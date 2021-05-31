-- Datastore adapter

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ReplicatedStorage.Globals)

local ServerScriptService = game:GetService("ServerScriptService")
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)


-- DataStore names
local DB_POINTS_STORE = "Points"


local DatabaseAdapter = {}


-- Call this once at the start of the server instance
function DatabaseAdapter.Initialize()
  -- Combine every key
  if Globals.USE_REAL_DATABASE then
    DataStore2.Combine(Globals.DATA_STORE_NAME, DB_POINTS_STORE)
  end
end


function DatabaseAdapter.GetPoints(player)
  if Globals.USE_REAL_DATABASE then
    local pointsStore = DataStore2(DB_POINTS_STORE, player)
    return pointsStore:Get(0)
  else
    return 0
  end
end

function DatabaseAdapter.SetPoints(player, points)
  if Globals.USE_REAL_DATABASE then
    local pointsStore = DataStore2(DB_POINTS_STORE, player)
    pointsStore:Set(points)
  end
end

function DatabaseAdapter.IncrementPoints(player, increment)
  if Globals.USE_REAL_DATABASE then
    local pointsStore = DataStore2(DB_POINTS_STORE, player)
    pointsStore:Increment(increment)
  end
end


return DatabaseAdapter

