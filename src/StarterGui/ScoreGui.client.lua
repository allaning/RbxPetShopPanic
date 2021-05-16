-- Show score

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

-- Events
local SessionCountdownBeginEvent = ReplicatedStorage.Events.SessionCountdownBegin
local SessionEndedEvent = ReplicatedStorage.Events.SessionEnded
local SessionScoreEvent = ReplicatedStorage.Events.SessionScore

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Player.Character or Player.CharacterAdded:wait()


local FONT_COLOR_DEFAULT = Color3.fromRGB(255, 255, 0)
local FONT_BORDER_COLOR_DEFAULT = Color3.fromRGB(170, 170, 0)


local scoreGui = nil
local textLabel = nil


local function getScoreTitleTextLabel(screenGui)
  local textLabel = Util:CreateInstance("TextLabel", {
      Text = "Score:",
      Font = Enum.Font.Bangers,
      --Font = Enum.Font.LuckiestGuy,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.05, 0, 0.43, 0),
      Size = UDim2.new(0.1, 0, 0.07, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 0.0,
      TextScaled = true,
      BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 0.0,
      BorderSizePixel = 5,
      BorderColor3 = Color3.new(1, 1, 1),
      ZIndex = 2,
    }, screenGui)
  return textLabel
end

local function getScoreTextLabel(screenGui, score)
  local textLabel = Util:CreateInstance("TextLabel", {
      Text = score,
      Font = Enum.Font.Bangers,
      --Font = Enum.Font.LuckiestGuy,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.05, 0, 0.5, 0),
      Size = UDim2.new(0.1, 0, 0.07, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 0.0,
      TextScaled = true,
      BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 0.0,
      BorderSizePixel = 5,
      BorderColor3 = Color3.new(1, 1, 1),
    }, screenGui)
  return textLabel
end

local function initializeScoreGui(score)
  scoreGui = Util:CreateInstance("ScreenGui", {
      Name = "ScoreGui",
    }, PlayerGui)

  getScoreTitleTextLabel(scoreGui)
  textLabel = getScoreTextLabel(scoreGui, score)
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
  if textLabel then
    textLabel.Text = tostring(score)
  end
end
SessionScoreEvent.OnClientEvent:Connect(updateScore)

