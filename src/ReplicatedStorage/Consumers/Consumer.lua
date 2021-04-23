-- This is the abstract root Consumer class 

--[[
Consumer rules:
  - Should be in ServerStorage/Assets/Consumers
  - Top level must be a Model with PrimaryPart
  - Must have Attribute named Input, which is a string matching name of input object
  - Recommended: Add a 1st level child Part with Attachment named PromptAttachment where the ProximityPrompt will be located
  - Recommended: Add a descendant Part named ProductAttachmentPart where the Product received will be welded
  - Optional: Add an Attribute named PromptObjectText to specify non-default ObjectText for ProximityPrompt
  - Optional: Add an Attribute named PromptActionText to specify non-default ActionText for ProximityPrompt
  - Optional: Add an Attribute named HoldDuration to specify non-default time it takes to give product to consumer
  - Optional: Add an Attribute named ConsumeTimeSec to specify non-default time it takes to consume product
  - Optional: Add an Attribute named ExpireTimeSec to specify non-default time it takes to quit waiting for input
  - Optional: Add an Attribute named ExtraInputRequestDelaySec to specify additional time to wait before requesting input
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)
local SoundModule = require(ReplicatedStorage.SoundModule)

local ShowOverheadBillboardEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowOverheadBillboard")
local UpdateOverheadBillboardEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateOverheadBillboard")
local ReplicatedStorageAssetsFolder = ReplicatedStorage:WaitForChild("Assets")


local Consumer = {}
Consumer.__index = Consumer


-- Default time after requesting an input before quitting
Consumer.DEFAULT_EXPIRE_TIME_SEC = 60

-- Show first warning when this much time left
Consumer.YELLOW_WARNING_TIME_SEC_BEFORE_EXPIRING = 20
Consumer.YELLOW_WARNING_COLOR = Color3.new(0.7, 0.7, 0)

-- Show second warning when this much time left
Consumer.RED_WARNING_TIME_SEC_BEFORE_EXPIRING = 10
Consumer.RED_WARNING_COLOR = Color3.new(0.7, 0, 0)

-- Sound when consumer initiates its input request
Consumer.INPUT_REQUEST_BEGIN_SOUND = SoundModule.SOUND_ID_DRIP

-- Sound when consumer receives its input request
Consumer.INPUT_REQUEST_RECEIVED_SOUND = SoundModule.SOUND_ID_LEVEL_UP_HIGH

-- Sound when consumer doesn't get its input in time
Consumer.INPUT_REQUEST_EXPIRED_SOUND = SoundModule.SOUND_ID_WAH

-- Additional delay time before requesting first input
Consumer.INITIAL_INPUT_REQUEST_DELAY_SEC = 5.0

-- Min delay time before requesting input
Consumer.MIN_INPUT_REQUEST_DELAY_SEC = 5.0

-- Max delay time before requesting input
Consumer.MAX_INPUT_REQUEST_DELAY_SEC = 15.0

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

  self.expireTimeSec = Consumer.DEFAULT_EXPIRE_TIME_SEC

  -- Input product for this consumer (string type), e.g. Carrot input for a Bunny consumer
  self.inputProductStr = ""

  -- Handle to its product model
  self.itsProductModel = nil

  -- Folder to hold the product model
  self.itsProductFolder = nil

  self.itsModel = nil

  -- Handle to Promise waiting for consumer's input request to be fulfilled
  self.itsAwaitingInputHandler = nil

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

-- Pass color=nil to indicate that timer expired
local function runTimer(itself, delaySec, model, attachmentPart, color)
  return Promise.new(function(resolve, reject, onCancel)
    Util:RealWait(delaySec)

    -- Check to see if timer was cancelled
    if onCancel(function()
        --print("Time was cancelled for ".. model.Name)
      end) then
      return
    end

    -- Listener will check if color is nil and act accordingly
    UpdateOverheadBillboardEvent:FireAllClients(model, attachmentPart, color)

    if not color then
      -- Reset consumer
      itself:OnReceiveInput()
      itself:OnInputConsumed()
      return
    end

    resolve()
  end)
end

function Consumer:ShowInputRequest(model, productModel)
  if model and productModel then
    local attachmentPart = self.GetRequestInputGuiAttachmentPart(model)
    if attachmentPart then
      local productClone = productModel:Clone()
      productClone.Parent = ReplicatedStorageAssetsFolder -- Move product clone somewhere accessible by clients
      print("ShowOverheadBillboardEvent:FireAllClients; model=".. model.Name.. "; product=".. productClone.Name)
      ShowOverheadBillboardEvent:FireAllClients(model, attachmentPart, productClone)

      -- Allow input consumption
      model:SetAttribute(Consumer.IS_REQUESTING_INPUT_ATTR_STR, true)

      -- Start the timer
      local awaitingInputHandler = Promise.resolve() -- Begin Promise chain
        :doneCall(
          runTimer, self, self.expireTimeSec - Consumer.YELLOW_WARNING_TIME_SEC_BEFORE_EXPIRING, model, attachmentPart, Consumer.YELLOW_WARNING_COLOR
        ):doneCall(
          runTimer, self, Consumer.YELLOW_WARNING_TIME_SEC_BEFORE_EXPIRING - Consumer.RED_WARNING_TIME_SEC_BEFORE_EXPIRING, model, attachmentPart, Consumer.RED_WARNING_COLOR
        ):doneCall(
          runTimer, self, Consumer.RED_WARNING_TIME_SEC_BEFORE_EXPIRING, model, attachmentPart, nil
        ):catch(function(err)
          print("Error in Consumer ".. self:GetName().. " while waiting for input: ".. tostring(err))
        end)

      print("Exiting ShowInputRequest")
      return awaitingInputHandler
    end
  end
end

local PROXIMITY_PROMPT_DISTANCE = 6
function Consumer:SetProximityPrompt(model, actionText)
  if model then
    local attachment = self:GetProximityPromptAttachment(model)

    -- Create the prompt
    local prompt = ProximityPromptFactory.GetDefaultProximityPrompt(self:GetName(), actionText)
    if prompt then
      ProximityPromptFactory.SetMaxDistance(prompt, PROXIMITY_PROMPT_DISTANCE)

      -- Check if consumer has non-default name
      local objectText = model:GetAttribute("PromptObjectText")
      if objectText then
        ProximityPromptFactory.SetObjectText(prompt, objectText)
      end

      -- Check if consumer has a HoldDuration
      local holdDuration = model:GetAttribute("HoldDuration")
      if holdDuration then
        ProximityPromptFactory.SetHoldDuration(prompt, holdDuration)
      end

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

function Consumer:OnReceiveInput(instance)
  -- Set attribute to disallow input consumption until next request
  local model = self:GetModel()
  if model then
    model:SetAttribute(Consumer.IS_REQUESTING_INPUT_ATTR_STR, false)
  end

  -- Cancel any existing timer
  if self.itsAwaitingInputHandler then
    print("Cancelling timer for consumer: ".. self:GetName())
    self.itsAwaitingInputHandler:cancel()
  end
end

function Consumer:OnInputConsumed(instance)
  -- Repeat after delay
  local model = self:GetModel()
  if model then
    local extraDelaySec = model:GetAttribute("ExtraInputRequestDelaySec") or 0
    local rand = Random.new()
    local randNum = rand:NextNumber(Consumer.MIN_INPUT_REQUEST_DELAY_SEC, Consumer.MAX_INPUT_REQUEST_DELAY_SEC)
    Promise.delay(extraDelaySec + randNum):andThen(function()
      self.itsAwaitingInputHandler = self:ShowInputRequest(model, self:GetInputModel())
    end)
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

      local actionTextStr = model:GetAttribute("PromptActionText") or "Feed"
      self:SetProximityPrompt(model, actionTextStr)

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

      -- Check if consumer has a non-default expire time
      local customExpireTimeSec = model:GetAttribute("ExpireTimeSec")
      if customExpireTimeSec then
        self.expireTimeSec = customExpireTimeSec
      end

      self:RunIdleAnimation(model)

      -- Show first input request
      Promise.delay(Consumer.INITIAL_INPUT_REQUEST_DELAY_SEC):andThen(function()
        self:OnInputConsumed()
      end)

      -- Create event for whenever product is received (i.e. input received)
      self.itsProductFolder.ChildAdded:Connect(function(instance)
        self:OnReceiveInput(instance)
      end)

      -- Create event for whenever product is removed (i.e. input received, then consumed)
      self.itsProductFolder.ChildRemoved:Connect(function(instance)
        self:OnInputConsumed(instance)
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
