-- Animation IDs: https://developer.roblox.com/en-us/articles/catalog-animations

local ServerScriptService = game:GetService("ServerScriptService")
local BadgeUtil = require(ServerScriptService.BadgeUtil)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")


Players.RespawnTime = 0.0

Players.PlayerAdded:Connect(function(Player)
  print("PlayerAdded: ".. Player.Name)

  BadgeUtil.AwardWelcomeBadge(Player)


  -- CharacterAdded
  Player.CharacterAdded:Connect(function(Character)
    Character:WaitForChild("Animate").walk.WalkAnim.AnimationId = "rbxassetid://910034870"
    Character:WaitForChild("Animate").run.RunAnim.AnimationId = "rbxassetid://910025107"

    -- Create folder to hold products
    local productsFolder = Character:FindFirstChild("Products")
    if not productsFolder then
      productsFolder = Instance.new("Folder", Character)
      productsFolder.Name = "Products"
    end

    -- Set walk speed
    local humanoid = Character:FindFirstChild("Humanoid")
    humanoid.WalkSpeed = 18

  end)
end)

