local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local SoundModule = {}


-- Drip
SoundModule.SOUND_ID_DRIP = "rbxassetid://2676723649"  -- https://www.roblox.com/library/2676723649/Drip

-- Mouse click
SoundModule.SOUND_ID_MOUSE_CLICK = "rbxassetid://421058925"  -- https://www.roblox.com/library/421058925/Click

-- Squish
SoundModule.SOUND_ID_SQUISH = "rbxassetid://162180713"  -- https://www.roblox.com/library/162180713/Squish

-- Switch3
SoundModule.SOUND_ID_SWITCH3 = "rbxassetid://12222183"  -- https://www.roblox.com/library/12222183/SWITCH3-wav

-- Clickfast (not used yet)
SoundModule.SOUND_ID_CLICK_FAST = "rbxassetid://12221976"  -- https://www.roblox.com/library/12221976/clickfast-wav


local function playSound(parentObject, soundId)
  -- Run in new thread
  Promise.try(function()
    local mouseClickSound = Instance.new("Sound")
    mouseClickSound.SoundId = soundId
    mouseClickSound.Parent = parentObject
    mouseClickSound:Play()
    Util:RealWait(2)
    mouseClickSound:Destroy()
  end):catch(function()
    warn("Problem playing sound: ".. soundId)
  end)
end 


function SoundModule.PlayDrip(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_DRIP)
end

function SoundModule.PlayMouseClick(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_MOUSE_CLICK)
end

function SoundModule.PlaySquish(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_SQUISH)
end

function SoundModule.PlaySwitch3(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_SWITCH3)
end


return SoundModule
