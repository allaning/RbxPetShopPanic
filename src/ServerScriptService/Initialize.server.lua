local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local assetsFolder = ServerStorage:WaitForChild("Assets")
local serverProductsFolder = assetsFolder:WaitForChild("Products")


-- Remove Player ForceField
Promise.try(function()
  for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj.Name == "SpawnLocation" then
      lobbySpawn = obj
      obj.Duration = 0

      -- Add ceiling barrier to block cheaters
      local ceilingBarrier = Util:CreateInstance("Part", {
          Name = "ceilingBarrier",
          Position = Vector3.new(obj.Position.X, 16, obj.Position.Z),
          Size = Vector3.new(200, 1, 120),
          Anchored = true,
          CastShadow = false,
          Transparency = 1.0,
          CanCollide = true,
        }, Workspace)

      break
    end
  end
end)


-- Copy assets to ReplicatedStorage to assist in loading
local forLoadingFolder = Instance.new("Folder")
forLoadingFolder.Name = "ForLoading"
forLoadingFolder.Parent = ReplicatedStorage
local productsFolder = Util:CreateInstance("Folder", {
    Name = "ProductsFolder",
  }, forLoadingFolder)
for _, obj in pairs(serverProductsFolder:GetChildren()) do
  local clone = obj:Clone()
  clone.Parent = productsFolder
end

