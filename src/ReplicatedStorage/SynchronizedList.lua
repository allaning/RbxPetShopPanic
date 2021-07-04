-- Synchronized list

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)


local SynchronizedList = {}
SynchronizedList.__index = SynchronizedList


function SynchronizedList.new()
  local self = {}
  setmetatable(self, SynchronizedList)

  self.list = {}

  self.LOCKED = false

  return self
end

function SynchronizedList:GetLock()
  while self:LOCKED do
    Util:RealWait(0.1)
  end
  self:LOCKED = true
end

function SynchronizedList:Free()
  self:LOCKED = false
end

function SynchronizedList:Insert(item)
  SynchronizedList:GetLock()
  table.insert(self:list, item)
  SynchronizedList:Free()
end

function SynchronizedList:Cleanup()
  self:list = nil
end


return SynchronizedList
