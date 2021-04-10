-- This is a Factory factory

local Factory = require(script.Parent.Factory)
local DefaultFactory = require(script.Parent.DefaultFactory)


local FactoryFactory = {}


function FactoryFactory.GetFactory(factoryName, spawnDelaySec)
  print("Creating Factory: ".. factoryName.. ", spawnDelaySec=".. tostring(spawnDelaySec))
  local newFactory = nil

  -- If a custom class is needed, then check for it and create it here
  if true then  -- Replace "true" with if-condition when custom classes are needed
    newFactory = DefaultFactory.new()
  end

  if spawnDelaySec then
    newFactory:SetSpawnTimeSec(spawnDelaySec)
  end

  return newFactory
end


return FactoryFactory
