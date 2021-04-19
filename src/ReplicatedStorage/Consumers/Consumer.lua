-- This is the abstract root Consumer class 

--[[
Consumer rules:
  - Should be in ServerStorage/Assets/Consumers
  - Top level must be a Model with PrimaryPart
  - Must have Attribute named Input, which is a string matching name of input object
  - Recommended: Add a 1st level child Part with Attachment named PromptAttachment where the ProximityPrompt will be located
  - Recommended: Add a descendant Part named ProductAttachmentPart where the Product received will be welded
  - Optional: Add an Attribute named ConsumeTimeSec to specify non-default time it takes to consume product
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local ShowOverheadBillboardEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowOverheadBillboard")
local ReplicatedStorageAssetsFolder = ReplicatedStorage:WaitForChild("Assets")

local Consumer = {}
Consumer.__index = Consumer


-- Multiplier for delay time before requesting first input
Consumer.INITIAL_INPUT_REQUEST_DELAY_MULTIPLIER = 2.5

-- Min delay time before requesting input
Consumer.MIN_INPUT_REQUEST_DELAY_SEC = 5.0

-- Max delay time before requesting input
Consumer.MAX_INPUT_REQUEST_DELAY_SEC = 9.0

-- Model Attribute override: ConsumeTimeSec [number]
Consumer.DEFAULT_CONSUME_TIME_SEC = 2.0

-- Name of Part to attach Request Input Gui
Consumer.REQUEST_INPUT_GUI_ATTACHMENT_PART_NAME = "RequestInputGuiAttachmentPart"

-- Name of Part to attach input Product
Consumer.PRODUCT_ATTACHMENT_PART_NAME = "ProductAttachmentPart"

-- Name of attribute that indicates whether consumer is currently asking for an input
Consumer.IS_REQUESTING_INPUT_ATTR_STR = "IsRequestingInput"

-- Name of UID Attribute
-- This can be used to identify the consumer on the client side, etc.
Consumer.UID_ATTRIBUTE_NAME = "UID"

Consumer.UID_UNINITIALIZED = -1

function Consumer.new()
  local self = {}
  setmetatable(self, Consumer)

  self.name = ""

  -- Unique ID for this consumer instance
  self.uid = Consumer.UID_UNINITIALIZED

  -- Input product for this consumer (string type), e.g. Carrot input for a Bunny consumer
  self.inputProductStr = ""

  -- Handle to its product model
  self.itsProductModel = nil

  -- Folder to hold the product model
  self.itsProductFolder = nil

  self.itsModel = nil

  return self
end

function Consumer:GetName()
  return self.name
end

function Consumer:SetName(name)
  self.name = name
end

function Consumer:GetUid()
  return self.uid
end

function Consumer:SetUid(uid)
  self.uid = uid

  if self.itsModel then
    self.itsModel:SetAttribute(Consumer.UID_ATTRIBUTE_NAME, self.uid)
  end
end

function Consumer:GetInput()
  return self.inputProductStr
end

function Consumer:SetInput(inputStr)
  self.inputProductStr = inputStr
end

function Consumer:GetInputModel()
  return self.itsProductModel
end

function Consumer:SetInputModel(inputModel)
  self.itsProductModel = inputModel
end

function Consumer:GetModel()
  return self.itsModel
end

function Consumer:SetModel(model)
  self.itsModel = model
end

local PROXIMITY_PROMPT_HEIGHT_ABOVE_PART = 6
function Consumer:GetProximityPromptAttachment(model)
  local attachment = nil
  -- Check if model already has an attachment
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
      attachment.Position = Vector3.new(0, PROXIMITY_PROMPT_HEIGHT_ABOVE_PART, 0)
    end
  end
  return attachment
end

local REQUEST_INPUT_GUI_HEIGHT_ABOVE_PART = 4.5
function Consumer.GetRequestInputGuiAttachmentPart(model)
  if model then
    local attachment = nil
    -- Check if model already has an attachment
    for _, obj in pairs(model:GetDescendants()) do
      if obj.Name == Consumer.REQUEST_INPUT_GUI_ATTACHMENT_PART_NAME then
        attachment = obj
        break
      end
    end
    if not attachment then
      -- Create a default attachment
      local primaryPart = model.PrimaryPart
      if primaryPart then
        attachment = Instance.new("Attachment", primaryPart)
        attachment.Name = Consumer.REQUEST_INPUT_GUI_ATTACHMENT_PART_NAME
        attachment.Position = primaryPart.Position + Vector3.new(0, REQUEST_INPUT_GUI_HEIGHT_ABOVE_PART, 0)
      end
    end
    return attachment
  end
end

function Consumer:ShowInputRequest(model, productModel)
  if model and productModel then
    local attachmentPart = self.GetRequestInputGuiAttachmentPart(model)
    if attachmentPart then
      local productClone = productModel:Clone()
      productClone.Parent = ReplicatedStorageAssetsFolder -- Move product clone somewhere accessible by clients
      ShowOverheadBillboardEvent:FireAllClients(model, attachmentPart, productClone)

      -- Allow input consumption
      model:SetAttribute(Consumer.IS_REQUESTING_INPUT_ATTR_STR, true)
    end
  end
end

local PROXIMITY_PROMPT_DISTANCE = 6
function Consumer:SetProximityPrompt(model)
  if model then
    local attachment = self:GetProximityPromptAttachment(model)

    -- Create the prompt
    local actionTextStr = model:GetAttribute("PromptActionText") or "Feed"
    local prompt = ProximityPromptFactory.GetDefaultProximityPrompt(self:GetName(), actionTextStr)
    if prompt then
      ProximityPromptFactory.SetMaxDistance(prompt, PROXIMITY_PROMPT_DISTANCE)
      prompt.Parent = attachment
    end
  end
end

function Consumer:RunIdleAnimation(model)
  if model then
    Promise.try(function()
      local idleAnimationId = model:FindFirstChild("AnimationIdIdle")
      if idleAnimationId then
        local animationController = model:WaitForChild("AnimationController", 2)
        if animationController then
          idleAnimation = Instance.new("Animation")
          idleAnimation.AnimationId = idleAnimationId.Value
          idleAnimationTrack = animationController:LoadAnimation(idleAnimation)
          if idleAnimationTrack and not idleAnimationTrack.IsPlaying then
            idleAnimationTrack:Play()
          end
        end
      else
        -- Look for humanoid animation
        local humanIdleAnimationId = model:FindFirstChild("HumanoidAnimationIdIdle")
        if humanIdleAnimationId then
          for _, obj in pairs(model:GetDescendants()) do
            if obj.Name == "Humanoid" then
              local animation = Instance.new("Animation")
              animation.AnimationId = humanIdleAnimationId.Value
              local animationTrack = obj:LoadAnimation(animation)
              animationTrack:Play()
            end
          end
        end
      end
    end):catch(function() warn("Error loading animation for ".. model.Name) end)
  end
end

function Consumer:Run()
  -- Run in new thread
  Promise.try(function()
    print("Run: ".. self:GetName())

    -- Create folder to hold product model
    local model = self:GetModel()
    if model then
      self.itsProductFolder = Instance.new("Folder", model)
      self.itsProductFolder.Name = "Products"

      -- Create attribute indicating if consumer is requesting an input
      model:SetAttribute(Consumer.IS_REQUESTING_INPUT_ATTR_STR, false)

      self:SetProximityPrompt(model)

      -- Break any welds from HumanoidRootPart so they don't move with NPC animation
      --for _, obj in pairs(model:GetDescendants()) do
      --  if obj.Name == "HumanoidRootPart" then
      --    for __, child in pairs(obj:GetChildren()) do
      --      if child:IsA("Motor6D") then
      --        print("Destroy welds in HumanoidRootPart for ".. self:GetName())
      --        --print("   0".. child.Part0)
      --        --print("   1".. child.Part1)
      --        --child:Destroy()
      --      end
      --    end
      --  end
      --end

      self:RunIdleAnimation(model)

      -- Show first input request
      local rand = Random.new()
      local randNum = rand:NextNumber(Consumer.MIN_INPUT_REQUEST_DELAY_SEC, Consumer.MAX_INPUT_REQUEST_DELAY_SEC)
      randNum *= Consumer.INITIAL_INPUT_REQUEST_DELAY_MULTIPLIER
      Promise.delay(randNum):andThen(function()
        self:ShowInputRequest(model, self:GetInputModel())
      end)

      -- Create event for whenever product is removed
      self.itsProductFolder.ChildRemoved:Connect(function(instance)
        model:SetAttribute(Consumer.IS_REQUESTING_INPUT_ATTR_STR, false)
        local randNum = rand:NextNumber(Consumer.MIN_INPUT_REQUEST_DELAY_SEC, Consumer.MAX_INPUT_REQUEST_DELAY_SEC)
        Promise.delay(randNum):andThen(function()
          self:ShowInputRequest(model, self:GetInputModel())
        end)
      end)
    end
  end):catch(function(err)
    local name = self:GetName() or "UNKNOWN"
    warn("Error in Run() for ".. name.. ": ".. tostring(err))
  end)
end

function Consumer:Cleanup()
  self.itsModel:Destroy()
  self.itsModel = nil
end


return Consumer
