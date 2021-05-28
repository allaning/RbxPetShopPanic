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
  self.PointsInstance = nil
  self.IsInGameSession = false

  self.Points = 0

  return self
end

function PlayerManager:GetPlayer()
  return self.Player
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

function PlayerManager:GetIsInGameSession()
  return self.IsInGameSession
end

function PlayerManager:SetIsInGameSession(isInGameSession)
  self.IsInGameSession = isInGameSession
end

function PlayerManager:IncrementPoints(points)
  self.Points += points

  if self.PointsInstance then
    self.PointsInstance.Value += points
  else
    error("PlayerManager:IncrementPoints: self.PointsInstance not initialized")
  end
end


return PlayerManager

