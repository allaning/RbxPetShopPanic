-- This is the abstract root Transformer class 

--[[
Transformer rules:
  - Should be in ServerStorage/Assets/Transformers
  - Name must match name of product output
  - Top level must be a Model with PrimaryPart
  - Must have Attribute named Input, which is a string matching name of input object
  - Must have Attribute named TransformerName, which is the name of the transformer shown in prompts
  - Recommended: Add a descendant Part named ProductAttachmentPart where the Product received will be welded
  - Optional: Add an Attribute named PromptActionText to specify non-default ActionText for ProximityPrompt
  - Optional: Add an Attribute named TransformTimeSec to specify non-default transformation duration time
  - Optional: Add an Attribute (boolean) named IsAutomatic to specify whether player must hold key during transformation
  - Optional: Add an Attribute named ProximityHoldAnimationId (string) to specify animation ID to play during HoldDuration
  - Optional: Add a Part named ProximityHoldTargetPart to specify direction player sould face during HoldDuration
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)
local SoundModule = require(ReplicatedStorage.SoundModule)

local Product = require(ReplicatedStorage.Products.Product)

local TransformBeginEvent = ReplicatedStorage.Transformers.Events.TransformBegin


local Transformer = {}
Transformer.__index = Transformer


-- Sound when transformer done
Transformer.TRANSFORM_COMPLETE_SOUND = SoundModule.SOUND_ID_CHIME_2

-- Name of string Attribute indicating input(s)
Transformer.INPUT_ATTR_NAME = "Input"

-- Model Attribute override: TransformTimeSec [number]
Transformer.DEFAULT_TRANSFORM_TIME_SEC = 5.0

-- Model Attribute IsAutomatic name
Transformer.IS_AUTOMATIC_ATTR_NAME = "IsAutomatic"

-- Name of string Attribute indicating animation ID during Proximity HoldDuration
Transformer.PROXIMITY_HOLD_ANIMATION_ATTR_NAME = "ProximityHoldAnimationId"

-- Part that player should face during Proximity HoldDuration
Transformer.PROXIMITY_HOLD_TARGET_PART_NAME = "ProximityHoldTargetPart"


function Transformer.new()
  local self = {}
  setmetatable(self, Transformer)

  -- Name of transformer instance
  self.nameStr = ""

  self.transformTimeSec = Transformer.DEFAULT_TRANSFORM_TIME_SEC

  self.itsProximityPromptAttachment = nil

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
  return self.nameStr
end

function Transformer:SetName(name)
  self.nameStr = name
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

local TRANSFORMER_ATTACHMENT_HEIGHT_ABOVE_PART = 6
function Transformer:GetProximityPromptAttachment(model)
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
        attachment.Position = Vector3.new(0, TRANSFORMER_ATTACHMENT_HEIGHT_ABOVE_PART, 0)
      end
    end

    -- Save for future reference
    if not self.itsProximityPromptAttachment then
      self.itsProximityPromptAttachment = attachment
    end

    return attachment
  end
end

local function clearAttachment(attachment)
  for _, obj in ipairs(attachment:GetChildren()) do
    obj:Destroy()
  end
end

local PROXIMITY_PROMPT_DISTANCE = 7.5
function Transformer:SetProximityPrompt(model, actionText)
  if model then
    local attachment = self:GetProximityPromptAttachment(model)
    clearAttachment(attachment)

    -- Create the prompt
    local prompt = ProximityPromptFactory.GetDefaultProximityPrompt(self:GetName(), actionText)
    if prompt then
      ProximityPromptFactory.SetMaxDistance(prompt, PROXIMITY_PROMPT_DISTANCE)

      -- Check if player must hold key during transform
      local isAutomatic = model:GetAttribute(Transformer.IS_AUTOMATIC_ATTR_NAME)
      if not isAutomatic or isAutomatic == false then
        ProximityPromptFactory.SetHoldDuration(prompt, self:GetTransformTimeSec())
      end

      prompt.Parent = attachment
    end
  end
end

function Transformer:TransformProduct(productInstance)
  -- Clear any existing ProximityPrompts
  if self.itsProximityPromptAttachment then
    clearAttachment(self.itsProximityPromptAttachment)
  end

  if productInstance and productInstance.Name == self:GetInput() then
    local transformerModel = self:GetModel()
    if transformerModel then
      local spawnPart = transformerModel:WaitForChild("ProductAttachmentPart")
      local transformTimeSec = self:GetTransformTimeSec()

      -- Check if player must hold key during transform
      local isAutomatic = transformerModel:GetAttribute(Transformer.IS_AUTOMATIC_ATTR_NAME)
      if not isAutomatic or isAutomatic == false then
        -- Do not transform automatically, so don't show progress bar
        transformTimeSec = 0.05
      else
        -- Tell client to show transform progress
        TransformBeginEvent:FireAllClients(spawnPart, transformTimeSec)
      end

      -- Delay for the transform, if any
      Promise.delay(transformTimeSec):andThen(function()
        local productFolder = self.itsProductFolder
        if productFolder then
          local inputObj = productFolder:FindFirstChild(self:GetInput())
          if inputObj then
            inputObj:Destroy()

            -- Spawn output product
            local product = self:GetProduct()
            if product then
              print("  Transformer:GetProduct: ".. product:GetName())
              local productClone = product:GetModelClone()
              if productClone then
                productClone:SetPrimaryPartCFrame(spawnPart.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
                productClone.Parent = self.itsProductFolder
                SoundModule.PlayAssetIdStr(productClone, Transformer.TRANSFORM_COMPLETE_SOUND)
              end
            end
          end
        end
      end)

    end
  end
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

      -- Set initial proximity prompt
      local actionTextStr = model:GetAttribute("PromptActionText") or "Drop"
      self:SetProximityPrompt(model, actionTextStr)

      -- Create event for whenever product is added
      self.itsProductFolder.ChildAdded:Connect(function(instance)
        self:TransformProduct(instance)
      end)

      -- Create event for whenever product is removed
      self.itsProductFolder.ChildRemoved:Connect(function(instance)
        self:SetProximityPrompt(model, actionTextStr)
      end)
    end
  end)
end

function Transformer:Cleanup()
  self.itsProduct:Destroy()
  self.itsProduct = nil
  self.itsModel:Destroy()
  self.itsModel = nil
end


return Transformer
