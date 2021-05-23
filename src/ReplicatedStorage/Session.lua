-- Game session

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)

local Session = {}
Session.__index = Session

Session.DEFAULT_TIME_PER_SESSION_SEC = 60 * 2


function Session.new()
  local self = {}
  setmetatable(self, Session)

  self.Score = 0
  self.StartTime = 0
  self.Duration = Session.DEFAULT_TIME_PER_SESSION_SEC

  return self
end

function Session:GetScore()
  return self.Score
end

function Session:IncrementScore(count)
  self.Score += count
end

function Session:SetScore(newScore)
  self.Score = newScore
end

function Session:Start()
  self.StartTime = os.time()
end

function Session:GetStartTime()
  return self.StartTime
end

function Session:SetStartTime(startTime)
  self.StartTime = startTime
end

function Session:GetDuration()
  return self.Duration
end

function Session:SetDuration(duration)
  self.Duration = duration
end

function Session:GetElapsedTime()
  return os.time() - self:GetStartTime()
end

function Session:GetRemainingTime()
  return self:GetDuration() - self:GetElapsedTime()
end

function Session:IsDone()
  if self:GetElapsedTime() > self:GetDuration() then
    return true
  else
    return false
  end
end

return Session
