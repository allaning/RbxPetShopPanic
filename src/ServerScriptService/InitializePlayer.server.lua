-- Animation IDs: https://developer.roblox.com/en-us/articles/catalog-animations

game.Players.PlayerAdded:Connect(function(Player)
  Player.CharacterAdded:Connect(function(Character)
    Character:WaitForChild("Animate").walk.WalkAnim.AnimationId = "rbxassetid://910034870"
    Character:WaitForChild("Animate").run.RunAnim.AnimationId = "rbxassetid://910025107"

    -- Create folder to hold products
    local productsFolder = Character:FindFirstChild("Products")
    if not productsFolder then
      productsFolder = Instance.new("Folder", Character)
      productsFolder.Name = "Products"
    end
  end)

end)

