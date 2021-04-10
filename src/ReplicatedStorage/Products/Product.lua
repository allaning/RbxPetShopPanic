local Product = {}
Product.__index = Product


function Product.new()
  local self = {}
  setmetatable(self, Product)

  self.Model = nil

  return self
end

function Product:GetName()
  if self.Model then
    return self.Model.Name
  end
end

function Product:GetModel()
  return self.Model
end

function Product:SetProximityPrompt(model)
  local attachment = Instance.new("Attachment", model)
  attachment.Name = "PromptAttachment"
  attachment.Position = Vector3.new(0, 4, 0)
  local prompt = Instance.new("ProximityPrompt", attachment)
  prompt.Name = self:GetName()
  prompt.ObjectText = self:GetName()
  prompt.ActionText = "Pick Up"
  prompt.MaxActivationDistance = 5
end

function Product:GetModelClone()
  if self:GetModel() then
    local clone = self:GetModel():Clone()
    self:SetProximityPrompt(clone)
    return clone
  end
end

function Product:SetModel(model)
  self.Model = model
end


return Product
