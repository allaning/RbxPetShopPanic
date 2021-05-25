-- Animation IDs: https://developer.roblox.com/en-us/articles/catalog-animations

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LevelRequestVotesEvent = ReplicatedStorage.Events.LevelRequestVotes
local PlayerRemovingEvent = ReplicatedStorage.Events.PlayerRemoving

local Players = game:GetService("Players")


Players.RespawnTime = 0.0

Players.PlayerAdded:Connect(function(Player)
  print("PlayerAdded: ".. Player.Name)

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

  LevelRequestVotesEvent:FireAllClients()
end)

Players.PlayerRemoving:Connect(function(Player)
  print("PlayerRemoving: ".. Player.Name)
  LevelRequestVotesEvent:FireAllClients()
  PlayerRemovingEvent:Fire(Player)
end)

