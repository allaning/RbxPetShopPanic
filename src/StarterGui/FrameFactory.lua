local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local Util = require(ReplicatedStorage.Util)


local FrameFactory = {}

function FrameFactory.GetDefaultLobbyFrame(frameSize)
  frameSize = frameSize or UDim2.new(0.6, 0, 0.5, 0)
  local mainFrame = nil
  local outerFrame = nil

  outerFrame = Util:CreateInstance("Frame", {
      Name = "outerFrame",
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      Size = frameSize,
      BackgroundTransparency = 0.0,
      BackgroundColor3 = Themes[Themes.CurrentTheme].BorderColor,
      BorderSizePixel = 0,
      ZIndex = 0,  -- Make in background
      Active = false,
      Visible = false,
    }, nil)
  local uiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(0, 20),
    }, outerFrame)

  -- Inner frame
  local mainFrame = Util:CreateInstance("Frame", {
      Name = "mainFrame",
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      Size = UDim2.new(0.985, 0, 0.96, 0),
      BackgroundTransparency = 0.0,
      BackgroundColor3 = Themes[Themes.CurrentTheme].Color,
      BorderSizePixel = 0,
      Active = true,
      Visible = true,
    }, outerFrame)
  local innerUiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(0, 20),
    }, mainFrame)

  return mainFrame, outerFrame
end

function FrameFactory.GetLargeLobbyFrame()
  return FrameFactory.GetDefaultLobbyFrame(UDim2.new(0.6, 0, 0.7, 0))
end

return FrameFactory

