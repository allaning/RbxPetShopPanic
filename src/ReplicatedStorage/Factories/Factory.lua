-- This is the abstract root Factory class 

-- Factory rules:
--   - Should be in ServerStorage/Assets/Factories
--   - Top level must be a Model with PrimaryPart and Spawner part


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local Product = require(ReplicatedStorage.Products.Product)


local Factory = {}
Factory.__index = Factory


-- Model Attribute override: SpawnDelaySec [number]
Factory.DEFAULT_SPAWN_DELAY_SEC = 5.0


function Factory.new()
  local self = {}
  setmetatable(self, Factory)

  self.spawnTimeSec = Factory.DEFAULT_SPAWN_DELAY_SEC

  -- Handle to the product object (not the model)
  self.itsProduct = nil

  -- Folder to hold the product model
  self.itsProductFolder = nil

  self.itsModel = nil

  return self
end

function Factory:GetProductName()
  return self.itsModel.Name
end

function Factory:GetModel()
  return self.itsModel
end

function Factory:SetModel(model)
  self.itsModel = model
end

function Factory:GetSpawnTimeSec()
  return self.spawnTimeSec
end

function Factory:SetSpawnTimeSec(spawnTimeSec)
  self.spawnTimeSec = spawnTimeSec
end

function Factory:GetProduct()
  return self.itsProduct
end

function Factory:SetProduct(productInstance)
  self.itsProduct = productInstance
end

-- Generate a product in its folder
function Factory:GenerateProduct(instance)
  Util:RealWait(self:GetSpawnTimeSec())

  local product = self:GetProduct()
  if product then
    print("  Factory:GetProduct: ".. product:GetName())
    local productClone = product:GetModelClone()
    if productClone then
      local factoryModel = self:GetModel()
      if factoryModel then
        local spawnPart = factoryModel:WaitForChild("Spawner")
        productClone:SetPrimaryPartCFrame(spawnPart.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
        productClone.Parent = self.itsProductFolder
      end
    end
  end
end

function Factory:Run()
  -- Run in new thread
  Promise.try(function()
    print("Run: ".. self:GetProductName())

    -- Create folder to hold product model
    local factoryModel = self:GetModel()
    if factoryModel then
      self.itsProductFolder = Instance.new("Folder", factoryModel)
      self.itsProductFolder.Name = "Products"
    end

    -- Create event for whenever product is removed
    self.itsProductFolder.ChildRemoved:Connect(function(instance)
      self:GenerateProduct()
    end)

    self:GenerateProduct()
  end)
end


return Factory
