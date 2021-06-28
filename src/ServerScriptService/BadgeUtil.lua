local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ReplicatedStorage.Globals)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)


local BadgeUtil = {}

BadgeUtil.WELCOME = 2124772383


local function awardBadge(player, badgeId)
  if player and badgeId then
    print("Checking for badge ".. tostring(badgeId).. " for ".. player.Name)
    local hasBadge = false
    local userId = player.UserId
    if userId then
      -- Check if the player already has the badge
      local success, message = pcall(function()
        hasBadge = BadgeService:UserHasBadgeAsync(userId, badgeId)
      end)

      -- If there's an error, issue a warning and exit the function
      if not success then
        warn("Error while checking if player has badge: " .. tostring(message))
        return
      end

      if hasBadge == false then
        BadgeService:AwardBadge(userId, badgeId)
        print("   Badge awarded to ".. player.Name)
      end
    end
  end
end


function BadgeUtil.AwardWelcomeBadge(player)
  Promise.try(function()
    Util:RealWait(Globals.LOADING_SCREEN_LENGTH + 2)
    awardBadge(player, BadgeUtil.WELCOME)
  end)
end

return BadgeUtil

