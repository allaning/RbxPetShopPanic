-- Show session gui, e.g. score

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
local Globals = require(ReplicatedStorage.Globals)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Assets = require(ReplicatedStorage.Assets)

local StarterGui = game:GetService("StarterGui")
local UserThumbnailGui = require(StarterGui.UserThumbnailGui)
local FrameFactory = require(StarterGui.FrameFactory)

-- Events
local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionUpdateTimerCountdownEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionUpdateTimerCountdown")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local SessionScoreEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionScore")
local ShowAnnouncementBindableEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowAnnouncement")
local GetCurrentMapLevelFn = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetCurrentMapLevel")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Player.Character or Player.CharacterAdded:wait()


local FONT_COLOR_DEFAULT = Color3.fromRGB(255, 255, 0)
local FONT_BORDER_COLOR_DEFAULT = Color3.fromRGB(170, 170, 0)


local function isLocalPlayerInGameSession()
  return Player:GetAttribute(Globals.PLAYER_IS_IN_GAME_SESSION_ATTRIBUTE_NAME)
end


-- Score

local scoreGui = nil
local scoreFrame = nil
local scoreTextLabel = nil

local function getScoreTitleTextLabel(parent)
  local textLabel = Util:CreateInstance("TextLabel", {
      Name = "Title",
      Text = "Score:",
      Font = Enum.Font.Bangers,
      --Font = Enum.Font.LuckiestGuy,
      Position = UDim2.new(0.0, 0, 0.0, 0),
      Size = UDim2.new(1.0, 0, 0.5, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 1.0,
      TextScaled = true,
      BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 1.0,
      BorderSizePixel = 0,
      ZIndex = 2,
    }, parent)
  return textLabel
end

local function getScoreTextLabel(score)
  local textLabel = Util:CreateInstance("TextLabel", {
      Name = "Value",
      Text = score,
      --Font = Enum.Font.Bangers,
      Font = Enum.Font.LuckiestGuy,
      Position = UDim2.new(0.0, 0, 0.52, 0),
      Size = UDim2.new(1.0, 0, 0.5, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 1.0,
      TextScaled = true,
      BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 1.0,
      BorderSizePixel = 0,
    }, nil)
  return textLabel
end

local function initializeScoreGui(score)
  if not scoreGui then
    scoreGui = Util:CreateInstance("ScreenGui", {
          Name = "ScoreGui",
        }, PlayerGui)
    scoreFrame = Util:CreateInstance("Frame", {
        Position = UDim2.new(0.0, 0, 0.4, 0),
        Size = UDim2.new(0.12, 0, 0.16, 0),
        BackgroundColor3 = Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 8,
        BorderColor3 = Color3.new(1, 1, 1),
      }, scoreGui)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 20),
      }, scoreFrame)

    -- "Score:" heading
    getScoreTitleTextLabel(scoreFrame)
    -- Score value
    scoreTextLabel = getScoreTextLabel(score)
    scoreTextLabel.Parent = scoreFrame
  end
end


local function showScoreGui()
  if scoreGui then
    scoreGui.Enabled = true
  end
  initializeScoreGui(0)
  if scoreTextLabel then
    scoreTextLabel.Text = tostring(0)
  end
end

local function hideScoreGui()
  if scoreGui then
    scoreGui.Enabled = false
  end
end

local function updateScore(increment)
  if scoreTextLabel and isLocalPlayerInGameSession() then
    -- Show announcement
    local announcementMsg = "+".. tostring(increment)
    ShowAnnouncementBindableEvent:Fire(announcementMsg, true, 1.0)

    -- Update score gui
    local scoreNumber = tonumber(scoreTextLabel.Text)
    scoreNumber += increment
    scoreTextLabel.Text = tostring(scoreNumber)
  end
end
SessionScoreEvent.OnClientEvent:Connect(updateScore)



-- Timer

local timerGui = nil
local timerFrame = nil
local timerTextLabel = nil
local timerScale = nil

