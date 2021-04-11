-- This is the abstract root Product class 

--[[
Product rules:
  - Should be in ServerStorage/Assets/Products
  - Top level must be a Model with PrimaryPart
  - Optional: Add an Attachment named "PromptAttachment" to PrimaryPart
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)


local Product = {}
Product.__index = Product


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
        ProximityPromptFactory.SetMaxDistance(prompt, 5)
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

function Product:SetModel(model)
  self.itsModel = model
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
