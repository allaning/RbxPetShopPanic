-- This is the abstract root Consumer class 

--[[
Consumer rules:
  - Should be in ServerStorage/Assets/Consumers
  - Top level must be a Model with PrimaryPart
  - Must have Attribute named Input, which is a string matching name of input object
  - Recommended: Add a descendant Attachment named PromptAttachment where the ProximityPrompt will be located
  - Recommended: Add a descendant Part named ProductAttachmentPart where the Product received will be welded
  - Optional: Add an Attribute named ConsumeTimeSec to specify non-default time it takes to consume product
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local Consumer = {}
Consumer.__index = Consumer


-- Model Attribute override: ConsumeTimeSec [number]
Consumer.DEFAULT_CONSUME_TIME_SEC = 2.0


function Consumer.new()
  local self = {}
  setmetatable(self, Consumer)

  self.name = ""

  -- Input product for this consumer (string type), e.g. Carrot input for a Bunny consumer
  self.inputProductStr = ""

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

function Consumer:GetInput()
  return self.inputProductStr
end

function Consumer:SetInput(inputStr)
  self.inputProductStr = inputStr
end

function Consumer:GetModel()
  return self.itsModel
end

function Consumer:SetModel(model)
  self.itsModel = model
end

function Consumer:SetProximityPrompt(model)
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
    local prompt = ProximityPromptFactory.GetDefaultProximityPrompt(self:GetName(), "Feed")
    if prompt then
      ProximityPromptFactory.SetMaxDistance(prompt, 6)
      prompt.Parent = attachment
    end
  end
end

function Consumer:RunIdleAnimation(model)
  if model then
    local idleAnimationId = model:FindFirstChild("AnimationIdIdle")
    if idleAnimationId then
      print("Found AnimationIdIdle")
      local animationController = model:WaitForChild("AnimationController", 2)
      if animationController then
        local idleId = model:FindFirstChild("AnimationIdIdle")
        if idleId then
          idleAnimation = Instance.new("Animation")
          idleAnimation.AnimationId = idleId.Value
          idleAnimationTrack = animationController:LoadAnimation(idleAnimation)
          if idleAnimationTrack and not idleAnimationTrack.IsPlaying then
            idleAnimationTrack:Play()
          end
        end
      end
    end
  end
end

function Consumer:Run()
  -- Run in new thread
  Promise.try(function()
    print("Run: ".. self:GetName())

    -- Create folder to hold product model
    local consumerModel = self:GetModel()
    if consumerModel then
      self.itsProductFolder = Instance.new("Folder", consumerModel)
      self.itsProductFolder.Name = "Products"
    end

    local model = self:GetModel()
    if model then
      self:SetProximityPrompt(model)

      self:RunIdleAnimation(model)
    end
  end)
end


return Consumer
