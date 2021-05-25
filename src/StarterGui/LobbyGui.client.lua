-- Show main lobby gui, e.g. avatar icon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Globals = require(ReplicatedStorage.Globals)

local StarterGui = game:GetService("StarterGui")
local AvatarGui = require(StarterGui.AvatarGui)
local PlayGui = require(StarterGui.PlayGui)
local UserThumbnailGui = require(StarterGui.UserThumbnailGui)
local ScoreGui = require(StarterGui.ScoreGui)
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)

local SelectLevelRequestSentEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectLevelRequestSent")
local LevelRequestVotesEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LevelRequestVotes")
local SessionMapLevelSelectedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionMapLevelSelected")
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


-- Show score gui on top of other guis
local function showScoreGui()
  local scoreScreenGui = Util:CreateInstance("ScreenGui", {
      Name = "ScoreScreenGui",
      DisplayOrder = 1,
    }, PlayerGui)
  local scoreGui = ScoreGui.GetCopy()
  scoreGui.Parent = scoreScreenGui 
end


local function showLobbyGui()
  lobbyScreenGui.Enabled = true
end

local function showScoreAndLobbyGui()
  showScoreGui()
  showLobbyGui()
end
SessionEndedEvent.OnClientEvent:Connect(showScoreAndLobbyGui)

local function hideLobbyGui()
  lobbyScreenGui.Enabled = false
  AvatarGui.Close()

  -- Remove vote thumbnails
  for _, obj in pairs(UserThumbsFolder:GetChildren()) do
    obj:Destroy()
  end
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



-- Find Id from Name based on table of this format:
-- { { ['PlayerName'] = plr.Name, ['PlayerId'] = plr.UserId }, }
local function getPlayerIdFromName(nameToIdMap, playerName)
  for _, pair in pairs(nameToIdMap) do
    if pair['PlayerName'] == playerName then
      return pair['PlayerId']
    end
  end
  return Globals.UNINIT_NUMBER
end

-- Holds the thumbnail position order based on number of players in game
local posOrderedListScaleX = {
  { 0.5 },
  { 0.4, 0.55 },
  { 0.35, 0.5, 0.65 },
  { 0.25, 0.4, 0.55, 0.7 },
}

-- Last votes
local playerLevelVotesPrevious = {}

