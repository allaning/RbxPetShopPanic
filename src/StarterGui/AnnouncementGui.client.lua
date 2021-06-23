-- Show announcements

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ReplicatedStorage.Globals)
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
local Util = require(ReplicatedStorage.Util)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Promise = require(ReplicatedStorage.Vendor.Promise)

-- Events
local ShowTitleMessageEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowTitleMessage")
local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local ShowMessagePopupEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowMessagePopup")
local ShowMessagePopupBindableEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowMessagePopupBindable")
local ShowAnnouncementBindableEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowAnnouncement")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Player.Character or Player.CharacterAdded:wait()


local FONT_COLOR_DEFAULT = Color3.fromRGB(255, 255, 0)
local FONT_BORDER_COLOR_DEFAULT = Color3.fromRGB(170, 170, 0)


local function isLocalPlayerInGameSession()
  return Player:GetAttribute(Globals.PLAYER_IS_IN_GAME_SESSION_ATTRIBUTE_NAME)
end

local function showMessagePopup(message, duration)
  SoundModule.PlayAssetIdStr(Character, SoundModule.SOUND_ID_ERROR, 0.5)

  local screenGui = Instance.new("ScreenGui")
  screenGui.Parent = PlayerGui
  local frame = Util:CreateInstance("Frame", {
      BackgroundColor3 = Color3.new(1, 1, 1),
      BorderSizePixel = 5,
      BorderColor3 = Color3.new(1, 1, 1),
      Position = UDim2.new(0.5, 0, 0.85, 0),
      Size = UDim2.new(0.2, 0, 0.04, 0),
      AnchorPoint = Vector2.new(0.5, 0.5),
    }, screenGui)
  local uiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(0, 10),
    }, frame)
  local textLabel = Util:CreateInstance("TextLabel", {
      Text = message,
      Font = Enum.Font.SourceSansSemibold,
      Position = UDim2.new(0.0, 0, 0.0, 0),
      Size = UDim2.new(1.0, 0, 1.0, 0),
      BackgroundTransparency = 1.0,
      TextColor3 = Color3.new(0.2, 0.5, 0.7),
      TextScaled = true,
    }, frame)
  TweenGuiFactory.SpringUpFrame(frame, duration)

  Promise.delay(duration):andThen(function()
    screenGui:Destroy()
  end)
end
ShowMessagePopupEvent.OnClientEvent:Connect(showMessagePopup)
ShowMessagePopupBindableEvent.Event:Connect(showMessagePopup)


local function showTitle(message, durationSec)
  local duration = durationSec or 2.0

  local titleGui = Util:CreateInstance("ScreenGui", {
      Name = "TitleGui",
    }, PlayerGui)

  local textLabel = Util:CreateInstance("TextLabel", {
      Text = message,
      Font = Enum.Font.Bangers,
      --Font = Enum.Font.LuckiestGuy,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.4, 0),
      Size = UDim2.new(0.4, 0, 0.2, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 0.0,
      TextScaled = true,
      BackgroundTransparency = 1,
    }, titleGui)
  local scale = Util:CreateInstance("UIScale", {
      Scale = 1.0,
    }, textLabel)

  Promise.delay(duration):andThen(function()
    TweenGuiFactory.ScaleOut(scale, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, false)
    textLabel:Destroy()
    titleGui:Destroy()
  end)
end
ShowTitleMessageEvent.OnClientEvent:Connect(showTitle)


local function getAnnouncementTextLabel(screenGui, message, backgroundTransparency, scale)
  local textLabel = Util:CreateInstance("TextLabel", {
      Text = message,
      Font = Enum.Font.Bangers,
      --Font = Enum.Font.LuckiestGuy,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.6, 0),
      Size = UDim2.new(0.4, 0, 0.1, 0),
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
  isBackgroundTransparent = isBackgroundTransparent or true
  local duration = durationSec or 2.0

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
ShowAnnouncementBindableEvent.Event:Connect(showAnnouncement)

-- Show "ready, set, go" countdown
local function showSessionCountdownBeginAnnouncement()
  if isLocalPlayerInGameSession() then
    showAnnouncement("Ready", true, 0.9)
    Util:RealWait(Globals.READY_SET_GO_COUNTDOWN_SEC / 4)
    showAnnouncement("3", true, 0.9)
    Util:RealWait(Globals.READY_SET_GO_COUNTDOWN_SEC / 4)
    showAnnouncement("2", true, 0.9)
    Util:RealWait(Globals.READY_SET_GO_COUNTDOWN_SEC / 4)
    showAnnouncement("1", true, 0.9)
    Util:RealWait(Globals.READY_SET_GO_COUNTDOWN_SEC / 4)
    showAnnouncement("Go!", true, 0.9)
  end
end
SessionCountdownBeginEvent.OnClientEvent:Connect(showSessionCountdownBeginAnnouncement)

local function showSessionEndedAnnouncement()
  if isLocalPlayerInGameSession() then
    showAnnouncement("Time's Up", true, 1.5)
  end
end
SessionEndedEvent.OnClientEvent:Connect(showSessionEndedAnnouncement)

