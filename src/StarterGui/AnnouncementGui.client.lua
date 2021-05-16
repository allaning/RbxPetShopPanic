-- Show announcements

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

-- Events
local SessionCountdownBeginEvent = ReplicatedStorage.Events.SessionCountdownBegin
local SessionEndedEvent = ReplicatedStorage.Events.SessionEnded

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Player.Character or Player.CharacterAdded:wait()


local FONT_COLOR_DEFAULT = Color3.fromRGB(255, 255, 0)
local FONT_BORDER_COLOR_DEFAULT = Color3.fromRGB(170, 170, 0)

local function getAnnouncementTextLabel(screenGui, message, backgroundTransparency, scale)
  local textLabel = Util:CreateInstance("TextLabel", {
      Text = message,
      Font = Enum.Font.Bangers,
      --Font = Enum.Font.LuckiestGuy,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.8, 0),
      Size = UDim2.new(0.3, 0, 0.07, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 0.0,
      TextScaled = true,
      BackgroundTransparency = backgroundTransparency,
    }, screenGui)
  local scale = Util:CreateInstance("UIScale", {
      Scale = scale,
    }, textLabel)
  return textLabel, scale
end

local function showAnnouncement(message, isBackgroundTransparent, durationSec)
  if isBackgroundTransparent == nil then
    isBackgroundTransparent = true
  end

  local duration = durationSec or 3.0

  local announceGui = Util:CreateInstance("ScreenGui", {
      Name = "AnnouncementGui",
    }, PlayerGui)

  local textLabel, scale = getAnnouncementTextLabel(announceGui, message, 1.0, 0.0)
  TweenGuiFactory.ScaleIn(scale, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, false)

  Promise.delay(duration):andThen(function()
    TweenGuiFactory.ScaleOut(scale, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, true)
    textLabel:Destroy()
    announceGui:Destroy()
  end)
end


local function showSessionCountdownBeginAnnouncement()
  showAnnouncement("Ready", true, 0.9)
  Util:RealWait(1.0)
  showAnnouncement("3", true, 0.9)
  Util:RealWait(1.0)
  showAnnouncement("2", true, 0.9)
  Util:RealWait(1.0)
  showAnnouncement("1", true, 0.9)
  Util:RealWait(1.0)
  showAnnouncement("Go!", true, 0.9)
end
SessionCountdownBeginEvent.OnClientEvent:Connect(showSessionCountdownBeginAnnouncement)

local function showSessionEndedAnnouncement()
  showAnnouncement("Time's Up", true, 1.5)
end
SessionEndedEvent.OnClientEvent:Connect(showSessionEndedAnnouncement)

