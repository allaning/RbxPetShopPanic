local Consumer = require(script.Parent.Consumer)
local DefaultConsumer = setmetatable({}, {__index = Consumer})
DefaultConsumer.__index = DefaultConsumer

function DefaultConsumer.new(difficultyLevel)
  local self = setmetatable(Consumer.new(), DefaultConsumer)

  self.difficultyLevel = difficultyLevel

  return self
end

return DefaultConsumer
