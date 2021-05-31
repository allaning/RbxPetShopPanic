-- Avatars
--[[
Avatar rules:
  - Should be in ReplicatedStorage/Characters/XX_Description
  - Top level must be a Character with PrimaryPart HumanoidRootPart
  - Optional: Add a Number Attribute named CostPoints to specify Points required to equip Character
  - Optional: Add a Number Attribute named CostRobux to specify Robux required to buy Character
  - Optional: Add Vector3 Attribute named ViewportCameraPosition to specify custom position for ViewportFrame Camera
  - Optional: Add Vector3 Attribute named ViewportTargetPositionOffset to specify target position offset for ViewportFrame Camera
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local ViewportFrameFactory = require(ReplicatedStorage.Gui.ViewportFrameFactory)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Avatars = require(ReplicatedStorage.Avatars)
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
local CHARACTER_THUMB_SIZE_SCALE_Y = 0.1


local AvatarGui = {}


AvatarGui.Frame = nil
AvatarGui.OuterFrame = nil

function AvatarGui.Initialize()
  if not AvatarGui.Frame then
    AvatarGui.Frame, AvatarGui.OuterFrame = FrameFactory.GetLargeLobbyFrame()
    AvatarGui.Frame.Name = "AvatarGui.Frame"
    AvatarGui.OuterFrame.Name = "AvatarGui.OuterFrame"
    AvatarGui.OuterFrame.Position = UDim2.new(0.5, 0, 0.4, 0)

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
        CanvasSize = UDim2.new(0, 0, 4.0, 0),  -- TODO: Increase Y
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
        BorderSizePixel = 2,
        BorderColor3 = Themes[Themes.CurrentTheme].BorderColor,
        ScrollBarImageColor3 = Themes[Themes.CurrentTheme].BorderColor,
      }, AvatarGui.Frame)
    local uiGridLayout = Util:CreateInstance("UIGridLayout", {
        CellSize = UDim2.new(CHARACTER_THUMB_SIZE_SCALE_X, 0, CHARACTER_THUMB_SIZE_SCALE_Y, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
      }, scrollingFrame)

    -- Add character buttons
    -- Get sorted list of subdirectories
    local subdirNameList = {}
    for _, subdir in pairs(CharacterFolder:GetChildren()) do
      table.insert(subdirNameList, subdir.Name)
    end
    table.sort(subdirNameList)
    local layoutOrder = 1  -- Specify order for UIGridLayout
    for subdirIdx = 1, #subdirNameList do
      local subdirCharacters = CharacterFolder:WaitForChild(subdirNameList[subdirIdx]):GetChildren()
      for idx = 1, #subdirCharacters do
        --print("CharacterFolder: ".. model.Name)
        local model = subdirCharacters[idx]
        local charFrame = Util:CreateInstance("Frame", {
            Name = model.Name.. "Frame",
            BackgroundTransparency = 1.0,
            LayoutOrder = layoutOrder,
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
            local infoFrameName = "Info"
            -- Remove old Info frames
            local oldInfoFrame = AvatarGui.Frame:FindFirstChild(infoFrameName)
            if oldInfoFrame then
              oldInfoFrame:Destroy()
            end

            -- Info frame
            local infoFrame = Util:CreateInstance("Frame", {
                Name = infoFrameName,
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
                TextColor3 = Themes[Themes.CurrentTheme].TextColor2,
                Font = Enum.Font.FredokaOne,
              }, infoFrame)
            local charDescription = Util:CreateInstance("TextLabel", {
                Name = "CharacterDescription",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0.85, 0, 0.2, 0),
                BackgroundTransparency = 1.0,
                TextColor3 = Themes[Themes.CurrentTheme].TextColor,
                Font = Enum.Font.FredokaOne,
                TextScaled = true,
                --TextSize = 22,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Text = "",  -- This will be set when a character icon is clicked
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

            charTitle.Text = model.Name
            SoundModule.PlayMouseClick(PlayerGui)

            -- Check for requirements
            local costPoints = model:GetAttribute(Avatars.COST_POINTS_ATTR_NAME)
            if costPoints then
              charDescription.Text = "Stars needed: ".. tostring(costPoints).. "\n"
            end
            local costRobux = model:GetAttribute(Avatars.COST_ROBUX_ATTR_NAME)
            if costRobux then
              charDescription.Text = charDescription.Text.. "Robux: ".. tostring(costRobux).. "\n"
            end

            charEquipBtn.Activated:Connect(function()
              SoundModule.PlayMouseClick(PlayerGui)
              SelectCharacterRequestEvent:FireServer(subdirNameList[subdirIdx], charTitle.Text)
              --print(string.format("SelectCharacterRequestEvent:FireServer(subdirNameList[subdirIdx] %s, charTitle.Text %s)", subdirNameList[subdirIdx], charTitle.Text))
            end)
          end)
        layoutOrder += 1
      end
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

