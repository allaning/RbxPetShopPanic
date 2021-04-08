local Factory = require(script.Parent.Factory)
local CarrotSeedFactory = setmetatable({}, {__index = Factory})
CarrotSeedFactory.__index = CarrotSeedFactory

function CarrotSeedFactory.new(model)
  local self = setmetatable(Factory.new(), CarrotSeedFactory)

  self.SpawnTimeSec = 2.0

  self.Model = model

  return self
end

function CarrotSeedFactory:SetModel(model)
  self.Model = model
end

return CarrotSeedFactory
