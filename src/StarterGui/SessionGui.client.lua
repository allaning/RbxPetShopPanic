-- Show session gui, e.g. score

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
local scoreFrame = nil
local textLabel = nil


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
      TextStrokeTransparency = 0.0,
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
      Position = UDim2.new(0.0, 0, 0.5, 0),
      Size = UDim2.new(1.0, 0, 0.5, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 0.0,
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
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 8,
        BorderColor3 = Color3.new(1, 1, 1),
      }, scoreGui)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 20),
      }, scoreFrame)

    getScoreTitleTextLabel(scoreFrame)
  end

  textLabel = getScoreTextLabel(scoreFrame, score)
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

