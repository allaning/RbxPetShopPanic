-- This is the abstract root Consumer class 

-- Consumer rules:
--   - Should be in ServerStorage/Assets/Consumers
--   - Top level must be a Model with PrimaryPart


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local Consumer = {}
Consumer.__index = Consumer


function Consumer.new()
  local self = {}
  setmetatable(self, Consumer)

  self.itsModel = nil

  return self
end

function Consumer:GetName()
  return self.itsModel.Name
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

function Consumer:Run()
  -- Run in new thread
  Promise.try(function()
    print("Run: ".. self:GetName())

    if self:GetModel() then
      self:SetProximityPrompt(self:GetModel())
    end
  end)
end


return Consumer
