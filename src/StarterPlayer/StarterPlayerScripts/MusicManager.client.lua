local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local SessionCountdownBeginEvent = ReplicatedStorage.Events.SessionCountdownBegin
local SessionEndedEvent = ReplicatedStorage.Events.SessionEnded

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


-- Swing It
 local MUSIC_ID_SWING_IT = "rbxassetid://1843313385"  -- https://www.roblox.com/library/1843313385/Swing-it


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

local function stopMusic()
  if currentMusic and currentMusic.IsPlaying then
    currentMusic:Stop()
  end
end


local function playSessionMusic()
  -- TODO: Choose music
  playMusic(PlayerGui, MUSIC_ID_SWING_IT)
end
SessionCountdownBeginEvent.OnClientEvent:Connect(playSessionMusic)

local function stopSessionMusic()
  stopMusic()
end
SessionEndedEvent.OnClientEvent:Connect(stopSessionMusic)

