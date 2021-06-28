local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Globals = require(ReplicatedStorage.Globals)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local LobbyMusicBeginBindableEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LobbyMusicBeginBindable")
local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local PlayMusicBindableEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayMusicBindable")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local lobbyMusic = "rbxassetid://1835276362"  -- https://www.roblox.com/library/1835276362/Many-Hands-Make-Light-Work-Main

local music = {
  ['1'] = {
    "rbxassetid://1846707136",  -- https://www.roblox.com/library/1846707136/Baby-Dwarf
    "rbxassetid://1843313385",  -- https://www.roblox.com/library/1843313385/Swing-it
    "rbxassetid://1841212514",  -- https://www.roblox.com/library/1841212514/Shop-til-You-Flop-a
  },
  ['2'] = {
    "rbxassetid://1846442728",  -- https://www.roblox.com/library/refer/1846442728/The-Entertainer
    "rbxassetid://1844779713",  -- https://www.roblox.com/library/1844779713/Boulevard
    "rbxassetid://1845765957",  -- https://www.roblox.com/library/1845765957/Happy-Music-Happy-People
  },
  ['3'] = {
    "rbxassetid://1847645014",  -- https://www.roblox.com/library/1847645014/8-Bit-Special-C
    "rbxassetid://1847606521",  -- https://www.roblox.com/library/1847606521/Im-Gonna-Get-Up-Remix-C
    "rbxassetid://1843384340",  -- https://www.roblox.com/library/1843384340/Morning-Run
  },
  ['4'] = {
    "rbxassetid://1838857104",  -- https://www.roblox.com/library/1838857104/Roselita
    "rbxassetid://1838529052",  -- https://www.roblox.com/library/1838529052/Ska-Wah
    "rbxassetid://1837720187",  -- https://www.roblox.com/library/1837720187/The-Secret-Room
  },
}


local currentMusic = nil


local function isLocalPlayerInGameSession()
  return Player:GetAttribute(Globals.PLAYER_IS_IN_GAME_SESSION_ATTRIBUTE_NAME)
end

local function playMusic(parentObject, soundId, volume)
  local volume = volume or 0.3

  -- Run in new thread
  Promise.try(function()
    currentMusic = Util:CreateInstance("Sound", {
        SoundId = soundId,
        Volume = volume,
        EmitterSize = 80,
        RollOffMode = Enum.RollOffMode.InverseTapered,
        Looped = true,
      }, parentObject)

    currentMusic:Play()
  end):catch(function()
    warn("Problem playing music: ".. soundId)
  end)
end 
PlayMusicBindableEvent.Event:Connect(playMusic)


local function stopMusic()
  if currentMusic and currentMusic.IsPlaying and isLocalPlayerInGameSession() then
    currentMusic:Stop()
    currentMusic:Destroy()
  end
end
SessionEndedEvent.OnClientEvent:Connect(stopMusic)


local function playLobbyMusic()
  playMusic(PlayerGui, lobbyMusic)
end
LobbyMusicBeginBindableEvent.Event:Connect(playLobbyMusic)


local function playSessionMusic(duration, levelName, sessionCount)
  stopMusic()

  -- Choose music
  local idx = (sessionCount % #(music[levelName])) + 1
  if idx < 1 then
    idx = 1
  elseif idx > #(music[levelName]) then
    idx = #(music[levelName])
  end
  playMusic(PlayerGui, music[levelName][idx])
end
SessionCountdownBeginEvent.OnClientEvent:Connect(playSessionMusic)


playLobbyMusic()

