-- Creates and returns decals

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)


local DecalFactory = {}


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
