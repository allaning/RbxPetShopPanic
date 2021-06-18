-- Console utilities
-- Paste the following lines into the shell to include modules
-- ServerScriptService = game:GetService("ServerScriptService"); Cmd = require(ServerScriptService.Cmd)


local DataStoreService = game:GetService("DataStoreService")


-- See above for instructions on including this module
local Cmd = {}


local DATA_STORE_NAME = "DATA00"


--
-- Commands for players that are NOT IN GAME
--

local function showOrderedDataPage(theData)
  print("a:".. tostring(theData))
  for __, col in pairs(theData) do
    print("  b:"..tostring(__))
    if type(theData[__]) == "table" then
      local c = ""
      for ___, spec in pairs(theData[__]) do
        if type(spec) == "number" then
          c = c..tostring(___)..":"..tostring(spec)..", "
        elseif type(spec) == "table" then
          c = c.. "  ['".. tostring(___).. "'] = "
          for ____, item in pairs(spec) do
            c = c..tostring(____).."="..tostring(item)..", "
          end
        end
      end
      print("    c: "..tostring(c))
    else
      print("    c: "..tostring(theData[__]))
    end
  end
end

-- View latest data
-- Usage: Cmd.ShowLatestData(500841057) -- WhoooDattt
-- Usage: Cmd.ShowLatestData(559009867) -- pinksheep20212
function Cmd.ShowLatestData(userId)
  local orderedDataStore = DataStoreService:GetOrderedDataStore(DATA_STORE_NAME .. "/" .. userId)
  local playerData = DataStoreService:GetDataStore(DATA_STORE_NAME.."/"..userId)
  if playerData then
    local pages = orderedDataStore:GetSortedAsync(false, 100)
    local pageData = pages:GetCurrentPage()
    for _, pair in pairs(pageData) do
      print(("key: %d, value: %s"):format(pair.key, type(pair.value)))
      local theData = playerData:GetAsync(pair.key)
      if theData then
        showOrderedDataPage(theData)
        break
      end
    end
    print(("Finished (%d: %s)"):format(userId, DATA_STORE_NAME))
  else
    warn("Error getting data")
  end
end


-- View previous ordered data
-- Usage: Cmd.ShowHistory(500841057) -- WhoooDattt
-- Usage: Cmd.ShowHistory(602483247, 12) -- CuteFaceAlert
function Cmd.ShowHistory(userId, numRecords)
  local MAX_HISTORY_INSTANCES = 5
  if not numRecords then
    numRecords = MAX_HISTORY_INSTANCES
  end
  local orderedDataStore = DataStoreService:GetOrderedDataStore(DATA_STORE_NAME .. "/" .. userId)
  local playerData = DataStoreService:GetDataStore(DATA_STORE_NAME.."/"..userId)
  if playerData then
    local iter = 0
    while true do
      local pages = orderedDataStore:GetSortedAsync(false, 100)
      local pageData = pages:GetCurrentPage()
      for _, pair in pairs(pageData) do
        print(("key: %d, value: %s"):format(pair.key, type(pair.value)))
        local theData = playerData:GetAsync(pair.key)
        if theData then
          showOrderedDataPage(theData)
          iter = iter + 1
          if iter >= numRecords then
            print("Returning after ".. tostring(numRecords).." records.")
            return
          end
        end
      end
      if pages.IsFinished then
        print(("Finished (%d: %s)"):format(userId, DATA_STORE_NAME))
        return
      end
    end
  else
    warn("Error getting data")
  end
end


-- Add item
-- Usage: Cmd.AddItem(500841057, "ProductIdsOwned", 0x123) -- WhoooDattt, 2x Cash
function Cmd.AddItem(userId, collectionType, itemId)
  if not userId or not collectionType or not itemId then
    warn("ERROR: Missing arg")
    return
  end
  local DataStoreService = game:GetService("DataStoreService")
  local orderedDataStore = DataStoreService:GetOrderedDataStore(DATA_STORE_NAME .. "/" .. userId)
  local playerData = DataStoreService:GetDataStore(DATA_STORE_NAME.."/"..userId)
  if playerData then
    local pages = orderedDataStore:GetSortedAsync(false, 100)
    local data = pages:GetCurrentPage()
    for _, pair in pairs(data) do
      print(("key: %d, value: %s"):format(pair.key, type(pair.value)))
      local collection = playerData:GetAsync(pair.key)
      if collection then
        print("a:".. tostring(collection))
        for __, col in pairs(collection) do
          print("  b:"..tostring(__))
          if __ == collectionType then
            if type(collection[__]) == "table" then
              table.insert(collection[__], itemId)
              playerData:SetAsync(pair.key, collection)
              break
            end
          end
        end
      end
      break
    end
    print(("Finished (%d: %s)"):format(userId, DATA_STORE_NAME))
  else
    warn("Error getting data")
  end
end


