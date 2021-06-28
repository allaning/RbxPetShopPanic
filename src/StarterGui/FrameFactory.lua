local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local StarterGui = game:GetService("StarterGui")
local AnimateText = require(StarterGui:WaitForChild("AnimateText"))

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
      Size = UDim2.new(0.985, 0, 0.97, 0),
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

function FrameFactory.GetTypedMessageFrame(message, sizeDim, color, zIndex, clickToExit)
  sizeDim = sizeDim or UDim2.new(0.3, 0, 0.3, 0)
  color = color or Color3.fromRGB(255, 255, 255)
  zIndex = zIndex or 1

  local frameOuter = Util:CreateInstance("Frame", {
      Name = "OuterMessageFrame",
      BackgroundColor3 = color,
      BorderSizePixel = 0,
      Size = sizeDim,
    }, nil)
  local uiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(0, 15),
    }, frameOuter)
  local frameInner = Util:CreateInstance("Frame", {
      Name = "InnerMessageFrame",
      BackgroundColor3 = color,
      BorderSizePixel = 0,
      Position = UDim2.new(0.12, 0, 0.05, 0),
      Size = UDim2.new(0.85, 0, 0.9, 0),
      ZIndex = zIndex,
    }, frameOuter)
  local uiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(0, 15),
    }, frameOuter)

  zIndex += 1
  if message and message ~= "" then
    local textLabel = Util:CreateInstance("TextLabel", {
        Text = "", -- message will be typed below
        Font = Enum.Font.SourceSansSemibold,
        Position = UDim2.new(0.0, 0, 0.0, 0),
        Size = UDim2.new(1.0, 0, 1.0, 0),
        BackgroundTransparency = 1.0,
        TextColor3 = Color3.new(0.2, 0.5, 0.7),
        TextScaled = true,
        RichText = true,
        ZIndex = zIndex,
      }, frameInner)
    Promise.try(function()
      -- The following call blocks, so use a Promise
      AnimateText.typeWrite(textLabel, message, 0.05)
    end)
  end

  if clickToExit then
    local exitButton = Util:CreateInstance("TextButton", {
        Name = "ExitButton",
        Position = UDim2.new(0.0, 0, 0.0, 0),
        Size = UDim2.new(1.0, 0, 1.0, 0),
        BackgroundTransparency = 1.0,
      }, frameInner)
    exitButton.Activated:Connect(function()
      frameOuter:Destroy()
    end)
  end

  return frameOuter
end

return FrameFactory

