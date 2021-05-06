local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local SoundModule = {}


-- Chime
SoundModule.SOUND_ID_CHIME_ANSWER = "rbxassetid://1839997962"  -- https://www.roblox.com/library/1839997962/Right-Answer

-- Chime
SoundModule.SOUND_ID_CHIME = "rbxassetid://6148388066"  -- https://www.roblox.com/library/6148388066/Chime

-- Chime
SoundModule.SOUND_ID_CHIME_2 = "rbxassetid://6169248722"  -- https://www.roblox.com/library/6169248722/Chime

-- Clickfast
SoundModule.SOUND_ID_CLICK_FAST = "rbxassetid://12221976"  -- https://www.roblox.com/library/12221976/clickfast-wav

-- Correct answer 1
SoundModule.SOUND_ID_CORRECT_ANSWER_1 = "rbxassetid://1839997916"  -- https://www.roblox.com/library/refer/1839997916/Correct-Answer-1

-- Correct answer 2
SoundModule.SOUND_ID_CORRECT_ANSWER_2 = "rbxassetid://1839997929"  -- https://www.roblox.com/library/refer/1839997929/Correct-Answer-2

-- Drip
SoundModule.SOUND_ID_DRIP = "rbxassetid://2676723649"  -- https://www.roblox.com/library/2676723649/Drip

-- Kerplunk
SoundModule.SOUND_ID_KERPLUNK = "rbxassetid://12222054"  -- https://www.roblox.com/library/12222054/Kerplunk-wav

-- Level up
SoundModule.SOUND_ID_LEVEL_UP = "rbxassetid://948261889"  -- https://www.roblox.com/library/948261889/Level-Up

-- Level up (higher pitch)
SoundModule.SOUND_ID_LEVEL_UP_HIGH = "rbxassetid://5153733046"  -- https://www.roblox.com/library/5153733046/Level-Up

-- Level up (dramatic)
SoundModule.SOUND_ID_LEVEL_UP_DRAMATIC = "rbxassetid://3120909354"  -- https://www.roblox.com/library/3120909354/Level-up

-- Mouse click
SoundModule.SOUND_ID_MOUSE_CLICK = "rbxassetid://421058925"  -- https://www.roblox.com/library/421058925/Click

-- Spring
SoundModule.SOUND_ID_SPRING = "rbxassetid://12222124"  -- https://www.roblox.com/library/12222124/Short-spring-sound-wav

-- Squish
SoundModule.SOUND_ID_SQUISH = "rbxassetid://162180713"  -- https://www.roblox.com/library/162180713/Squish

-- Switch3
SoundModule.SOUND_ID_SWITCH3 = "rbxassetid://12222183"  -- https://www.roblox.com/library/12222183/SWITCH3-wav

-- Wah
SoundModule.SOUND_ID_WAH = "rbxassetid://597537672"  -- https://www.roblox.com/library/597537672/WAH

-- Wave
SoundModule.SOUND_ID_WAVE = "rbxassetid://860861713"  -- https://www.roblox.com/library/860861713/Level-up-o


local function playSound(parentObject, soundId, volume)
  local volume = volume or 0.5

  -- Run in new thread
  Promise.try(function()
    local mouseClickSound = Util:CreateInstance("Sound", {
        SoundId = soundId,
        Volume = volume,
        EmitterSize = 80,
        RollOffMode = Enum.RollOffMode.InverseTapered,
      }, parentObject)

    mouseClickSound:Play()
    Util:RealWait(2)
    mouseClickSound:Destroy()
  end):catch(function()
    warn("Problem playing sound: ".. soundId)
  end)
end 


function SoundModule.PlayAssetIdStr(parentObject, assetIdStr, volume)
  if assetIdStr and assetIdStr ~= "" then
    playSound(parentObject, assetIdStr, volume)
  end
end

function SoundModule.PlayChime(parentObject, volume)
  playSound(parentObject, SoundModule.SOUND_ID_CHIME, volume)
end

function SoundModule.PlayChime2(parentObject, volume)
  playSound(parentObject, SoundModule.SOUND_ID_CHIME_2, volume)
end

function SoundModule.PlayChimeAnswer(parentObject, volume)
  playSound(parentObject, SoundModule.SOUND_ID_CHIME_ANSWER, volume)
end

function SoundModule.PlayCorrectAnswer1(parentObject, volume)
  playSound(parentObject, SoundModule.SOUND_ID_CORRECT_ANSWER_1, volume)
end

function SoundModule.PlayCorrectAnswer2(parentObject, volume)
  playSound(parentObject, SoundModule.SOUND_ID_CORRECT_ANSWER_2, volume)
end

function SoundModule.PlayDrip(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_DRIP)
end

function SoundModule.PlayKerplunk(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_KERPLUNK)
end

function SoundModule.PlayLevelUp(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_LEVEL_UP)
end

function SoundModule.PlayLevelUpHigh(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_LEVEL_UP_HIGH)
end

function SoundModule.PlayLevelUpDramatic(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_LEVEL_UP_DRAMATIC)
end

function SoundModule.PlayMouseClick(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_MOUSE_CLICK)
end

function SoundModule.PlaySpring(parentObject, volume)
  playSound(parentObject, SoundModule.SOUND_ID_SPRING, volume)
end

function SoundModule.PlaySquish(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_SQUISH)
end

function SoundModule.PlaySwitch3(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_SWITCH3)
end

function SoundModule.PlayWah(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_WAH)
end

function SoundModule.PlayWave(parentObject)
  playSound(parentObject, SoundModule.SOUND_ID_WAVE)
end


return SoundModule