-- Set value, e.g. Money or RebirthCount
-- Usage: Cmd.SetValue(500841057, "Points", 500) -- WhoooDattt
function Cmd.SetValue(userId, collectionType, newValue)
  if not userId or not collectionType or not newValue then
    warn("ERROR: Missing arg")
    return
  end
  local orderedDataStore = DataStoreService:GetOrderedDataStore(DATA_STORE_NAME .. "/" .. userId)
  local playerData = DataStoreService:GetDataStore(DATA_STORE_NAME.."/"..userId)
  if playerData then
    local pages = orderedDataStore:GetSortedAsync(false, 100)
    local data = pages:GetCurrentPage()
    for _, pair in pairs(data) do
      print(("key: %d, value: %s"):format(pair.key, type(pair.value)))
      local collection = playerData:GetAsync(pair.key)
      if collection then
        print("a:".. tostring(collection))
        for __, col in pairs(collection) do
          print("  b:"..tostring(__))
          if __ == collectionType then
            print("    OLD c:"..tostring(collection[__]))
            collection[__] = newValue
            print("    NEW c:"..tostring(collection[__]))
            playerData:SetAsync(pair.key, collection)
            break
          end
        end
      end
      break
    end
    print(("Finished (%d: %s)"):format(userId, DATA_STORE_NAME))
  else
    warn("Error getting data")
  end
end


-- Remove item
-- Usage: Cmd.RemoveItem(500841057, "ProductIdsOwned", 0x123) -- WhoooDattt, 2x Cash
function Cmd.RemoveItem(userId, collectionType, itemId)
  local orderedDataStore = DataStoreService:GetOrderedDataStore(DATA_STORE_NAME .. "/" .. userId)
  local playerData = DataStoreService:GetDataStore(DATA_STORE_NAME.."/"..userId)
  if playerData then
    local pages = orderedDataStore:GetSortedAsync(false, 100)
    local data = pages:GetCurrentPage()
    for _, pair in pairs(data) do
      print(("key: %d, value: %s"):format(pair.key, type(pair.value)))
      local collection = playerData:GetAsync(pair.key)
      if collection then
        print("a:".. tostring(collection))
        for __, col in pairs(collection) do
          print("  b:"..tostring(__))
          if __ == collectionType then
            if type(collection[__]) == "table" then
              local c = ""
              for i = #collection[__], 1, -1 do
                c = c..tostring(collection[__][i])..", "
                if collection[__][i] == itemId then
                  c = c..", ["..tostring(collection[__][i]).."], "
                  table.remove(collection[__], i)
                  playerData:SetAsync(pair.key, collection)
                  break
                end
              end
              print("    c:"..tostring(c))
            end
          end
        end
      end
      break
    end
    print(("Finished (%d: %s)"):format(userId, DATA_STORE_NAME))
  else
    warn("Error getting data")
  end
end


-- Restore data from an older key (view history to find last good key)
-- Usage: Cmd.RestoreFromKey(500841057, 3)  -- Revert Whooodattt's data back to key 36
function Cmd.RestoreFromKey(userId, keyNum)
  local MAX_HISTORY_INSTANCES = 15
  local numRecords = MAX_HISTORY_INSTANCES
  local orderedDataStore = DataStoreService:GetOrderedDataStore(DATA_STORE_NAME .. "/" .. userId)
  local playerData = DataStoreService:GetDataStore(DATA_STORE_NAME.."/"..userId)
  if playerData then
    local firstKey
    local iter = 0
    while true do
      local pages = orderedDataStore:GetSortedAsync(false, 100)
      local data = pages:GetCurrentPage()
      for _, pair in pairs(data) do
        if iter == 0 then
          firstKey = tonumber(pair.key)
          print("First key: ".. tostring(firstKey).. "; type=".. type(pair.key))
        end
        print(("key: %d, value: %d"):format(pair.key, pair.value))
        if tonumber(pair.key) == keyNum then
          local collection = playerData:GetAsync(pair.key)
          if collection then
            print("Found key ".. tostring(pair.key).. "; Writing back to key ".. tostring(firstKey).. "...\n")
            wait(4)
            playerData:SetAsync(tostring(firstKey), collection)
            return
          end
        end
        iter = iter + 1
        if iter > numRecords then
          print("Returning after ".. tostring(numRecords).." records.")
          return
        end
      end
      if pages.IsFinished then
        print(("Finished (%d: %s)"):format(userId, DATA_STORE_NAME))
        return
      end
    end
  else
    warn("Error getting data")
  end
end


-- REMOVE ALL ORDERED DATA
function Cmd.RemoveAllOrderedData(userId)
  local orderedDataStore = DataStoreService:GetOrderedDataStore(DATA_STORE_NAME .. "/" .. userId)
  local playerData = DataStoreService:GetDataStore(DATA_STORE_NAME.."/"..userId)
  if playerData then
    while true do
      local pages = orderedDataStore:GetSortedAsync(false, 100)
      local data = pages:GetCurrentPage()
      for _, pair in pairs(data) do
        print(("Removed key: %d"):format(pair.key))
        playerData:RemoveAsync(pair.key)
        orderedDataStore:RemoveAsync(pair.key)
      end
      if pages.IsFinished then
        print(("Finished (%d: %s)"):format(userId, DATA_STORE_NAME))
        return
      end
    end
  else
    warn("Error getting data")
  end
end


return Cmd

