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

-- NOTE: THIS HAS NOT BEEN TESTED YET

-- View latest data
-- Usage: Cmd.ShowLatestData(500841057) -- WhoooDattt
function Cmd.ShowLatestData(userId)
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
					if type(collection[__]) == "table" then
						local c = ""
						for ___, spec in pairs(collection[__]) do
							if type(spec) == "number" then
								spec = string.format("0x%x", spec)
							end
							c = c..tostring(___)..":"..tostring(spec)..", "
						end
						print("    c:"..tostring(c))
					else
						print("    c:"..tostring(collection[__]))
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



return Cmd