local function getTimerTitleTextLabel(parent)
  local textLabel = Util:CreateInstance("TextLabel", {
      Name = "Title",
      Text = "Time:",
      Font = Enum.Font.Bangers,
      --Font = Enum.Font.LuckiestGuy,
      Position = UDim2.new(0.0, 0, 0.0, 0),
      Size = UDim2.new(1.0, 0, 0.5, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 1.0,
      TextScaled = true,
      BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 1.0,
      BorderSizePixel = 0,
      ZIndex = 2,
    }, parent)
  return textLabel
end

local function getTimerTextLabel(timer)
  local textLabel = Util:CreateInstance("TextLabel", {
      Name = "Value",
      Text = tostring(timer),
      --Font = Enum.Font.Bangers,
      Font = Enum.Font.LuckiestGuy,
      AnchorPoint = Vector2.new(0.5, 0, 0.5, 0),
      Position = UDim2.new(0.5, 0, 0.52, 0),
      Size = UDim2.new(1.0, 0, 0.5, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 1.0,
      TextScaled = true,
      BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 1.0,
      BorderSizePixel = 0,
    }, nil)
  local scale = Util:CreateInstance("UIScale", {
      Scale = 1.0,
    }, textLabel)
  return textLabel, scale
end

local function initializeTimerGui(timer)
  if not timerGui then
    timerGui = Util:CreateInstance("ScreenGui", {
          Name = "TimerGui",
        }, PlayerGui)
    timerFrame = Util:CreateInstance("Frame", {
        Position = UDim2.new(0.88, 0, 0.4, 0),
        Size = UDim2.new(0.12, 0, 0.16, 0),
        BackgroundColor3 = Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 8,
        BorderColor3 = Color3.new(1, 1, 1),
      }, timerGui)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 20),
      }, timerFrame)

    -- "Time:" heading
    getTimerTitleTextLabel(timerFrame)
    -- Time value
    timerTextLabel, timerScale = getTimerTextLabel(timer)
    timerTextLabel.Parent = timerFrame
  end
end


local function showTimerGui(duration)
  if timerGui then
    timerGui.Enabled = true
  end
  initializeTimerGui(duration)
  if timerTextLabel then
    timerTextLabel.Text = tostring(duration)
  end
end

local function showGuis(duration)
  showScoreGui()
  showTimerGui(duration)

  -- Check if show intro gui
  local mapLevel = GetCurrentMapLevelFn:InvokeServer() or 2
  if mapLevel == 1 then
    local screenGui = Util:CreateInstance("ScreenGui", {
        Name = "HowToPlay",
      }, nil)
    local thumb = UserThumbnailGui.GetImageThumbnail(Assets.CHARACTER_SMILING, UDim2.new(0.3, 0, 0.3, 0), nil, 3)
    local introText = "Give the customer and animals the items they need. Good luck!"
    local msg = FrameFactory.GetTypedMessageFrame(introText, UDim2.new(0.5, 0, 0.2, 0), nil, 2, false)
    if thumb and msg then
      screenGui.Parent = PlayerGui
      thumb.Position = UDim2.new(0.2, 0, 0.6, 0)
      thumb.Parent = screenGui
      msg.Position = UDim2.new(0.3, 0, 0.65, 0)
      msg.Parent = screenGui

    local exitButton = Util:CreateInstance("TextButton", {
        Name = "ExitButton",
        Position = UDim2.new(0.0, 0, 0.0, 0),
        Size = UDim2.new(1.0, 0, 1.0, 0),
        BackgroundTransparency = 1.0,
        Text = "",
      }, msg)
    exitButton.Activated:Connect(function()
      screenGui:Destroy()
    end)
      Promise.delay(8):andThen(function()
        if screenGui then
          screenGui:Destroy()
        end
      end)
    end
  end
end
SessionCountdownBeginEvent.OnClientEvent:Connect(showGuis)

local function hideTimerGui()
  if timerGui then
    timerGui.Enabled = false
  end
end

local function hideGuis()
  hideScoreGui()
  hideTimerGui()
end
SessionEndedEvent.OnClientEvent:Connect(hideGuis)


local function updateTimer(timeSec)
  if timerTextLabel then
    timerTextLabel.Text = tostring(timeSec)
    if timeSec < 10 then
      Promise.try(function()
        TweenGuiFactory.ScaleOut(timerScale, 0.07, Enum.EasingStyle.Linear, Enum.EasingDirection.In, true)
        TweenGuiFactory.ScaleIn(timerScale, 0.07, Enum.EasingStyle.Linear, Enum.EasingDirection.In, false)
      end)
    end
  end
end
SessionUpdateTimerCountdownEvent.OnClientEvent:Connect(updateTimer)

