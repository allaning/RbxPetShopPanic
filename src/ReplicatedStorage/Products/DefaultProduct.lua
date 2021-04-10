local Product = require(script.Parent.Product)
local DefaultProduct = setmetatable({}, {__index = Product})
DefaultProduct.__index = DefaultProduct

function DefaultProduct.new(model)
  local self = setmetatable(Product.new(), DefaultProduct)

  self.Model = model

  return self
end

return DefaultProduct
