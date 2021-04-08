-- This is the abstract root Factory class 

local Factory = {}
Factory.__index = Factory


function Factory.new()
  local self = {}
  setmetatable(self, Factory)

  self.SpawnTimeSec = 0.0

  self.Model = nil

  return self
end

function Factory:GetName()
  return self.Model.Name
end

function Factory:GetModel()
  return self.Model
end

function Factory:GetSpawnTimeSec()
  return self.SpawnTimeSec
end


return Factory
