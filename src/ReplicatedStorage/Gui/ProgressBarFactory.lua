-- Creates progress bars
-- https://devforum.roblox.com/t/customizable-health-bar/1065326


local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)

local backgroundTransparency = 0.5
local frameXPosition = 0
local textSize = 16
local backgroundColor = Color3.new(0, 0, 0)
local textColor = Color3.fromRGB(243, 243, 243)


local ProgressBarFactory = {}


function ProgressBarFactory.TweenAutoProgressBar(billboardGui, timeSec)
  local progressBar = billboardGui:FindFirstChild("ProgressBar")
  if progressBar then
    -- Move gradient position
    local uiGradient = progressBar:FindFirstChild("UIGradient")
    if uiGradient then
      local animTweenInfo = TweenInfo.new(timeSec, Enum.EasingStyle["Linear"])
      TweenService:Create(uiGradient, animTweenInfo, {Offset = Vector2.new(1, 0)}):Play() -- move gradient
    end
  end
end

--[[
  BillboardGui (Name: "ProgressBarBillboardGui")
    +- Frame (Name: "ProgressBar")
        +- UIGradient
        +- TextLabel
]]--
function ProgressBarFactory.GetAutoProgressBar(timeSec)
  -- Create BillboardGui
  local billboardGui = Util:CreateInstance("BillboardGui", {
      Name = "ProgressBarBillboardGui",
      Size = UDim2.new(4, 0, 1, 0),
      ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, nil)

  -- Create progress bar frame
  local progressBar = Util:CreateInstance("Frame", {
      Name = "ProgressBar",
      Size = UDim2.new(1, 0, 1, 0),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      AnchorPoint = Vector2.new(0.5, 0.5),
      BackgroundColor3 = Color3.new(1, 1, 1),
      --BorderMode = Enum.BorderMode["Outline"],
      --BorderColor3 = Color3.new(1, 1, 1),
      --BorderSizePixel = 2
    }, billboardGui)

  -- Create UICorner (if corner radius is not 0)
  local cornerRadius = UDim.new(0, 8)
  if cornerRadius.Scale ~= 0 or cornerRadius.Offset ~= 0 then
    Util:CreateInstance("UICorner", {CornerRadius = cornerRadius}, progressBar)
  end

  -- Create UIGradient
  local uiGradient = Util:CreateInstance("UIGradient", {
      Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)),
          ColorSequenceKeypoint.new(0.001, backgroundColor),
          ColorSequenceKeypoint.new(1, backgroundColor)
        }),
      Transparency = NumberSequence.new({
          NumberSequenceKeypoint.new(0, 0.3),
          NumberSequenceKeypoint.new(0.001, backgroundTransparency),
          NumberSequenceKeypoint.new(1, backgroundTransparency)
        }),
      Offset = Vector2.new(0, 0)
    }, progressBar)

  -- Create TextLabel for current progress
  local uiTextLabel = Util:CreateInstance("TextLabel", {
      Size = UDim2.new(0, 100, 1, 0),
      Position = UDim2.new(1, -8, 0, 0),
      AnchorPoint = Vector2.new(1, 0),
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Text = "", -- Text to overlay on progress bar
      TextColor3 = textColor,
      TextSize = textSize,
      Font = font,
      TextXAlignment = Enum.TextXAlignment.Right
    }, progressBar)

  return billboardGui
end


return ProgressBarFactory
