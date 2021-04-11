-- This is the abstract root Transformer class 

--[[
Transformer rules:
  - Should be in ServerStorage/Assets/Transformers
  - Name must match name of product output
  - Top level must be a Model with PrimaryPart
  - Must have Attribute named Input, which is a string matching name of input object
  - Recommended: Add a descendant Part named ProductAttachmentPart where the Product received will be welded
  - Optional: Add an Attribute named TransformTimeSec to specify non-default transformation duration time
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local Product = require(ReplicatedStorage.Products.Product)


local Transformer = {}
Transformer.__index = Transformer


-- Model Attribute override: TransformTimeSec [number]
Transformer.DEFAULT_TRANSFORM_TIME_SEC = 5.0


function Transformer.new()
  local self = {}
  setmetatable(self, Transformer)

  self.spawnTimeSec = Transformer.DEFAULT_TRANSFORM_TIME_SEC

  -- Handle to the product object (not the model)
  self.itsProduct = nil

  -- Input product for this transformer (string type), e.g. Carrot Seed input for a Carrot transformer
  self.inputProductStr = ""

  -- Folder to hold the product model
  self.itsProductFolder = nil

  self.itsModel = nil

  return self
end

function Transformer:GetName()
  if self:GetModel() then
    return self:GetModel().Name
  end
end

function Transformer:GetProductName()
  if self.itsProduct then
    return self.itsProduct:GetName()
  end
end

function Transformer:GetInput()
  return self.inputProductStr
end

function Transformer:SetInput(inputStr)
  self.inputProductStr = inputStr
end

function Transformer:GetModel()
  return self.itsModel
end

function Transformer:SetModel(model)
  self.itsModel = model
end

function Transformer:GetTransformTimeSec()
  return self.transformTimeSec
end

function Transformer:SetTransformTimeSec(transformTimeSec)
  self.transformTimeSec = transformTimeSec
end

function Transformer:GetProduct()
  return self.itsProduct
end

function Transformer:SetProduct(productInstance)
  self.itsProduct = productInstance
end

function Transformer:SetProximityPrompt(model)
  if model then
    -- Check if model already has an attachment for the prompt
    local attachment = nil
    for _, obj in pairs(model:GetDescendants()) do
      if obj.Name == "PromptAttachment" then
        attachment = obj
        break
      end
    end
    if not attachment then
      -- Create a default attachment
      local primaryPart = model.PrimaryPart
      if primaryPart then
        attachment = Instance.new("Attachment", primaryPart)
        attachment.Name = "PromptAttachment"
        attachment.Position = Vector3.new(0, 6, 0)
      end
    end

    -- Create the prompt
    local prompt = ProximityPromptFactory.GetDefaultProximityPrompt(self:GetName(), "Drop")
    if prompt then
      print("PROMPT")
      ProximityPromptFactory.SetMaxDistance(prompt, 6)
      prompt.Parent = attachment
    end
  end
end

function Transformer:TransformProduct(productInstance)
  print("TRANSFORM")
end

function Transformer:Run()
  -- Run in new thread
  Promise.try(function()
    local model = self:GetModel()
    if model then
      print("Run: ".. self:GetName())

      -- Create folder to hold product model
      local transformerModel = model
      if transformerModel then
        self.itsProductFolder = Instance.new("Folder", transformerModel)
        self.itsProductFolder.Name = "Products"
      end

      self:SetProximityPrompt(model)

      -- Create event for whenever product is added
      self.itsProductFolder.ChildAdded:Connect(function(instance)
        self:TransformProduct()
      end)
    end
  end)
end


return Transformer
