local Product = require(script.Parent.Product)
local DefaultProduct = require(script.Parent.DefaultProduct)


local ProductFactory = {}


function ProductFactory.GetProduct(productName, itsModel)
  print("Creating Product: ".. productName)
  local newProduct = nil

  -- If a custom class is needed, then check for it and create it here
  if true then  -- Replace "true" with if-condition when custom classes are needed
    newProduct = DefaultProduct.new()
  end

  if itsModel then
    newProduct:SetModel(itsModel:Clone())
  end

  return newProduct
end


return ProductFactory
