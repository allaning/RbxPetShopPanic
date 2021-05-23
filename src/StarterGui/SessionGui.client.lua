-- Show session gui, e.g. score

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

-- Events
local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionUpdateTimerCountdownEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionUpdateTimerCountdown")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local SessionScoreEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionScore")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Player.Character or Player.CharacterAdded:wait()


local FONT_COLOR_DEFAULT = Color3.fromRGB(255, 255, 0)
local FONT_BORDER_COLOR_DEFAULT = Color3.fromRGB(170, 170, 0)


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

local function getScoreTextLabel(parent, score)
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
    }, parent)
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

    getScoreTitleTextLabel(scoreFrame)
  end

  scoreTextLabel = getScoreTextLabel(scoreFrame, score)
end


local function showScoreGui()
  if scoreGui then
    scoreGui.Enabled = true
  end
  initializeScoreGui(0)
end
SessionCountdownBeginEvent.OnClientEvent:Connect(showScoreGui)

local function hideScoreGui()
  if scoreGui then
    scoreGui.Enabled = false
  end
end
SessionEndedEvent.OnClientEvent:Connect(hideScoreGui)

local function updateScore(score)
  if scoreTextLabel then
    scoreTextLabel.Text = tostring(score)
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

local function getTimerTextLabel(parent, timer)
  local textLabel = Util:CreateInstance("TextLabel", {
      Name = "Value",
      Text = timer,
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
    }, parent)
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

    getTimerTitleTextLabel(timerFrame)
  end

  timerTextLabel, timerScale = getTimerTextLabel(timerFrame, timer)
end


local function showTimerGui(duration)
  if timerGui then
    timerGui.Enabled = true
  end
  initializeTimerGui(duration)
end
SessionCountdownBeginEvent.OnClientEvent:Connect(showTimerGui)

local function hideTimerGui()
  if timerGui then
    timerGui.Enabled = false
  end
end
SessionEndedEvent.OnClientEvent:Connect(hideTimerGui)


local function updateTimer(timeSec)
  print("Update timer: ".. tostring(timeSec))
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

