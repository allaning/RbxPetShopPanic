local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)

local assetsFolder = ServerStorage:WaitForChild("Assets")
local serverProductsFolder = assetsFolder:WaitForChild("Products")


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

