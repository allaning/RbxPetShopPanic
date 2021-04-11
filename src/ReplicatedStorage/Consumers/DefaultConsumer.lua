local Consumer = require(script.Parent.Consumer)
local DefaultConsumer = setmetatable({}, {__index = Consumer})
DefaultConsumer.__index = DefaultConsumer

function DefaultConsumer.new(model)
  local self = setmetatable(Consumer.new(), DefaultConsumer)

  self.itsModel = model

  return self
end

return DefaultConsumer
