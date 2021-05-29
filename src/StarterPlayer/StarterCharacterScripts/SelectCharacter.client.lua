-- https://devforum.roblox.com/t/tutorial-changing-character-while-ingame-with-custom-rigs/976315

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Util = require(ReplicatedStorage.Util)

local CharactersFolder = Workspace:WaitForChild("Lobby"):WaitForChild("Characters")

local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Player.Character or Player.CharacterAdded:wait()
local Humanoid = Character:WaitForChild("Humanoid");
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");


Players.CharacterAutoLoads = false


-- Find morph parts and set up morph function

local function loadCharacter(player, characterModel)
  print("Found ".. characterModel.Name)

  Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

  for _,v in ipairs(characterModel:GetChildren()) do
    if v.Name ~= "HumanoidRootPart" and v.Name ~= "Humanoid" then
      local part = v:Clone()
      Character[v.Name]:Destroy()
      part.Parent = Character
    end
  end

  Humanoid:BuildRigFromAttachments()

  Util:RealWait(10)
  Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)

  -- Put things from StarterCharacterScripts inside the char,
  -- cause it will not do automatically:
  for i, v in pairs(StarterPlayer.StarterCharacterScripts:GetChildren()) do
    --v:Clone().Parent = newCharacter
  end

  -- Here, local scripts wont run if
  -- they are inside a Tool or Accessory in the char.
  -- You can fix this by setting .Disabled = true and then
  -- .Disabled = false again in the LocalScript. 
  -- It is an engine bug.

  -- Default Player.CharacterAdded event wont run here,
  -- so create a custom one with a BindableEvent instance
  -- called CharacterAdded in ReplicatedStorage:
  --ReplicatedStorage.CharacterAdded:Fire(Player.Character)
end

local function transform(player, model)
  local char = player.Character
  local model=model:Clone()
  model:SetPrimaryPartCFrame(char.PrimaryPart.CFrame+Vector3.new(0,model:GetExtentsSize().Y,0))
  local h=char.Humanoid
  local function unkill()
    h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
  end
  for i,v in pairs(h:GetPlayingAnimationTracks()) do
    v:Stop()
  end
  h.Parent=game.ReplicatedStorage
  unkill()
  for i,v in pairs(char:GetChildren()) do
    if v.Name~="Humanoid" and not v:IsA("Script") and not v:IsA("LocalScript") then
      v:Destroy()
    end
  end
  local hipheight=model.Humanoid.HipHeight
  local primary=model.PrimaryPart
  for i,v in pairs(model:GetChildren()) do
    if v.Name~="Humanoid" then
      v.Parent=char
    end
  end
  -- synchronize.
  model:Destroy()
  char.PrimaryPart=char.HumanoidRootPart
  h.HipHeight=hipheight
  h.Parent=char
  char.PrimaryPart=char.HumanoidRootPart
  h.HipHeight=hipheight
  local plr=game.Players:GetPlayerFromCharacter(char)
  if plr then -- thanks roblox.
    --ReplicatedStorage.HipHeight:FireClient(plr,hipheight)
  end
end

-- I don't think this is needed
--for _, part in pairs(CharactersFolder:GetChildren()) do
--  local debounce = false
--  part.Touched:Connect(function(partTouched)
--    Promise.try(function()
--      if not debounce then
--        debounce = true
--        local characterModel = part:FindFirstChildWhichIsA("Model")
--        if characterModel then
--          --loadCharacter(Player, characterModel)
--          transform(Player, characterModel)
--
--          Humanoid.Died:Connect(function()
--            Util:RealWait(3) -- seconds between death and respawn
--            --loadCharacter(Player, characterModel)
--            transform(Player, characterModel)
--          end)
--        end
--
--        Util:RealWait(2)
--        debounce = false
--      end
--    end)
--  end)
--end

