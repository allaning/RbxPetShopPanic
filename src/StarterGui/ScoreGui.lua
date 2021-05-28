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


local STAR_IMAGE_ID = "rbxassetid://6865524956"  -- https://iconarchive.com/show/small-n-flat-icons-by-paomedia/star-icon.html
local BLANK_STAR_IMAGE_ID = "rbxassetid://6865980124"


local ScoreGui = {}

ScoreGui.Frame = nil
ScoreGui.OuterFrame = nil
ScoreGui.BackgroundFrame = nil

local function getIcon(imageId, parent)
  local pointsIcon = Util:CreateInstance("ImageLabel", {
      Name = "StarIcon",
      Image = imageId,
      AnchorPoint = Vector2.new(0.5, 0.5),
      Size = UDim2.new(0.2, 0, 0.2, 0),
      SizeConstraint = Enum.SizeConstraint.RelativeYY,
      BackgroundTransparency = 1.0,
      BorderSizePixel = 0,
    }, parent)
  return pointsIcon
end

function ScoreGui.GetCopy(pointsEarned, numTotal, numCompleted, numFailed)
  if pointsEarned then
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

    -- TODO show stars
    -- Points Frame
    zIndex += 1
    local pointsFrame = Util:CreateInstance("Frame", {
        Name = "PointsFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.75, 0, 0.5, 0),
        Size = UDim2.new(0.45, 0, 0.9, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
        BorderSizePixel = 0,
        --BorderColor3 = Themes[Themes.CurrentTheme].BorderColor,
        ZIndex = zIndex,
      }, ScoreGui.Frame)
    local uiCornerPointsFrame = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
      }, pointsFrame)

    -- Points Title
    zIndex += 1
    local pointsTitle = Util:CreateInstance("TextLabel", {
        Name = "PointsTitle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.14, 0),
        Size = UDim2.new(0.5, 0, 0.18, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "STARS",
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
        ZIndex = zIndex,
      }, pointsFrame)

    -- Num total
    zIndex += 1
    local pointsTitle = Util:CreateInstance("TextLabel", {
        Name = "NumTotal",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.34, 0),
        Size = UDim2.new(0.6, 0, 0.1, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "Number Possible: ".. tostring(numTotal),
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
        ZIndex = zIndex,
      }, pointsFrame)

    -- Num completed
    zIndex += 1
    local pointsTitle = Util:CreateInstance("TextLabel", {
        Name = "NumCompleted",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.44, 0),
        Size = UDim2.new(0.7, 0, 0.1, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "Number Completed: ".. tostring(numCompleted),
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
        ZIndex = zIndex,
      }, pointsFrame)

    -- Num failed
    zIndex += 1
    local pointsTitle = Util:CreateInstance("TextLabel", {
        Name = "NumFailed",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.54, 0),
        Size = UDim2.new(0.52, 0, 0.1, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "Number Failed: ".. tostring(numFailed),
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
        ZIndex = zIndex,
      }, pointsFrame)


    -- Add star icons
    local starIconId = BLANK_STAR_IMAGE_ID
    local starPositionsX = { 0.25, 0.5, 0.75 }

    zIndex += 1
    if pointsEarned >= 1 then
      starIconId = STAR_IMAGE_ID
    else
      starIconId = BLANK_STAR_IMAGE_ID
    end
    local pointsIcon = getIcon(starIconId, pointsFrame)
    pointsIcon.Position = UDim2.new(starPositionsX[1], 0, 0.8, 0)
    pointsIcon.ZIndex = zIndex

    zIndex += 1
    if pointsEarned >= 2 then
      starIconId = STAR_IMAGE_ID
    else
      starIconId = BLANK_STAR_IMAGE_ID
    end
    local pointsIcon = getIcon(starIconId, pointsFrame)
    pointsIcon.Position = UDim2.new(starPositionsX[2], 0, 0.8, 0)
    pointsIcon.ZIndex = zIndex

    zIndex += 1
    if pointsEarned >= 3 then
      starIconId = STAR_IMAGE_ID
    else
      starIconId = BLANK_STAR_IMAGE_ID
    end
    local pointsIcon = getIcon(starIconId, pointsFrame)
    pointsIcon.Position = UDim2.new(starPositionsX[3], 0, 0.8, 0)
    pointsIcon.ZIndex = zIndex


    -- OK button
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
    local okBtnShadow = Util:CreateInstance("TextLabel", {
        Name = "OK Button Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.505, 0, 0.87, 0),
        Size = UDim2.new(0.12, 0, 0.07, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Color3.fromRGB(149, 8, 8),
        BorderSizePixel = 0,
        ZIndex = zIndex - 1,
      }, ScoreGui.BackgroundFrame)
    local uiCornerShadow = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
      }, okBtnShadow)

  end
  return ScoreGui.BackgroundFrame
end

return ScoreGui
