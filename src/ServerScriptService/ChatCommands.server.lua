-- See https://devforum.roblox.com/t/how-to-make-basic-admin-commands/59691
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")


local Prefix = "/"

local ANIMAL_RESCUE_GROUP_ID = 5006104
local WHOOODATTT_ID = 500841057

local Admins = {
	"WhoooDattt"; -- Username example
	WHOOODATTT_ID; -- WhoooDattt ID  -- User ID example
	"hgjfdiy322";
	-- {GroupId = 0000;RankId = 255;} -- Group example
}

-- Admin commands
local Commands = {}

-- Assistant commands
local AssistCommands = {}


-- Usage: /kick [PlayerName]
Commands.kick = function(Sender, Arguments)
	local Message = table.concat(Arguments, " ")
	print("ChatCommands: From " ..Sender.Name..": kick "..Message)
	local playerToKick = Players:FindFirstChild(Message)
	if playerToKick then
		--print("DEBUG: ChatCommands: kick "..Message)
		playerToKick:Kick("Disruption")
	else
		warn("kick: Could not find player: "..Message)
	end
end

local function IsAdmin(Player)
	for _,Admin in pairs (Admins) do
		--print(Admin, Player)
		if type(Admin) == "string" and string.lower(Admin) == string.lower(Player.Name) then
			return true
		elseif type(Admin) == "number" and Admin == Player.UserId then
			return true
		--[[elseif type(Admin) == "table" then
			local Rank = Player:GetRankInGroup(Admin.GroupId)
			if Rank >= (Admin.RankId or 1) then
				return true
			end]]
		end
	end
	return false
end

-- Parses message and execute command if valid
local function ParseMessage(Player, Message, Rank)
	--Message = string.lower(Message)
	local PrefixMatch = string.match(Message,"^"..Prefix)
	
	if PrefixMatch then
		Message = string.gsub(Message,PrefixMatch,"",1)
		local Arguments = {}
		
		for Argument in string.gmatch(Message,"[^%s]+") do
			table.insert(Arguments,Argument)
		end
		
		local CommandName = Arguments[1]
		table.remove(Arguments,1)

		if Rank == "Admin" then
			local CommandFunc = Commands[CommandName]
			if CommandFunc ~= nil then
				--print("DEBUG: ChatCommands: ParseMessage() player="..Player.Name.."; CommandName="..CommandName)
				CommandFunc(Player, Arguments)
			end
		end
		if Rank == "Assistant" or Rank == "Admin" then
			local CommandFunc = AssistCommands[CommandName]
			if CommandFunc ~= nil then
				--print("DEBUG: ChatCommands: ParseMessage() player="..Player.Name.."; CommandName="..CommandName)
				CommandFunc(Player, Arguments)
			end
		end

	end
end

Players.PlayerAdded:Connect(function(Player)
	Player.Chatted:Connect(function(Message, Recipient)
		if not Recipient then
			if IsAdmin(Player) then
				-- Parse message and execute command
				ParseMessage(Player, Message, "Admin")
			elseif IsAssistant(Player) then
				-- Parse message and execute command
				ParseMessage(Player, Message, "Assistant")
			end
		end
	end)
end)


-- Chat tags
-- Ref: https://devforum.roblox.com/t/how-would-i-make-chat-tags/243277/4

local ChatService = require(ServerScriptService:WaitForChild('ChatServiceRunner'):WaitForChild('ChatService'))
local GroupService = game:GetService("GroupService")

local function getRankInGroup(userId, groupId)
	local groups
	local success, message = pcall(function()
		groups = GroupService:GetGroupsAsync(userId)
	end)
	if not success then
		warn("ChatCommands:getRankInGroup(): Error while checking player groups: " .. tostring(message))
		return 0
	end

	if groups then
		for _, group in pairs(groups) do
			if group["Id"] == groupId then
				return group["Rank"]
			end
		end
	end
	return 0
end

-- https://developer.roblox.com/en-us/api-reference/function/Players/GetUserIdFromNameAsync
-- Memoization: since these results are rarely (if ever) going to change
-- all we have to do is check a cache table for the name.
-- If we find the name, then we have no work to do! Just return the user id (fast).
-- If we don't find the name (cache miss), go look it up (takes time).
local cache = {}
function getUserIdFromUsername(name)
	-- First, check if the cache contains the name
	if cache[name] then return cache[name] end
	-- Second, check if the user is already connected to the server
	local player = Players:FindFirstChild(name)
	if player then
		cache[name] = player.UserId
		return player.UserId
	end 
	-- If all else fails, send a request
	local id
	pcall(function ()
		id = Players:GetUserIdFromNameAsync(name)
	end)
	cache[name] = id
	return id
end

ChatService.SpeakerAdded:Connect(function(PlayerName)
	local Speaker
	local success, message = pcall(function()
		Speaker = ChatService:GetSpeaker(PlayerName)
	end)
	if not success then
		warn("ChatCommands:SpeakerAdded(): Error while getting Speaker for player: " .. tostring(message))
		return
	end

	local tag = ""
	local nameColor = Color3.fromRGB(209, 192, 97)
	local userId = getUserIdFromUsername(PlayerName)
	if userId then
		local hasTag = false
		local tagsList = {}

		-- Check Group
		local rank = getRankInGroup(userId, ANIMAL_RESCUE_GROUP_ID)
		if rank == 255 then
			-- Group Owner
			nameColor = Color3.fromRGB(92, 192, 192)
			Speaker:SetExtraData('NameColor', nameColor)
			hasTag = true
		elseif rank == 250 then
			table.insert(tagsList, {TagText = "Group Dev", TagColor = Color3.fromRGB(225, 92, 150)})
			hasTag = true
		elseif rank == 225 then
			table.insert(tagsList, {TagText = "Group Admin", TagColor = Color3.fromRGB(225, 92, 92)})
			hasTag = true
		elseif rank == 200 then
			table.insert(tagsList, {TagText = "Group Moderator", TagColor = Color3.fromRGB(92, 205, 205)})
			hasTag = true
		elseif rank == 150 then
			table.insert(tagsList, {TagText = "Veterinarian", TagColor = Color3.fromRGB(120, 205, 150)})
			hasTag = true
		elseif rank == 50 then
			table.insert(tagsList, {TagText = "Animal Caretaker", TagColor = Color3.fromRGB(150, 205, 120)})
			hasTag = true
		elseif rank == 1 then
			table.insert(tagsList, {TagText = "Group Member", TagColor = Color3.fromRGB(92, 205, 92)})
			hasTag = true
		end
		if hasTag then
			Speaker:SetExtraData('ChatColor', Color3.fromRGB(178, 248, 229))
			Speaker:SetExtraData('Tags', tagsList)
		end
	end
end)

