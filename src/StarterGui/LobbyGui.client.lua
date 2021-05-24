-- Show main lobby gui, e.g. avatar icon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)
local StarterGui = game:GetService("StarterGui")
local AvatarGui = require(StarterGui.AvatarGui)
local PlayGui = require(StarterGui.PlayGui)
local UserThumbnailGui = require(StarterGui.UserThumbnailGui)
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)

local SelectLevelRequestSentEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectLevelRequestSent")
local LevelRequestVotesEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LevelRequestVotes")
local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local UpdateCharacterEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateCharacter")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Folder to hold UserThumbnailGui images
local UserThumbsFolder = Instance.new("Folder", PlayerGui)
UserThumbsFolder.Name = "UserThumbsFolder"

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
    TweenGuiFactory.ChangeScale(uiScaleInstance, 1.05, 0.01, Enum.EasingStyle.Linear, Enum.EasingDirection.In, false)
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
        Position = UDim2.new(0.91, 0, 0.34, 0),
        Size = UDim2.new(0.14, 0, 0.34, 0),
        BackgroundTransparency = 0.0,
        BackgroundColor3 = Color3.fromRGB(65, 65, 65),
        BorderSizePixel = 0,
      }, lobbyScreenGui)
    local uiCorner = Util:CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 20),
      }, lobbyFrame)
    avatarIcon = Util:CreateInstance("ImageButton", {
        Name = "AvatarIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.32, 0, 0.27, 0),
        Size = UDim2.new(0.42, 0, 0.42, 0),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = avatarIconId,
        BackgroundTransparency = 1.0,
      }, lobbyFrame)
    local avatarIconScale = Util:CreateInstance("UIScale", {
        Scale = 1.0,
      }, avatarIcon)
    playIcon = Util:CreateInstance("ImageButton", {
        Name = "PlayIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.32, 0, 0.72, 0),
        Size = UDim2.new(0.42, 0, 0.42, 0),
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



-- See Game.server.lua for playerLevelVotes format
local function onLevelRequestVotesEvent(playerLevelVotes)
  print("Received LevelRequestVotesEvent")
  if false then -- Debug
    for _, pv in pairs(playerLevelVotes) do
      print(string.format("  playerLevelVotes: Player %s (%d) votes for %s", pv['PlayerName'], pv['PlayerId'], pv['LevelVote']))
    end
  end

  -- Create sorted list of player names and another list with corresponding user IDs
  local playerNames = {}
  for _, plr in pairs(Players:GetPlayers()) do
    table.insert(playerNames, plr.Name)
  end
  table.sort(playerNames)

  -- Show user vote thumbnails
  local POS_Y = 0.7
  local posOrderedListScaleX = { 0.4, 0.55, 0.25, 0.7 }
  local currentPosX = 1
  for idx, playerVote in pairs(playerLevelVotes) do
    local plrName = playerVote['PlayerName']
    local plrId = playerVote['PlayerId']
    local screenGui = Util:CreateInstance("ScreenGui", {
        Name = plrName.."UserVoteScreenGui",
      }, UserThumbsFolder)
    local thumb = UserThumbnailGui.GetThumbnail(plrName, plrId)
    thumb.Parent = screenGui
    thumb.Position = UDim2.new(posOrderedListScaleX[currentPosX], 0, POS_Y, 0)
    currentPosX += 1
  end

  -- TODO

end
LevelRequestVotesEvent.OnClientEvent:Connect(onLevelRequestVotesEvent)

