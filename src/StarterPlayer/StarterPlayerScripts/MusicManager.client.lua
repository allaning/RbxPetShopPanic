local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local PlayMusicBindableEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayMusicBindable")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local music = {
  ['1'] = {
    "rbxassetid://1843313385",  -- https://www.roblox.com/library/1843313385/Swing-it
    "rbxassetid://1846707136",  -- https://www.roblox.com/library/1846707136/Baby-Dwarf
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
  },
}


local currentMusic = nil


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
  if currentMusic and currentMusic.IsPlaying then
    currentMusic:Stop()
  end
end


local function playSessionMusic(duration, levelName)
  -- Choose music
  local rand = Random.new()
  local randIdx = rand:NextInteger(1, #(music[levelName]))
  playMusic(PlayerGui, music[levelName][randIdx])
end
SessionCountdownBeginEvent.OnClientEvent:Connect(playSessionMusic)

local function stopSessionMusic()
  stopMusic()
end
SessionEndedEvent.OnClientEvent:Connect(stopSessionMusic)

