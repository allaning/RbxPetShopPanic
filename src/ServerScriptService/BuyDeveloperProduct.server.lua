local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Avatars = require(ReplicatedStorage.Avatars)
local Util = require(ReplicatedStorage.Util)

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerManager = require(ServerScriptService.PlayerManager)
local InsertProductIdBindableEvent = ServerScriptService.InsertProductIdBindable
local ProductIdsOwnedChangedEvent = ReplicatedStorage.Events.ProductIdsOwnedChanged
local GetOwnedProductIdsBindableFn = ServerScriptService.GetOwnedProductIdsBindable

local CharacterFolder = ReplicatedStorage.Characters

local Players = game:GetService("Players")


-- Table setup containing product IDs and functions for handling purchases
local productFunctions = {}

-- Product types
local PRODUCT_TYPES = {
  ["Avatar"] = 1,
}

-- List of product IDs by type
local avatarProductIds = {}

-- Initialize avatarProductIds
for _, subdir in pairs(CharacterFolder:GetChildren()) do
  for __, characterModel in pairs(subdir:GetChildren()) do
    local productId = characterModel:GetAttribute(Avatars.PRODUCT_ID_ATTR_NAME)
    if productId then
      table.insert(avatarProductIds, productId)
    end
  end
end


local function getProductType(productId)
  if Util:Contains(avatarProductIds, productId) then
    return PRODUCT_TYPES.Avatar
  end
end


productFunctions[PRODUCT_TYPES.Avatar] = function(receipt, player)
  if player then
    InsertProductIdBindableEvent:Fire(player, receipt.ProductId)
    local productsOwned = GetOwnedProductIdsBindableFn:Invoke(player)
    if productsOwned then
      ProductIdsOwnedChangedEvent:FireClient(player, productsOwned)
    end
    return true
  end
end


-- The core 'ProcessReceipt' callback function
local function processReceipt(receiptInfo)

  local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
  if not player then
    -- The callback should be called again
    return Enum.ProductPurchaseDecision.NotProcessedYet
  end

  -- Data store for tracking the last purchase that was successfully processed
  -- Determine if the product was already granted by checking the data store
  -- If purchase was recorded, the product was already granted

  -- Find the player who made the purchase in the server
  player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
  if not player then
    -- The player probably left the game
    -- If they come back, the callback will be called again
    return Enum.ProductPurchaseDecision.NotProcessedYet
  end

  local productType = getProductType(receiptInfo.ProductId)
  -- Look up handler function from 'productFunctions' table above
  local handler = productFunctions[productType]

  if handler then
    -- Call the handler function and catch any errors
    local success, result = pcall(handler, receiptInfo, player)
    if not success or not result then
      warn("Error occurred while processing a product purchase")
      print("\nProductId:", receiptInfo.ProductId)
      print("\nPlayer:", player)
      return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    -- Record transaction in data store so it isn't granted again

    -- IMPORTANT: Tell Roblox that the game successfully handled the purchase
    return Enum.ProductPurchaseDecision.PurchaseGranted
  end
end

-- Set the callback; this can only be done once by one script on the server! 
MarketplaceService.ProcessReceipt = processReceipt

