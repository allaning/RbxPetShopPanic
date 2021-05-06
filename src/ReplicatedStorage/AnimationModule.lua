local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local AnimationModule = {}


-- Defeat WhoooDattt
--AnimationModule.ANIM_ID_DEFEAT = "rbxassetid://6777618070"  -- https://www.roblox.com/library/6777618070/Defeated-Mixamo
-- Defeat (The Animal Rescuers)
AnimationModule.ANIM_ID_DEFEAT = "rbxassetid://6777845942"  -- https://www.roblox.com/library/6777845942/Defeated

-- Victory Idle (The Animal Rescuers)
AnimationModule.ANIM_ID_VICTORY_IDLE = "rbxassetid://6777978681"  -- https://www.roblox.com/library/6777978681/Victory-Idle



local function getCurrentAnimationTrack(humanoid)
  local animtracks = humanoid:GetPlayingAnimationTracks()
  for _, track in pairs(animtracks) do
    if track.IsPlaying then
      return track
    end
  end
end


local function playAnimation(humanoid, animationId, isLooped, uid)
  if humanoid and animationId then
    local isLooped = isLooped or false
    local uid = uid or -1

    -- Stop current animation
    local oldTrack = nil
    if not isLooped then
      oldTrack = getCurrentAnimationTrack(humanoid)
      if oldTrack then
        oldTrack:Stop()
      end
    end

    -- Create new "Animation" instance
    local animation = Instance.new("Animation")
    -- Set its "AnimationId" to the corresponding animation asset ID
    animation.AnimationId = animationId
    -- Load animation onto the humanoid
    local animationTrack = humanoid:LoadAnimation(animation)
    -- Play animation track
    animationTrack:Play()

    -- Play old animation when done
    if not isLooped then
      if oldTrack then
        Promise.delay(animationTrack.Length):andThen(function()
          animationTrack:Stop()
          oldTrack:Play()

          -- TODO: Fire event singalling uid is complete
        end)
      end
    end
  end
end


function AnimationModule.PlayAssetIdStr(humanoid, assetIdStr, isLooped, uid)
  if humanoid and assetIdStr and assetIdStr ~= "" then
    playAnimation(humanoid, assetIdStr, isLooped, uid)
  end
end


return AnimationModule
