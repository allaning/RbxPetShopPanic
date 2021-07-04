local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local Util = require(ReplicatedStorage.Util)


local FONT_COLOR_DEFAULT = Color3.fromRGB(255, 0, 0)
local FONT_BORDER_COLOR_DEFAULT = Color3.fromRGB(170, 0, 0)


local ArrowGui = {}

function ArrowGui.GetRetroArrowFrame()
  local arrowFrame = Util:CreateInstance("Frame", {
      Name = "ArrowFrame",
      AnchorPoint = Vector2.new(0.5, 0.5),
      BackgroundTransparency = 1.0,
    }, nil)
  local textLabel = Util:CreateInstance("TextLabel", {
      Text = "-->",
      Font = Enum.Font.RobotoCondensed,
      Size = UDim2.new(1.0, 0, 1.0, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 0.0,
      TextScaled = true,
      BackgroundTransparency = 1.0,
    }, arrowFrame)

  return arrowFrame, textLabel
end

return ArrowGui

