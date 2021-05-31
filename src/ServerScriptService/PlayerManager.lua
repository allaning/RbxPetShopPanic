local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ReplicatedStorage.Globals)

local Players = game:GetService("Players")


local PlayerManager = {}
PlayerManager.__index = PlayerManager


function PlayerManager.new(player)
  local self = {}
  setmetatable(self, PlayerManager)

  -- Reference to this instance's player
  self.Player = player
  self.PlayerName = player.Name

  self.LeaderstatsFolder = nil
  self.PointsInstance = nil  -- Leaderstats points (versus per session points)

  self.Points = 0  -- Cached Points; When changing Points, also update PointsInstance

  self.IsInGameSession = false
  self.SessionScore = 0  -- Per session score for this player
  self.SessionAssists = 0  -- Per session transformations made for this player

  return self
end

function PlayerManager:GetPlayer()
  return self.Player
end

function PlayerManager:GetPlayerName()
  return self.PlayerName
end

-- Create leaderstats for Player
function PlayerManager:InitializeLeaderstats()
  if self.Player then
    -- Setup leaderboard
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = self.Player
    self.LeaderstatsFolder = leaderstats

    -- Points
    local pointsInstance = Instance.new("IntValue")
    pointsInstance.Name = Globals.LEADERBOARD_POINTS_NAME  -- Name of the in-game leaderboard stat
    pointsInstance.Value = 0
    pointsInstance.Parent = leaderstats
    self.PointsInstance = pointsInstance
  else
    error("Cannot InitializePlayer because self.Player is not set")
  end
end

function PlayerManager:GetPoints()
  return self.Points
end

function PlayerManager:SetPoints(points)
  self.Points = points

  if self.PointsInstance then
    self.PointsInstance.Value = points
  else
    error("PlayerManager:SetPoints: self.PointsInstance not initialized")
  end
end

function PlayerManager:IncrementPoints(points)
  self.Points += points

  if self.PointsInstance then
    self.PointsInstance.Value += points
  else
    error("PlayerManager:IncrementPoints: self.PointsInstance not initialized")
  end
end

function PlayerManager:GetIsInGameSession()
  return self.IsInGameSession
end

function PlayerManager:SetIsInGameSession(isInGameSession)
  self.IsInGameSession = isInGameSession
end

function PlayerManager:GetSessionScore()
  return self.SessionScore
end

function PlayerManager:SetSessionScore(sessionScore)
  self.SessionScore = sessionScore
end

function PlayerManager:IncrementSessionScore(increment)
  local incr = increment or 1
  self.SessionScore += incr
end

function PlayerManager:GetSessionAssists()
  return self.SessionAssists
end

function PlayerManager:SetSessionAssists(sessionAssists)
  self.SessionAssists = sessionAssists
end

function PlayerManager:IncrementSessionAssists(increment)
  local incr = increment or 1
  self.SessionAssists += incr
end


-- Helper functions, since can't pass operations via BindableFunction

-- Get PlayerManager for specified Player.Name
function PlayerManager.GetPlayerManagerFromList(playerManagers, playerName)
  for _, plrMgr in pairs(playerManagers) do
    if plrMgr:GetPlayerName() == playerName then
      return plrMgr
    end
  end
end

-- Get player with highest score and assists
function PlayerManager.GetPlayersWithBestScoreAndAssists(playerManagers)
  local playerWithBestScore = nil
  local playerWithBestAssists = nil
  local bestScore = 0
  local bestAssists = 0
  for _, plrMgr in pairs(playerManagers) do
    if plrMgr:GetSessionScore() > bestScore then
      bestScore = plrMgr:GetSessionScore()
      playerWithBestScore = plrMgr:GetPlayer()
    end
    if plrMgr:GetSessionAssists() > bestAssists then
      bestAssists = plrMgr:GetSessionAssists()
      playerWithBestAssists = plrMgr:GetPlayer()
    end
  end
  return playerWithBestScore, playerWithBestAssists
end

function PlayerManager.GetPoints(playerManager)
  return playerManager.Points
end


return PlayerManager

