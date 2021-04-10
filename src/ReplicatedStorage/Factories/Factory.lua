-- This is the abstract root Factory class 


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local Product = require(ReplicatedStorage.Products.Product)


local Factory = {}
Factory.__index = Factory


function Factory.new()
  local self = {}
  setmetatable(self, Factory)

  self.spawnTimeSec = 5.0

  -- Handle to the product object (not the model)
  self.itsProduct = nil

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

function Factory:Run()
  -- Run in new thread
  Promise.try(function()
    print("Run: ".. self:GetProductName())

    -- Create folder to hold product model
    local factoryModel = self:GetModel()
    local productFolder = Instance.new("Folder", factoryModel)
    productFolder.Name = "Products"

    Util:RealWait(self:GetSpawnTimeSec())

    local product = self:GetProduct()
    if product then
      print("  Factory:GetProduct: ".. product:GetName())
      local productClone = product:GetModelClone()
      if productClone then
        local spawnPart = factoryModel:WaitForChild("Spawner")
        productClone.CFrame = spawnPart.CFrame
        productClone.Parent = productFolder
      end
    end

  end)
end


return Factory
