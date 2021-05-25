local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local ViewportFrameFactory = require(ReplicatedStorage.Gui.ViewportFrameFactory)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)

local StarterGui = game:GetService("StarterGui")
local FrameFactory = require(StarterGui.FrameFactory)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local ScoreGui = {}

ScoreGui.Frame = nil
ScoreGui.OuterFrame = nil
ScoreGui.BackgroundFrame = nil

function ScoreGui.GetCopy()
  if not ScoreGui.Frame then
    local zIndex = 5
    ScoreGui.BackgroundFrame = Util:CreateInstance("Frame", {
        Name = "ScoreGui",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1.1, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Color3.fromRGB(111, 166, 255),
        ZIndex = zIndex,
      }, nil)

    ScoreGui.Frame, ScoreGui.OuterFrame = FrameFactory.GetDefaultLobbyFrame()
    ScoreGui.Frame.Name = "ScoreGui.Frame"
    ScoreGui.OuterFrame.Name = "ScoreGui.OuterFrame"
    ScoreGui.OuterFrame.Visible = true
    ScoreGui.OuterFrame.Parent = ScoreGui.BackgroundFrame

    zIndex += 1
    ScoreGui.OuterFrame.ZIndex = zIndex
    zIndex += 1
    ScoreGui.Frame.ZIndex = zIndex
    zIndex += 1

    -- Title
    local title = Util:CreateInstance("TextLabel", {
        Name = "Score",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.1, 0),
        Size = UDim2.new(0.3, 0, 0.12, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "STARS",
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
        ZIndex = zIndex,
      }, ScoreGui.Frame)

    -- TODO show stars
    -- Frame
    local frame = Util:CreateInstance("Frame", {
        Name = "Levels",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.58, 0),
        Size = UDim2.new(0.58, 0, 0.7, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
        BorderSizePixel = 2,
        BorderColor3 = Themes[Themes.CurrentTheme].BorderColor,
      }, ScoreGui.Frame)
    local uiListLayout = Util:CreateInstance("UIListLayout", {
      }, frame)

    zIndex += 1
    local okBtn = Util:CreateInstance("TextButton", {
        Name = "OK",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.86, 0),
        Size = UDim2.new(0.12, 0, 0.07, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Color3.fromRGB(220, 28, 28),
        BorderSizePixel = 0,
        Text = "OK",
        Font = Enum.Font.Bangers,
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
        ZIndex = zIndex,
      }, ScoreGui.BackgroundFrame)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
      }, okBtn)
    okBtn.Activated:Connect(function()
        SoundModule.PlayMouseClick(PlayerGui)
        ScoreGui.BackgroundFrame:Destroy()
      end)
  end
  return ScoreGui.BackgroundFrame
end

return ScoreGui

