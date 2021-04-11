local Transformer = require(script.Parent.Transformer)
local DefaultTransformer = setmetatable({}, {__index = Transformer})
DefaultTransformer.__index = DefaultTransformer

function DefaultTransformer.new(model)
  local self = setmetatable(Transformer.new(), DefaultTransformer)

  self.itsModel = model

  return self
end

return DefaultTransformer
