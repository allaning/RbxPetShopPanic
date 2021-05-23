-- Show main lobby gui, e.g. avatar icon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)
local StarterGui = game:GetService("StarterGui")
local AvatarGui = require(StarterGui.AvatarGui)

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

local avatarFrame = nil


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
        Size = UDim2.new(1.0, 0, 1.0, 0),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = avatarIconId,
        BackgroundTransparency = 1.0,
      }, lobbyFrame)
    avatarFrame = AvatarGui.Initialize()
    avatarFrame.Parent = lobbyScreenGui
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
  AvatarGui.Toggle()
  SoundModule.PlayMouseClick(PlayerGui)
end
avatarIcon.Activated:Connect(onAvatarIconClick)

local function hideAvatarGui()
  AvatarGui.Close()
end
UpdateCharacterEvent.OnClientEvent:Connect(hideAvatarGui)


-- Start by showing lobby gui
showLobbyGui()

