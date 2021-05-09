-- Use Animator directly
-- Ref: https://developer.roblox.com/en-us/api-reference/class/Animator

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local AnimationModule = {}


AnimationModule.IS_LOOPED = true
AnimationModule.IS_NOT_LOOPED = false


-- Defeat WhoooDattt
--AnimationModule.ANIM_ID_DEFEAT = "rbxassetid://6777618070"  -- https://www.roblox.com/library/6777618070/Defeated-Mixamo
-- Defeat (The Animal Rescuers)
AnimationModule.ANIM_ID_DEFEAT = "rbxassetid://6777845942"  -- https://www.roblox.com/library/6777845942/Defeated

-- Victory Idle (The Animal Rescuers)
AnimationModule.ANIM_ID_VICTORY_IDLE = "rbxassetid://6777978681"  -- https://www.roblox.com/library/6777978681/Victory-Idle

-- Typing (The Animal Rescuers)
AnimationModule.ANIM_ID_TYPING = "rbxassetid://6784134427"  -- https://www.roblox.com/library/6784134427/Cashier


local function getCurrentAnimationTrack(humanoid)
  local animtracks = humanoid:GetPlayingAnimationTracks()
  for _, track in pairs(animtracks) do
    if track.IsPlaying then
      return track
    end
  end
end

local function stopAllAnimationTracks(humanoid)
  local animtracks = humanoid:GetPlayingAnimationTracks()
  for _, track in pairs(animtracks) do
    if track.IsPlaying then
      track:Stop()
    end
  end
end


local function playAnimation(humanoid, animationId, isLooped, uid)
  if humanoid and animationId then
    local isLooped = isLooped or AnimationModule.IS_NOT_LOOPED
    local uid = uid or -1

    Promise.try(function()
      -- Need to use animation object for server access
      local animator = humanoid:FindFirstChildOfClass("Animator")
      if animator then
        -- Stop current animation
        local oldTrack = nil
        if isLooped == AnimationModule.IS_NOT_LOOPED then
          oldTrack = getCurrentAnimationTrack(animator)
          if oldTrack then
            oldTrack:Stop()
          end
        end

        -- Create new "Animation" instance
        local animation = Instance.new("Animation")
        -- Set its "AnimationId" to the corresponding animation asset ID
        animation.AnimationId = animationId
        -- Load animation onto the animator
        local animationTrack = animator:LoadAnimation(animation)
        animationTrack.Looped = isLooped

        -- Ensure track is playing before trying to access its Length else it will be 0
        while animationTrack.Length == 0 do
          Util:RealWait()
        end

        -- Play animation track
        animationTrack:Play()

        -- Stop animation before it completes, else it kept looping even when Looped was false
        Promise.delay(animationTrack.Length - 0.2):andThen(function()
          if isLooped == AnimationModule.IS_NOT_LOOPED then
            animationTrack:Stop(0.2)

            -- Play old animation when done
            if oldTrack then
              oldTrack:Play(0.8)
            end
          end

          -- TODO: Fire event singalling uid is complete
        end)

      end
    end)
  end
end


function AnimationModule.Stop(humanoid)
  if humanoid then
    stopAllAnimationTracks(humanoid)
  end
end

function AnimationModule.PlayAssetIdStr(humanoid, assetIdStr, isLooped, uid)
  if humanoid and assetIdStr and assetIdStr ~= "" then
    playAnimation(humanoid, assetIdStr, isLooped, uid)
  end
end

function AnimationModule.PlayVictoryAnimation(model)
  local human = Util:GetDescendantWithName(model, "Humanoid")
  if human then
    AnimationModule.PlayAssetIdStr(human, AnimationModule.ANIM_ID_VICTORY_IDLE, false)
  end
end

function AnimationModule.PlayDefeatAnimation(model)
  local human = Util:GetDescendantWithName(model, "Humanoid")
  if human then
    AnimationModule.PlayAssetIdStr(human, AnimationModule.ANIM_ID_DEFEAT, false)
  end
end

function AnimationModule.PlayTypingAnimation(model)
  local human = Util:GetDescendantWithName(model, "Humanoid")
  if human then
    AnimationModule.PlayAssetIdStr(human, AnimationModule.ANIM_ID_TYPING, true)
  end
end


return AnimationModule
