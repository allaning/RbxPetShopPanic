local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local ViewportFrameFactory = require(ReplicatedStorage.Gui.ViewportFrameFactory)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)

local StarterGui = game:GetService("StarterGui")
local FrameFactory = require(StarterGui.FrameFactory)

local MapsFolder = Workspace:WaitForChild("Maps")

local SelectLevelRequestEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectLevelRequest")
local SelectLevelRequestSentEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectLevelRequestSent")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local LEVEL_THUMB_SIZE_Y = 60

local PlayGui = {}

PlayGui.Frame = nil
PlayGui.OuterFrame = nil

function PlayGui.Initialize()
  if not PlayGui.Frame then
    PlayGui.Frame, PlayGui.OuterFrame = FrameFactory.GetDefaultLobbyFrame()
    PlayGui.Frame.Name = "PlayGui.Frame"
    PlayGui.OuterFrame.Name = "PlayGui.OuterFrame"

    -- Title
    local title = Util:CreateInstance("TextLabel", {
        Name = "Play",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.1, 0),
        Size = UDim2.new(0.3, 0, 0.12, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "PLAY",
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
      }, PlayGui.Frame)

    -- Scrolling frame
    local scrollingFrame = Util:CreateInstance("ScrollingFrame", {
        Name = "Levels",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.58, 0),
        Size = UDim2.new(0.58, 0, 0.7, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
        BorderSizePixel = 2,
        BorderColor3 = Themes[Themes.CurrentTheme].BorderColor,
        ScrollBarImageColor3 = Themes[Themes.CurrentTheme].BorderColor,
      }, PlayGui.Frame)
    local uiListLayout = Util:CreateInstance("UIListLayout", {
        --CellSize = UDim2.new(0, LEVEL_THUMB_SIZE_X, 0, LEVEL_THUMB_SIZE_Y),
      }, scrollingFrame)

    -- Add level buttons
    local levelFolders = MapsFolder:GetChildren()
    local levelNames = {}
    -- Sort level names
    for _, levelFolder in pairs(levelFolders) do
      table.insert(levelNames, levelFolder.Name)
    end
    table.sort(levelNames)
    -- Add level names to gui
    for idx = 1, #levelNames do
      local levelButton = Util:CreateInstance("TextButton", {
          Name = levelNames[idx].."Button",
          Position = UDim2.new(0.0, 0, 0.0, 0),
          Size = UDim2.new(0.9, 0, 0, LEVEL_THUMB_SIZE_Y),
          BackgroundTransparency = 1.0,
          TextScaled = true,
          Text = levelNames[idx],
          Font = Enum.Font.FredokaOne,
          TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        }, scrollingFrame)
      levelButton.Activated:Connect(function()
          print("Clicked levelButton.Text = ".. levelButton.Text)
          SoundModule.PlayMouseClick(PlayerGui)
          SelectLevelRequestSentEvent:Fire(levelButton.Text)
          SelectLevelRequestEvent:FireServer(levelButton.Text)
        end)
    end

  end
  return PlayGui.OuterFrame
end

function PlayGui.Open()
  if not PlayGui.Frame then
    PlayGui.Initialize()
  end
  PlayGui.OuterFrame.Active = true
  PlayGui.OuterFrame.Visible = true
end

function PlayGui.Close()
  if not PlayGui.Frame then
    PlayGui.Initialize()
  end
  PlayGui.OuterFrame.Active = false
  PlayGui.OuterFrame.Visible = false
end

function PlayGui.Toggle()
  if PlayGui.OuterFrame.Active == true then
    PlayGui.OuterFrame.Active = false
    PlayGui.OuterFrame.Visible = false
  else
    PlayGui.OuterFrame.Active = true
    PlayGui.OuterFrame.Visible = true
  end
end

return PlayGui

