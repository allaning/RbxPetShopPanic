local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local Util = require(ReplicatedStorage.Util)


local FONT_COLOR_DEFAULT = Color3.fromRGB(255, 255, 0)
local FONT_BORDER_COLOR_DEFAULT = Color3.fromRGB(170, 170, 0)


local LoadingGui = {}

function LoadingGui.GetLoadingFrame()
  local loadingGui = Util:CreateInstance("ScreenGui", {
      Name = "LoadingGui",
    }, nil)
  local textLabel = Util:CreateInstance("TextLabel", {
      Text = "Loading map...",
      Font = Enum.Font.Bangers,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.4, 0),
      Size = UDim2.new(0.4, 0, 0.2, 0),
      TextColor3 = FONT_COLOR_DEFAULT,
      TextStrokeColor3 = FONT_BORDER_COLOR_DEFAULT,
      TextStrokeTransparency = 0.0,
      TextScaled = true,
      BackgroundTransparency = 1.0,
    }, loadingGui)

  return loadingGui
end

return LoadingGui

