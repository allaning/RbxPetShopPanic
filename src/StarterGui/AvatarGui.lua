local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local ViewportFrameFactory = require(ReplicatedStorage.Gui.ViewportFrameFactory)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)

local StarterGui = game:GetService("StarterGui")
local FrameFactory = require(StarterGui.FrameFactory)

local SelectCharacterRequestEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectCharacterRequest")
local UpdateCharacterEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateCharacter")

local CharacterFolder = ReplicatedStorage:WaitForChild("Characters")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local CHARACTER_THUMB_SIZE_SCALE_X = 0.30
local CHARACTER_THUMB_SIZE_SCALE_Y = 0.40

local AvatarGui = {}

AvatarGui.Frame = nil
AvatarGui.OuterFrame = nil

function AvatarGui.Initialize()
  if not AvatarGui.Frame then
    AvatarGui.Frame, AvatarGui.OuterFrame = FrameFactory.GetDefaultLobbyFrame()
    AvatarGui.Frame.Name = "AvatarGui.Frame"
    AvatarGui.OuterFrame.Name = "AvatarGui.OuterFrame"

    -- Title
    local title = Util:CreateInstance("TextLabel", {
        Name = "Avatar",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.1, 0),
        Size = UDim2.new(0.3, 0, 0.12, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "AVATAR",
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
      }, AvatarGui.Frame)

    -- Scrolling frame
    local scrollingFrame = Util:CreateInstance("ScrollingFrame", {
        Name = "Characters",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.335, 0, 0.55, 0),
        Size = UDim2.new(0.58, 0, 0.7, 0),
        CanvasSize = UDim2.new(0, 0, 2.0, 0),  -- TODO: Increase Y
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
        BorderSizePixel = 2,
        BorderColor3 = Themes[Themes.CurrentTheme].BorderColor,
        ScrollBarImageColor3 = Themes[Themes.CurrentTheme].BorderColor,
      }, AvatarGui.Frame)
    local uiGridLayout = Util:CreateInstance("UIGridLayout", {
        CellSize = UDim2.new(CHARACTER_THUMB_SIZE_SCALE_X, 0, CHARACTER_THUMB_SIZE_SCALE_Y, 0),
      }, scrollingFrame)

    -- Info frame
    local infoFrame = Util:CreateInstance("Frame", {
        Name = "Info",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.8, 0, 0.55, 0),
        Size = UDim2.new(0.3, 0, 0.7, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
        BorderSizePixel = 0,
      }, AvatarGui.Frame)
    local charTitle = Util:CreateInstance("TextLabel", {
        Name = "CharacterTitle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.2, 0),
        Size = UDim2.new(0.8, 0, 0.2, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "",  -- This will be set to the selected model name and used in the remote event
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
      }, infoFrame)
    local charEquipBtn = Util:CreateInstance("TextButton", {
        Name = "EquipCharacter",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.8, 0),
        Size = UDim2.new(0.5, 0, 0.2, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Themes[Themes.CurrentTheme].BorderColor,
        BorderSizePixel = 0,
        Text = "   MORPH   ",
        Font = Enum.Font.Bangers,
        TextColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
        TextScaled = true,
      }, infoFrame)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
      }, charEquipBtn)

    -- Add character buttons
    for idx, model in pairs(CharacterFolder:GetChildren()) do
      --print("CharacterFolder: ".. model.Name)
      local charFrame = Util:CreateInstance("Frame", {
          Name = model.Name.. "Frame",
          BackgroundTransparency = 1.0,
        }, scrollingFrame)
      local viewport = ViewportFrameFactory.GetViewportFrame(model, Vector3.new(0, 2.5, -6.0))
      viewport.Parent = charFrame

      local charButton = Util:CreateInstance("TextButton", {
          Name = "Button",
          Position = UDim2.new(0.0, 0, 0.0, 0),
          Size = UDim2.new(1.0, 0, 1.0, 0),
          Transparency = 1.0,
        }, charFrame)
      charButton.Activated:Connect(function()
          charTitle.Text = model.Name
          SoundModule.PlayMouseClick(PlayerGui)

          charEquipBtn.Activated:Connect(function()
            SoundModule.PlayMouseClick(PlayerGui)
            SelectCharacterRequestEvent:FireServer(charTitle.Text)
          end)
        end)
    end  -- CharacterFolder

  end
  return AvatarGui.OuterFrame
end

function AvatarGui.Open()
  if not AvatarGui.Frame then
    AvatarGui.Initialize()
  end
  AvatarGui.OuterFrame.Active = true
  AvatarGui.OuterFrame.Visible = true
end

function AvatarGui.Close()
  if not AvatarGui.Frame then
    AvatarGui.Initialize()
  end
  AvatarGui.OuterFrame.Active = false
  AvatarGui.OuterFrame.Visible = false
end

function AvatarGui.Toggle()
  if AvatarGui.OuterFrame.Active == true then
    AvatarGui.OuterFrame.Active = false
    AvatarGui.OuterFrame.Visible = false
  else
    AvatarGui.OuterFrame.Active = true
    AvatarGui.OuterFrame.Visible = true
  end
end

return AvatarGui

