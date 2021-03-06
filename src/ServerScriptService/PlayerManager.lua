local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ReplicatedStorage.Globals)

local ServerScriptService = game:GetService("ServerScriptService")
local DatabaseAdapter = require(ServerScriptService.DatabaseAdapter)

local Players = game:GetService("Players")


local PlayerManager = {}
PlayerManager.__index = PlayerManager


-- Example format for self.EquippedItems
local DEFAULT_EQUIPPED_ITEMS = {
  ['Character'] = {
    ['Name'] = "",
  },
  ['ShoulderPet'] = {
    ['Name'] = "",
    ['IsNeon'] = false,
  },
  ['PetBoost'] = {
    ['Name'] = "",
  },
}


function PlayerManager.new(player)
  local self = {}
  setmetatable(self, PlayerManager)

  -- Reference to this instance's player
  self.Player = player
  self.PlayerName = player.Name

  -- Leaderstats
  self.LeaderstatsFolder = nil
  self.PointsInstance = nil  -- Leaderstats points (versus per session points)

  -- Session info
  self.IsInGameSession = false
  self.SessionScore = 0  -- Per session score for this player
  self.SessionAssists = 0  -- Per session transformations made for this player


  -- Database

  -- Cached Points; When changing Points, also update PointsInstance
  self.Points = 0

  -- Cached list of Marketplace Product IDs owned
  -- Format: { 123, 456 }
  self.ProductIdsOwned = {}

  -- Cached table of equipped items
  self.EquippedItems = {}

  return self
end

function PlayerManager:GetPlayer()
  return self.Player
end

function PlayerManager:GetPlayerName()
  return self.PlayerName
end

function PlayerManager:Initialize()
  if self.Player then
    local player = self.Player
    -- Setup leaderboard
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    self.LeaderstatsFolder = leaderstats

    -- Points
    self.Points = DatabaseAdapter.GetPoints(player)
    local pointsInstance = Instance.new("IntValue")
    pointsInstance.Name = Globals.LEADERBOARD_POINTS_NAME  -- Name of the in-game leaderboard stat
    pointsInstance.Value = self.Points
    pointsInstance.Parent = leaderstats
    self.PointsInstance = pointsInstance

    -- Product IDs Owned
    self.ProductIdsOwned = DatabaseAdapter.GetProductIdsOwned(player)
    --table.insert(self.ProductIdsOwned, 1178916298)  -- testing Fox
    --table.insert(self.ProductIdsOwned, 1178952971)  -- testing Bear
    --table.insert(self.ProductIdsOwned, 1178968280)  -- testing Monkey
    --table.insert(self.ProductIdsOwned, 1180009943)  -- testing Draconis

    -- Equipped items
    self.EquippedItems = DatabaseAdapter.GetEquippedItems(player)
    if #self.EquippedItems == 0 then
      -- Use default table
      if self.EquippedItems['Character'] == nil then
        self.EquippedItems['Character'] = {}
        self.EquippedItems['Character']['Name'] = ""
      end
      if self.EquippedItems['ShoulderPet'] == nil then
        self.EquippedItems['ShoulderPet'] = {}
        self.EquippedItems['ShoulderPet']['Name'] = ""
        self.EquippedItems['ShoulderPet']['IsNeon'] = false
      end
    end

  else
    error("Cannot InitializePlayer because self.Player is not set")
  end
end


-- Points

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

  DatabaseAdapter.SetPoints(self.Player, points)
end

function PlayerManager:IncrementPoints(points)
  self.Points += points

  if self.PointsInstance then
    self.PointsInstance.Value += points
  else
    error("PlayerManager:IncrementPoints: self.PointsInstance not initialized")
  end

  DatabaseAdapter.IncrementPoints(self.Player, points)
  print("In PlayerManager:IncrementPoints(points ".. points.." ) self.Points=".. self.Points)
end


-- ProductIdsOwned

function PlayerManager:GetProductIdsOwned()
  return self.ProductIdsOwned
end

function PlayerManager:SetProductIdsOwned(productIdsOwnedList)
  self.ProductIdsOwned = productIdsOwnedList
  DatabaseAdapter.SetProductIdsOwned(self.Player, productIdsOwnedList)
end

function PlayerManager:InsertProductIdOwned(productIdOwned)
  table.insert(self.ProductIdsOwned, productIdOwned)
  DatabaseAdapter.SetProductIdsOwned(self.Player, self.ProductIdsOwned)
end


-- EquippedItems

-- Returns the whole EquippedItems table
function PlayerManager:GetEquippedItems()
  return self.EquippedItems
end

-- Sets the whole EquippedItems table
function PlayerManager:SetEquippedItems(equippedItemsList)
  self.EquippedItems = equippedItemsList
  DatabaseAdapter.SetEquippedItems(self.Player, equippedItemsList)
end

-- Save EquippedItems to data store
function PlayerManager:SaveEquippedItems()
  DatabaseAdapter.SetEquippedItems(self.Player, self.EquippedItems)
end

function PlayerManager:GetEquippedCharacterName()
  return self.EquippedItems['Character']['Name']
end

function PlayerManager:GetEquippedShoulderPetName()
  return self.EquippedItems['ShoulderPet']['Name']
end


-- Other attributes

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
-- NOTE: Only use getters here, not setters; Users of BindableFunction get a copy of object

-- Get PlayerManager for specified Player.Name
function PlayerManager.GetPlayerManagerFromList(playerManagers, playerName)
  for _, plrMgr in pairs(playerManagers) do
    if plrMgr:GetPlayerName() == playerName then
      return plrMgr
    end
  end
end

function PlayerManager.SetEquippedCharacterName(playerManagers, player, charName)
  local plrMgr = PlayerManager.GetPlayerManagerFromList(playerManagers, player.Name)
  if plrMgr then
    plrMgr.EquippedItems['Character']['Name'] = charName
    plrMgr:SaveEquippedItems()
    print("Saving player Character name: ".. plrMgr:GetPlayerName().. " as ".. charName)
  end
end

function PlayerManager.SetEquippedShoulderPetName(playerManagers, player, shoulderPetName)
  local plrMgr = PlayerManager.GetPlayerManagerFromList(playerManagers, player.Name)
  if plrMgr then
    plrMgr.EquippedItems['ShoulderPet']['Name'] = shoulderPetName
    plrMgr:SaveEquippedItems()
    print("Saving player ShoulderPet name: ".. plrMgr:GetPlayerName().. " as ".. shoulderPetName)
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

function PlayerManager.GetPointsForPlayerFromPlayerManager(playerManager)
  return playerManager.Points
end

function PlayerManager.GetProductIdsOwnedForPlayer(playerManager)
  return playerManager.ProductIdsOwned
end

function PlayerManager.DoesPlayerOwnProductId(playerManager, productId)
  for _, id in ipairs(playerManager.ProductIdsOwned) do
    if tonumber(id) == tonumber(productId) then
      return true
    end
  end
end


return PlayerManager

