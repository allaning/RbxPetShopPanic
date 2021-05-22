-- https://devforum.roblox.com/t/character-morph-script/1199389

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Util = require(ReplicatedStorage.Util)

local UpdateCharacterEvent = ReplicatedStorage.Events.UpdateCharacter

local CharactersFolder = Workspace.Lobby.Characters

local Players = game:GetService("Players")


local function transform(char, model)
  if char.PrimaryPart then
    local model = model:Clone()
    model:SetPrimaryPartCFrame(char.PrimaryPart.CFrame+Vector3.new(0,model:GetExtentsSize().Y,0))
    local h = char:WaitForChild("Humanoid")
    local function unkill()
      h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
    for i,v in pairs(h:GetPlayingAnimationTracks()) do
      v:Stop()
    end
    h.Parent = ReplicatedStorage
    unkill()
    for i,v in pairs(char:GetChildren()) do
      if v.Name ~= "Humanoid" and v.Name ~= "HumanoidRootPart" and not v:IsA("Script") and not v:IsA("LocalScript") then
        -- Don't delete custom objects (e.g. created in InitializePlayer.server.lua)
        if v.Name ~= "Products" then
          v:Destroy()
        end
      end
    end
    local hipheight = model.Humanoid.HipHeight
    local primary = model.PrimaryPart
    for i,v in pairs(model:GetChildren()) do
      if v.Name ~= "Humanoid" and v.Name ~= "HumanoidRootPart" then
        v.Parent = char
      end
    end

    -- synchronize
    model:Destroy()
    char.PrimaryPart = char:WaitForChild("HumanoidRootPart")
    h.HipHeight = hipheight
    h.Parent = char
    char.PrimaryPart = char:WaitForChild("HumanoidRootPart")
    h.HipHeight = hipheight
    local plr = Players:GetPlayerFromCharacter(char)
    if plr then
      UpdateCharacterEvent:FireClient(plr, hipheight)
    end
  end
end

for _, part in pairs(CharactersFolder:GetChildren()) do
  local debounce = false
  part.Touched:Connect(function(partTouched)
    Promise.try(function()
      if not debounce then
        debounce = true

        local character = partTouched.Parent
        local characterModel = part:FindFirstChildWhichIsA("Model")
        if characterModel then
          transform(character, characterModel)
        end

        Util:RealWait(2)
        debounce = false
      end
    end)
  end)
end

