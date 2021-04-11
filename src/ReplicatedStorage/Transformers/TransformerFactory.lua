-- This is a Transformer factory

local Transformer = require(script.Parent.Transformer)
local DefaultTransformer = require(script.Parent.DefaultTransformer)


local TransformerFactory = {}


function TransformerFactory.GetTransformer(transformerName)
  print("Creating Transformer: ".. transformerName)
  local newTransformer = nil

  -- If a custom class is needed, then check for it and create it here
  if true then  -- Replace "true" with if-condition when custom classes are needed
    newTransformer = DefaultTransformer.new()
  end

  return newTransformer
end


return TransformerFactory
