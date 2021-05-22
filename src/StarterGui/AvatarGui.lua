local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)

local AvatarGui = {}

AvatarGui.Frame = nil

function AvatarGui.Initialize()
  if not AvatarGui.Frame then
    AvatarGui.Frame = Util:CreateInstance("Frame", {
        Name = "AvatarGui.Frame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.6, 0, 0.5, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Color3.fromRGB(19, 153, 255),
        BorderSizePixel = 0,
        Active = false,
        Visible = false,
      }, nil)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 20),
      }, AvatarGui.Frame)

    -- Inner frame
    local innerFrame = Util:CreateInstance("Frame", {
        Name = "innerFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.985, 0, 0.96, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Active = true,
        Visible = true,
        ZIndex = 2,
      }, AvatarGui.Frame)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 20),
      }, innerFrame)
  end
  return AvatarGui.Frame
end

function AvatarGui.Open()
  if not AvatarGui.Frame then
    AvatarGui.Initialize()
  end
  AvatarGui.Frame.Active = true
  AvatarGui.Frame.Visible = true
end

function AvatarGui.Close()
  if not AvatarGui.Frame then
    AvatarGui.Initialize()
  end
  AvatarGui.Frame.Active = false
  AvatarGui.Frame.Visible = false
end

function AvatarGui.Toggle()
  if AvatarGui.Frame.Active == true then
    AvatarGui.Frame.Active = false
    AvatarGui.Frame.Visible = false
  else
    AvatarGui.Frame.Active = true
    AvatarGui.Frame.Visible = true
  end
end

return AvatarGui

