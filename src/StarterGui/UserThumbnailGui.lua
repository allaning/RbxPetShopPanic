local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local Players = game:GetService("Players")

local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420

local THUMB_SIZE_SCALE_X = 0.12
local THUMB_SIZE_SCALE_Y = 0.12

local UserThumbnailGui = {}

UserThumbnailGui.MainFrameName = "UserThumbnail"
UserThumbnailGui.VoteFrameName = "VoteBgFrame"

function UserThumbnailGui.GetThumbnail(playerName, userId)
  local frame = Util:CreateInstance("Frame", {
      Name = UserThumbnailGui.MainFrameName,
      Size = UDim2.new(THUMB_SIZE_SCALE_X, 0, THUMB_SIZE_SCALE_Y, 0),
      SizeConstraint = Enum.SizeConstraint.RelativeYY,
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BackgroundTransparency = 0.0,
    }, nil)
  local uiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(1, 20),
    }, frame)

  -- Show user thumbnail
  local imageStr
  local ok, result = pcall(function()
    imageStr = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
  end)
  if not ok then
    warn("Could not get user thumbnail for ".. playerName)
  else
    if imageStr then
      local image = Util:CreateInstance("ImageLabel", {
          Image = imageStr,
          Size = UDim2.new(1.0, 0, 1.0, 0),
          BackgroundTransparency = 1.0,
        }, frame)
    end
  end

  -- Name
  local name = Util:CreateInstance("TextLabel", {
      Name = playerName,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.95, 0),
      Size = UDim2.new(1.4, 0, 0.3, 0),
      BackgroundTransparency = 1.0,
      TextScaled = true,
      Text = playerName,
      TextColor3 = Color3.fromRGB(255, 255, 0),
      Font = Enum.Font.FredokaOne,
      ZIndex = 2,
    }, frame)

  return frame
end

function UserThumbnailGui.GetImageThumbnail(assetId, sizeDim, color, zIndex)
  if assetId then
    sizeDim = sizeDim or UDim2.new(0.3, 0, 0.3, 0)
    color = color or Color3.fromRGB(255, 255, 255)
    zIndex = zIndex or 1

    local frame = Util:CreateInstance("Frame", {
        Name = "Thumbnail",
        Size = sizeDim,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundColor3 = color,
        BackgroundTransparency = 0.0,
        ZIndex = zIndex,
      }, nil)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(1, 20),
      }, frame)

    -- Show thumbnail
    zIndex += 1
    local image = Util:CreateInstance("ImageLabel", {
        Image = assetId,
        Size = UDim2.new(1.0, 0, 1.0, 0),
        BackgroundTransparency = 1.0,
        ZIndex = zIndex,
      }, frame)

    return frame
  end
end

return UserThumbnailGui

