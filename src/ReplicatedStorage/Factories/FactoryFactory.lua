-- This is a Factory factory

local Factory = require(script.Parent.Factory)
local BoneFactory = require(script.Parent.BoneFactory)
local CarrotSeedFactory = require(script.Parent.CarrotSeedFactory)


local FactoryFactory = {}


-- TODO: Add each factory here
function FactoryFactory.GetFactory(factoryName)
  if factoryName == "Bone" then
    return BoneFactory.new()
  elseif factoryName == "CarrotSeed" then
    return CarrotSeedFactory.new()
  end
  error(script.Name..": Invalid Factory name: ".. factoryName)
end


return FactoryFactory
