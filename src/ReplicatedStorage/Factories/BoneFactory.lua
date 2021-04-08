local Factory = require(script.Parent.Factory)
local BoneFactory = setmetatable({}, {__index = Factory})
BoneFactory.__index = BoneFactory

function BoneFactory.new(model)
  local self = setmetatable(Factory.new(), BoneFactory)

  self.SpawnTimeSec = 5.0

  self.Model = model

  return self
end

function BoneFactory:SetModel(model)
  self.Model = model
end

return BoneFactory
