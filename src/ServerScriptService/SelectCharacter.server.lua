-- https://devforum.roblox.com/t/character-morph-script/1199389

local MarketplaceService = game:GetService("MarketplaceService")

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Avatars = require(ReplicatedStorage.Avatars)
local ModelUtil = require(ReplicatedStorage.ModelUtil)
local Util = require(ReplicatedStorage.Util)

local ShowMessagePopupEvent = ReplicatedStorage.Events.ShowMessagePopup
local SelectCharacterRequestEvent = ReplicatedStorage.Events.SelectCharacterRequest
local SelectShoulderPetRequestEvent = ReplicatedStorage.Events.SelectShoulderPetRequest
local UpdateCharacterEvent = ReplicatedStorage.Events.UpdateCharacter

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerManager = require(ServerScriptService.PlayerManager)
local GetPlayerManagerInstanceBindableFn = ServerScriptService.Bindable.GetPlayerManagerInstanceBindable

local CharacterFolder = ReplicatedStorage.Avatar.Characters
local ShoulderPetFolder = ReplicatedStorage.Avatar.ShoulderPets
local ShoulderPetTemplateFolder = ReplicatedStorage.Avatar.ShoulderPetTemplates

local Players = game:GetService("Players")


local function transform(playerCharacter, characterModel)
  if playerCharacter.PrimaryPart then
    local modelClone = characterModel:Clone()

    modelClone:SetPrimaryPartCFrame(playerCharacter.PrimaryPart.CFrame+Vector3.new(0, modelClone:GetExtentsSize().Y, 0))
    local humanoid = playerCharacter:WaitForChild("Humanoid")
    local function unkill()
      humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
    for i,v in pairs(humanoid:GetPlayingAnimationTracks()) do
      v:Stop()
    end
    humanoid.Parent = ReplicatedStorage
    unkill()
    for i,v in pairs(playerCharacter:GetChildren()) do
      if v.Name ~= "Humanoid" and v.Name ~= "HumanoidRootPart" and not v:IsA("Script") and not v:IsA("LocalScript") then
        -- Don't delete custom objects (e.g. created in InitializePlayer.server.lua)
        if v.Name ~= "Products" and not string.find(v.Name, "ShoulderPet") then
          v:Destroy()
        end
      end
    end
    local cloneHumanoid = modelClone:WaitForChild("Humanoid", 1)
    if cloneHumanoid then
      local hipheight = cloneHumanoid.HipHeight

      local primary = modelClone.PrimaryPart
      for i,v in pairs(modelClone:GetChildren()) do
        if v.Name ~= "Humanoid" and v.Name ~= "HumanoidRootPart" then
          v.Parent = playerCharacter

          -- Remove TouchInterest parts (e.g. so accessories don't jump from player to player!)
          for i, desc in pairs(v:GetDescendants()) do
            if desc.Name == 'TouchInterest' then
              desc:Destroy()
            end
          end
        end
      end
    end

    -- synchronize
    modelClone:Destroy()
    playerCharacter.PrimaryPart = playerCharacter:WaitForChild("HumanoidRootPart")
    humanoid.HipHeight = hipheight
    humanoid.Parent = playerCharacter
    playerCharacter.PrimaryPart = playerCharacter:WaitForChild("HumanoidRootPart")
    humanoid.HipHeight = hipheight

    -- Copy description
    --local description = humanoid:GetAppliedDescription()
    --description.HeadScale = 1.0
    --humanoid:ApplyDescription(description)

    local plr = Players:GetPlayerFromCharacter(playerCharacter)
    if plr then
      UpdateCharacterEvent:FireClient(plr, hipheight)
    end
  end
end

local function checkSelectCharacterRequest(player, folderName, modelName)
  local character = Util:GetCharacterFromPlayer(player)
  if character then
    -- Find model
    local characterModel = CharacterFolder[folderName][modelName]
    if characterModel then
      -- Check requirements
      local plrMgr = GetPlayerManagerInstanceBindableFn:Invoke(player.Name)
      if plrMgr then
        -- Points
        local costPoints = characterModel:GetAttribute(Avatars.COST_POINTS_ATTR_NAME)
        if costPoints then
          if PlayerManager.GetPoints(plrMgr) < costPoints then
            ShowMessagePopupEvent:FireClient(player, "Need ".. costPoints.. " stars", 2.0)
            return
          end
        end

        -- Robux
        local costRobux = characterModel:GetAttribute(Avatars.COST_ROBUX_ATTR_NAME)
        if costRobux then
          -- Check if player owns avatar
          local productId = characterModel:GetAttribute(Avatars.PRODUCT_ID_ATTR_NAME)
          local playerOwnsAvatar = PlayerManager.DoesPlayerOwnProductId(plrMgr, productId)

          if not playerOwnsAvatar then
            -- Prompt for purchase
            MarketplaceService:PromptProductPurchase(player, productId)
            return
          end
        end

        transform(character, characterModel)
      else
        warn("Could not get PlayerManager for ".. player.Name)
      end
    else
      warn("Cannot get Character from ".. player.Name)
    end
  end
end
SelectCharacterRequestEvent.OnServerEvent:Connect(checkSelectCharacterRequest)

local function checkSelectShoulderPetRequest(player, folderName, modelName)
  local character = Util:GetCharacterFromPlayer(player)
  if character then
    -- Find model
    local shoulderPetModel = ShoulderPetFolder[folderName][modelName]
    if shoulderPetModel then
      -- Check requirements
      local plrMgr = GetPlayerManagerInstanceBindableFn:Invoke(player.Name)
      if plrMgr then
        -- Points
        local costPoints = shoulderPetModel:GetAttribute(Avatars.COST_POINTS_ATTR_NAME)
        if costPoints then
          if PlayerManager.GetPoints(plrMgr) < costPoints then
            ShowMessagePopupEvent:FireClient(player, "Need ".. costPoints.. " stars", 2.0)
            return
          end
        end

        -- Robux
        local costRobux = shoulderPetModel:GetAttribute(Avatars.COST_ROBUX_ATTR_NAME)
        if costRobux then
          -- Check if player owns avatar
          local productId = shoulderPetModel:GetAttribute(Avatars.PRODUCT_ID_ATTR_NAME)
          local playerOwnsAvatar = PlayerManager.DoesPlayerOwnProductId(plrMgr, productId)

          if not playerOwnsAvatar then
            -- Prompt for purchase
            MarketplaceService:PromptProductPurchase(player, productId)
            return
          end
        end

        -- Check if the model is based on a template
        local templateModelName = shoulderPetModel:GetAttribute(Avatars.TEMPLATE_MODEL_ATTR_NAME)
        if templateModelName then
          local existingAccessory = shoulderPetModel:FindFirstChildWhichIsA("Accessory")
          if not existingAccessory then
            local templateModel = ShoulderPetTemplateFolder:WaitForChild(templateModelName, 1)
            if templateModel then
              local accessory = templateModel:FindFirstChildWhichIsA("Accessory")
              if accessory then
                local accessoryClone = accessory:Clone()
                accessoryClone.Parent = shoulderPetModel
                -- Set PrimaryPart and color parts
                ModelUtil.SetPrimaryPartAndColors(shoulderPetModel)
              end
            end
          end
        end

        local humanoid = character:WaitForChild("Humanoid")
        local accessory = shoulderPetModel:FindFirstChildWhichIsA("Accessory")
        if humanoid and accessory then
          -- Remove old pets if any
          for i,v in pairs(character:GetChildren()) do
            if string.find(v.Name, "ShoulderPet") then
              v:Destroy()
            end
          end

          -- Add new pet
          humanoid:AddAccessory(accessory:Clone())
          UpdateCharacterEvent:FireClient(player)
        else
          warn("Could not get Humanoid or Accessory for ".. player.Name.. ", ".. modelName)
        end
      else
        warn("Could not get PlayerManager for ".. player.Name)
      end
    else
      warn("Cannot get Character from ".. player.Name)
    end
  end
end
SelectShoulderPetRequestEvent.OnServerEvent:Connect(checkSelectShoulderPetRequest)

