-- This is the abstract root TrashBin class 

--[[
TrashBin rules:
  - Should be in ServerStorage/Assets/TrashBins
  - Top level must be a Model with PrimaryPart
  - Recommended: Add a descendant Attachment named PromptAttachment where the ProximityPrompt will be located
  - Recommended: Add a descendant Part named ProductAttachmentPart where the Product received will be welded
]]--


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptFactory = require(ReplicatedStorage.Gui.ProximityPromptFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local TrashBin = {}
TrashBin.__index = TrashBin


function TrashBin.new()
  local self = {}
  setmetatable(self, TrashBin)

  self.name = "Trash Bin"

  -- Folder to hold the product model
  self.itsProductFolder = nil

  self.itsModel = nil

  return self
end

function TrashBin:GetName()
  return self.name
end

function TrashBin:SetName(name)
  self.name = name
end

function TrashBin:GetModel()
  return self.itsModel
end

function TrashBin:SetModel(model)
  self.itsModel = model
end

function TrashBin:SetProximityPrompt(model)
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
      ProximityPromptFactory.SetMaxDistance(prompt, 6)
      prompt.Parent = attachment
    end
  end
end

function TrashBin:Run()
  -- Run in new thread
  Promise.try(function()
    print("Run: ".. self:GetName())

    -- Create folder to hold product model
    local trashBinModel = self:GetModel()
    if trashBinModel then
      self.itsProductFolder = Instance.new("Folder", trashBinModel)
      self.itsProductFolder.Name = "Products"
    end

    local model = self:GetModel()
    if model then
      self:SetProximityPrompt(model)
    end
  end)
end

function TrashBin:Cleanup()
  self.itsModel:Destroy()
  self.itsModel = nil
end


return TrashBin
