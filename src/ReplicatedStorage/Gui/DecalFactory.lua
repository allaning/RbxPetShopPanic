-- Creates and returns decals

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)


local DecalFactory = {}


DecalFactory.CONSUMER_RECEIVED_NIL_DECAL = "http://www.roblox.com/asset/?id=15637705" -- https://www.roblox.com/catalog/15637848/unnamed
DecalFactory.CONSUMER_RECEIVED_CORRECT_INPUT_DECAL = "http://www.roblox.com/asset/?id=209713384" -- https://www.roblox.com/catalog/209995366/Joyful-Smile
DecalFactory.CONSUMER_RECEIVED_INCORRECT_INPUT_DECAL = "http://www.roblox.com/asset/?id=8560912" -- https://www.roblox.com/catalog/8560975/Anguished


-- Returns Frame containing image of asset
function DecalFactory.GetImage(assetId)
  if assetId then
    local decal = Util:CreateInstance("Decal", {
        Texture = assetId,
      }, nil)

    return decal
  else
    error("Input asset id is nil; Unable to create image")
  end
end


return DecalFactory
