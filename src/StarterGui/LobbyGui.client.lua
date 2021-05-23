-- Show main lobby gui, e.g. avatar icon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)
local StarterGui = game:GetService("StarterGui")
local AvatarGui = require(StarterGui.AvatarGui)
local PlayGui = require(StarterGui.PlayGui)
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)

local SelectLevelRequestSentEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectLevelRequestSent")
local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local UpdateCharacterEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateCharacter")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local lobbyScreenGui = nil
local lobbyFrame = nil
local avatarIcon = nil
local avatarIconId = "rbxassetid://6847150302"  -- https://icon-icons.com/icon/avatar-default-user/92824
local playIcon = nil
local playIconId = "rbxassetid://6855026893"  -- https://graphiccave.com/project/play-icon-vector-and-png-free-download/

local lobbyFrames = {
  avatarFrame = nil,
  playFrame = nil,
}


local function addEnlargeOnMouseHover(parent, uiScaleInstance)
  parent.MouseEnter:Connect(function()
    TweenGuiFactory.ChangeScale(uiScaleInstance, 1.1, 0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.In, false)
  end)
  parent.MouseLeave:Connect(function()
    TweenGuiFactory.ChangeScale(uiScaleInstance, 1.0, 0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.In, false)
  end)
end

local function initializeLobbyGui()
  if not lobbyScreenGui then
    lobbyScreenGui = Util:CreateInstance("ScreenGui", {
        Name = "LobbyScreenGui",
      }, PlayerGui)
    lobbyFrame = Util:CreateInstance("Frame", {
        Name = "ButtonsFrame",
        Position = UDim2.new(0.92, 0, 0.4, 0),
        Size = UDim2.new(0.12, 0, 0.12, 0),
        BackgroundTransparency = 1.0,
        BorderSizePixel = 0,
      }, lobbyScreenGui)
    avatarIcon = Util:CreateInstance("ImageButton", {
        Name = "AvatarIcon",
        AnchorPoint = Vector2.new(0.5, 0, 0.5, 0),
        Position = UDim2.new(0.25, 0, 0, 0),
        Size = UDim2.new(1.0, 0, 1.0, 0),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = avatarIconId,
        BackgroundTransparency = 1.0,
      }, lobbyFrame)
    local avatarIconScale = Util:CreateInstance("UIScale", {
        Scale = 1.0,
      }, avatarIcon)
    playIcon = Util:CreateInstance("ImageButton", {
        Name = "PlayIcon",
        AnchorPoint = Vector2.new(0.5, 0, 0.5, 0),
        Position = UDim2.new(0.25, 0, 1.1, 0),
        Size = UDim2.new(1.0, 0, 1.0, 0),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = playIconId,
        BackgroundTransparency = 1.0,
      }, lobbyFrame)
    local playIconScale = Util:CreateInstance("UIScale", {
        Scale = 1.0,
      }, playIcon)

    addEnlargeOnMouseHover(avatarIcon, avatarIconScale)
    addEnlargeOnMouseHover(playIcon, playIconScale)

    lobbyFrames.avatarFrame = AvatarGui.Initialize()
    lobbyFrames.playFrame = PlayGui.Initialize()
    lobbyFrames.avatarFrame.Parent = lobbyScreenGui
    lobbyFrames.playFrame.Parent = lobbyScreenGui
  end
end

local function showLobbyGui()
  lobbyScreenGui.Enabled = true
end
SessionEndedEvent.OnClientEvent:Connect(showLobbyGui)

local function hideLobbyGui()
  lobbyScreenGui.Enabled = false
  AvatarGui.Close()
end
SessionCountdownBeginEvent.OnClientEvent:Connect(hideLobbyGui)


initializeLobbyGui()


local function onAvatarIconClick()
  PlayGui.Close()
  AvatarGui.Toggle()
  SoundModule.PlayMouseClick(PlayerGui)
end
avatarIcon.Activated:Connect(onAvatarIconClick)

local function hideAvatarGui()
  AvatarGui.Close()
end
UpdateCharacterEvent.OnClientEvent:Connect(hideAvatarGui)

local function onPlayIconClick()
  AvatarGui.Close()
  PlayGui.Toggle()
  SoundModule.PlayMouseClick(PlayerGui)
end
playIcon.Activated:Connect(onPlayIconClick)

local function hidePlayGui()
  PlayGui.Close()
end
SelectLevelRequestSentEvent.Event:Connect(hidePlayGui)


-- Start by showing lobby gui
showLobbyGui()

