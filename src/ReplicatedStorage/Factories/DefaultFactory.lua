local Factory = require(script.Parent.Factory)
local DefaultFactory = setmetatable({}, {__index = Factory})
DefaultFactory.__index = DefaultFactory

function DefaultFactory.new(model)
  local self = setmetatable(Factory.new(), DefaultFactory)

  self.spawnTimeSec = 5.0

  self.itsModel = model

  return self
end

return DefaultFactory
