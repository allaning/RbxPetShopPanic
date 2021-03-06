-- This is a Consumer factory

local Consumer = require(script.Parent.Consumer)
local DefaultConsumer = require(script.Parent.DefaultConsumer)


local ConsumerFactory = {}


function ConsumerFactory.GetConsumer(consumerName, inputStr, difficultyLevel)
  print("Creating Consumer: ".. consumerName.. "; Input=".. inputStr)
  local newConsumer = nil

  -- If a custom class is needed, then check for it and create it here
  if true then  -- Replace "true" with if-condition when custom classes are needed
    newConsumer = DefaultConsumer.new(difficultyLevel)
  end

  newConsumer:SetName(consumerName)
  newConsumer:SetInput(inputStr)

  return newConsumer
end


return ConsumerFactory
