-- Game session

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local ServerScriptService = game:GetService("ServerScriptService")

local Session = {}
Session.__index = Session


-- Default game session length
Session.DEFAULT_TIME_PER_SESSION_SEC = 60 * 2

-- Delay that occurs when game session ends
Session.POST_GAME_COOLDOWN_PERIOD_SEC = 2


function Session.new()
  local self = {}
  setmetatable(self, Session)

  self.Score = 0  -- This is the running score for current session (versus points, e.g. stars, earned at end of session)
  self.StartTime = 0
  self.Duration = Session.DEFAULT_TIME_PER_SESSION_SEC
  self.IsActive = false

  self.NumCompleted = 0  -- Number of consumers successfully completed
  self.NumMissed = 0  -- Number of requests missed (wrong item given or request timed out)
  self.NumTotal = 0  -- Number of total requests made

  self.PlayerList = {}  -- List of Players (instances, not names) that participated in the session

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
  self:SetIsActive(true)
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

function Session:GetIsActive()
  return self.IsActive
end

function Session:SetIsActive(isActive)
  self.IsActive = isActive
end

function Session:GetNumCompleted()
  return self.NumCompleted
end

function Session:IncrementNumCompleted()
  print("self.NumCompleted += 1 --> ".. tostring(self.NumCompleted))
  self.NumCompleted += 1
end

function Session:GetNumMissed()
  return self.NumMissed
end

function Session:IncrementNumMissed()
  print("self.NumMissed += 1")
  self.NumMissed += 1
end

function Session:GetPlayerList()
  return self.PlayerList
end

function Session:SetPlayerList(playerList)
  self.PlayerList = playerList
end

function Session:GetNumTotal()
  return self.NumTotal
end

function Session:IncrementNumTotal()
  print("self.NumTotal += 1 --> ".. tostring(self.NumTotal))
  self.NumTotal += 1
end

function Session:GetElapsedTime()
  return os.time() - self:GetStartTime()
end

function Session:GetRemainingTime()
  return self:GetDuration() - self:GetElapsedTime()
end

function Session:IsDone()
  if self:GetElapsedTime() > self:GetDuration() then
    self:SetIsActive(false)
    return true
  else
    return false
  end
end

function Session:GetPointsEarned(handicap)
  -- Handicap is because we assume current consumer requests couldn't be fulfilled before time expired
  local handicap = handicap or 0
  local effectiveTotalRequests = self:GetNumTotal() - handicap
  if effectiveTotalRequests == 0 then
    effectiveTotalRequests = 1  -- Avoid div by zero
  end
  local percentComplete = self:GetNumCompleted() / effectiveTotalRequests * 100
  print("effectiveTotalRequests=".. tostring(effectiveTotalRequests).. "; self:GetNumCompleted()=".. tostring(self:GetNumCompleted()).. "; percentComplete=".. tostring(percentComplete))

  local points = 0
  if percentComplete >= 90 then
    points = 3
  elseif percentComplete >= 70 then
    points = 2
  elseif percentComplete >= 30 then
    points = 1
  end
  return points
end


return Session

