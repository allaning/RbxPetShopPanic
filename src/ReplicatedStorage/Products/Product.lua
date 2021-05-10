-- This is the abstract root Product class 

--[[
Product rules:
  - Should be in ServerStorage/Assets/Products
  - Top level must be a Model with PrimaryPart
  - Optional: Add Vector3 Attribute named ViewportCameraPosition to specify custom position for ViewportFrame Camera
  - Optional: Add Vector3 Attribute named ViewportTargetPositionOffset to specify target position offset for ViewportFrame Camera
  - Optional: Add an Attribute named IsAggregate to indicate that the product's descendants must match its input -- Note: Not implemented yet
  - Optional: Add an Attribute named ImageAssetId to Model; otherwise, ViewportFrame will be used -- Note: Not implemented yet
  - Optional: Add an Attachment named PromptAttachment to PrimaryPart to position the ProximityPrompt
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)


local Product = {}
Product.__index = Product


-- Default points earned for success
Product.DEFAULT_POINTS = 10


function Product.new()
  local self = {}
  setmetatable(self, Product)

  self.itsModel = nil

  return self
end

function Product:GetName()
  if self.itsModel then
    return self.itsModel.Name
  end
end

function Product:GetModel()
  return self.itsModel
end

function Product:SetModel(model)
  self.itsModel = model
end

local PROXIMITY_PROMPT_DISTANCE = 7.5
function Product:SetProximityPrompt(model)
  if model then
    -- Check if model already has an attachment for the prompt
    local primaryPart = model.PrimaryPart
    if primaryPart then
      local attachment = primaryPart:FindFirstChild("PromptAttachment")
      if not attachment then
        -- Create a default attachment
        attachment = Instance.new("Attachment", primaryPart)
        attachment.Name = "PromptAttachment"
        attachment.Position = Vector3.new(0, 4, 0)
      end
      -- Create the prompt
      local prompt = ProximityPromptFactory.GetDefaultProximityPrompt(self:GetName(), "Pick Up")
      if prompt then
        ProximityPromptFactory.SetMaxDistance(prompt, PROXIMITY_PROMPT_DISTANCE)
        prompt.Parent = attachment
      end
    end
  end
end

function Product:GetModelClone()
  if self:GetModel() then
    local clone = self:GetModel():Clone()
    self:SetProximityPrompt(clone)
    return clone
  end
end

function Product:GetModelPrimaryPart()
  if self:GetModel() then
    local pri = self:GetModel()
    return pri.PrimaryPart
  else
    warn("Product:GetModelPrimaryPart() could not find PrimaryPart for ".. self:GetName())
  end
end

function Product:Cleanup()
  self.itsModel:Destroy()
  self.itsModel = nil
end


return Product
