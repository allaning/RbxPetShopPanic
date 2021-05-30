-- Game session

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local ServerScriptService = game:GetService("ServerScriptService")

local Session = {}
Session.__index = Session


-- Default game session length
Session.DEFAULT_TIME_PER_SESSION_SEC = 60 * 3

-- Delay that occurs when game session ends
Session.POST_GAME_COOLDOWN_PERIOD_SEC = 2


function Session.new()
  local self = {}
  setmetatable(self, Session)

  self.Score = 0  -- This is the running score for current session (versus points, e.g. stars, earned at end of session)
  self.StartTime = 0
  self.Duration = 18--aing Session.DEFAULT_TIME_PER_SESSION_SEC
  self.IsActive = false
  self.Level = 0  -- Difficulty level

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

function Session:GetLevel()
  return self.Level
end

function Session:SetLevel(level)
  self.Level = level
end

function Session:GetNumCompleted()
  return self.NumCompleted
end

function Session:IncrementNumCompleted()
  self.NumCompleted += 1
  --print("self.NumCompleted += 1 --> ".. tostring(self.NumCompleted))
end

function Session:GetNumMissed()
  return self.NumMissed
end

function Session:IncrementNumMissed()
  self.NumMissed += 1
  --print("self.NumMissed += 1")
end

function Session:GetPlayerList()
  return self.PlayerList
end

function Session:SetPlayerList(playerList)
  self.PlayerList = playerList
end

function Session:RemoveFromPlayerList(playerName)
  for idx = #self.PlayerList, 1, -1 do
    if self.PlayerList[idx].Name == playerName then
      table.remove(self.PlayerList, idx)
      break
    end
  end
end

function Session:GetNumTotal()
  return self.NumTotal
end

function Session:IncrementNumTotal()
  self.NumTotal += 1
  --print("self.NumTotal += 1 --> ".. tostring(self.NumTotal))
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

function Session:GetStats(handicap)
  -- Handicap is because we assume current consumer requests couldn't be fulfilled before time expired
  local handicap = handicap or 0
  local numTotalRequests = self:GetNumTotal()
  local numCompleted = self:GetNumCompleted()

  local effectiveTotalRequests = numTotalRequests - handicap
  if effectiveTotalRequests <= 0 then
    effectiveTotalRequests = 1  -- Avoid div by zero
  end
  if effectiveTotalRequests < numCompleted then
    effectiveTotalRequests = numCompleted  -- Make sure total is higher
  end

  local percentComplete = numCompleted / effectiveTotalRequests * 100
  print("effectiveTotalRequests=".. tostring(effectiveTotalRequests).. "; self:GetNumCompleted()=".. tostring(self:GetNumCompleted()).. "; percentComplete=".. tostring(percentComplete))

  local points = 0
  if percentComplete >= 85 then
    points = 3
  elseif percentComplete >= 60 then
    points = 2
  elseif percentComplete >= 30 then
    points = 1
  end

  local numFailed = self:GetNumMissed()
  return points, effectiveTotalRequests, numCompleted, numFailed
end


return Session