-- See Game.server.lua for playerLevelVotes format
local function onLevelRequestVotesEvent(playerLevelVotes)
  print("Received LevelRequestVotesEvent")

  -- If this was triggered by a new player, then use the last vote info
  if not playerLevelVotes then
    playerLevelVotes = Util:DeepTableCopy(playerLevelVotesPrevious)
  end

  if true then -- Debug
    for _, pv in pairs(playerLevelVotes) do
      print(string.format("  playerLevelVotes: Player %s (%d) votes for %s", pv['PlayerName'], pv['PlayerId'], pv['LevelVote']))
    end
  end

  -- Save votes
  playerLevelVotesPrevious = Util:DeepTableCopy(playerLevelVotes)

  -- Create sorted list of player names and another list with corresponding user IDs
  local playerNames = {}
  local playerNameToIdMap = {}
  for _, plr in pairs(Players:GetPlayers()) do
    table.insert(playerNames, plr.Name)
    table.insert(playerNameToIdMap, { ['PlayerName'] = plr.Name, ['PlayerId'] = plr.UserId } )
    --table.insert(playerNameToIdMap, { ['PlayerName'] = "WhoooDattt".."2", ['PlayerId'] = plr.UserId } )--aing
  end
  --table.insert(playerNames, "WhoooDattt".."2") --aing
  --table.insert(playerNames, "WhoooDattt".."3") --aing
  --table.insert(playerNames, "WhoooDattt".."4") --aing
  table.sort(playerNames)

  -- Show user vote thumbnails
  local POS_Y = 0.78
  local currentPosX = 1
  for idx = 1, #playerNames do
    Promise.try(function()
      local currentPlayerName = playerNames[idx]
      local playerVote = nil
      -- Find player vote
      for _, voteInfo in pairs(playerLevelVotes) do
        if currentPlayerName == voteInfo['PlayerName'] then
          playerVote = voteInfo
          break
        end
      end
      local plrName = currentPlayerName
      local plrId = getPlayerIdFromName(playerNameToIdMap, currentPlayerName)
      if playerVote then
        plrName = playerVote['PlayerName']
        plrId = playerVote['PlayerId']
      end
      --if currentPlayerName == "WhoooDattt3" then--aing
      --  plrId = getPlayerIdFromName(playerNameToIdMap, "WhoooDattt")--aing
      --  print("    ".. currentPlayerName.. " plrId=".. tostring(plrId))--aing
      --end--aing
      local screenGui = Util:CreateInstance("ScreenGui", {
          Name = plrName,
        }, nil)
      local thumb = UserThumbnailGui.GetThumbnail(plrName, plrId)
      if thumb then
        -- Show vote
        local voteText = "_"
        local voteTextColor = Color3.fromRGB(143, 143, 143)
        if playerVote then
          voteText = playerVote['LevelVote']
          voteTextColor = Color3.fromRGB(0, 255, 127)
        end
        local voteTextLabel = Util:CreateInstance("TextLabel", {
            Name = "Vote",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 1.2, 0),
            Size = UDim2.new(1.4, 0, 0.3, 0),
            BackgroundTransparency = 1.0,
            TextScaled = true,
            Text = "Vote: ".. voteText,
            TextColor3 = voteTextColor,
            Font = Enum.Font.FredokaOne,
            ZIndex = 2,
          }, thumb)
        local voteTextBackground = Util:CreateInstance("Frame", {
            Name = "VoteBgFrame",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 1.2, 0),
            Size = UDim2.new(1.8, 0, 0.3, 0),
            BackgroundTransparency = 0.0,
            BackgroundColor3 = Color3.fromRGB(22, 150, 0),
            ZIndex = 1,
            Visible = false,
          }, thumb)
        local uiCorner = Util:CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 25),
          }, voteTextBackground)

        -- Remove old thumbnail
        local oldThumb = UserThumbsFolder:FindFirstChild(plrName)
        if oldThumb then
          oldThumb:Destroy()
        end
        -- Add new thumbnail to screen
        screenGui.Parent = UserThumbsFolder
        thumb.Position = UDim2.new(posOrderedListScaleX[#playerNames][currentPosX], 0, POS_Y, 0)
        thumb.Parent = screenGui
      end

      currentPosX += 1
    end)
  end

end
LevelRequestVotesEvent.OnClientEvent:Connect(onLevelRequestVotesEvent)


-- Make random frames visible
local function showRandomFrames(frameList, frequency, durationSec)
  --print("In showRandomFrames")
  local rand = Random.new()
  local isActive = true
  Promise.try(function()
    while isActive do
      local randIdx = rand:NextInteger(1, #frameList)
      for idx = 1, #frameList do
        if idx == randIdx then
          frameList[idx].Visible = true
        else
          frameList[idx].Visible = false
        end
      end
      Util:RealWait(1/frequency)
    end
  end)
  Util:RealWait(durationSec)
  isActive = false

  -- Make all invisible
  for idx = 1, #frameList do
    frameList[idx].Visible = false
  end
end

-- Show random vote being selected...
local function onSessionMapLevelSelectedEvent(playerName, winningLevel)
  --print("In onSessionMapLevelSelectedEvent")
  -- Find the thumbnails and put the voting background into a list
  local voteFrameList = {}
  local winningFrameIdx = Globals.UNINIT_NUMBER
  local thumbScreenGuis = UserThumbsFolder:GetChildren()
  for idx, thumb in pairs(thumbScreenGuis) do
    local thumbFrame = thumb:WaitForChild(UserThumbnailGui.MainFrameName, 0.1)
    if thumbFrame then
      local voteFrame = thumbFrame:WaitForChild(UserThumbnailGui.VoteFrameName, 0.1)
      if voteFrame then
        table.insert(voteFrameList, voteFrame)

        -- Check if this is the winner
        if playerName == thumb.Name then
          winningFrameIdx = idx  -- This is the frame that won
          --print("Winner: ".. thumb.Name)
        end
      end
    end
  end

  -- Highlight random votes
  local timePerPhase = Globals.RANDOM_LEVEL_SELECTION_DISPLAY_DELAY_SEC / 4
  local frequency = timePerPhase * 18

  -- Show shuffling random votes in descending frequency
  showRandomFrames(voteFrameList, frequency, timePerPhase)
  frequency = timePerPhase * 10
  showRandomFrames(voteFrameList, frequency, timePerPhase)
  frequency = timePerPhase * 6
  showRandomFrames(voteFrameList, frequency, timePerPhase)
  -- Hold winner visible
  voteFrameList[winningFrameIdx].Visible = true

end
SessionMapLevelSelectedEvent.OnClientEvent:Connect(onSessionMapLevelSelectedEvent)

