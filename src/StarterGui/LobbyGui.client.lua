-- Show main lobby gui, e.g. avatar icon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundModule = require(ReplicatedStorage.SoundModule)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Globals = require(ReplicatedStorage.Globals)
local Assets = require(ReplicatedStorage.Assets)

local StarterGui = game:GetService("StarterGui")
local AvatarGui = require(StarterGui.AvatarGui)
local PlayGui = require(StarterGui.PlayGui)
local UserThumbnailGui = require(StarterGui.UserThumbnailGui)
local ScoreGui = require(StarterGui.ScoreGui)
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
local FrameFactory = require(StarterGui.FrameFactory)

local GetPlayerPointsFn = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetPlayerPoints")
local GetSessionStatusFn = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetSessionStatus")
local GetNamesOfPlayersInSessionFn = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetNamesOfPlayersInSession")
local GetLevelRequestVotesFn = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetLevelRequestVotes")
local SelectLevelRequestSentEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectLevelRequestSent")
local LevelRequestVotesEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("LevelRequestVotes")
local SessionMapLevelSelectedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionMapLevelSelected")
local SessionCountdownBeginEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionCountdownBegin")
local SessionUpdateTimerCountdownEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionUpdateTimerCountdown")
local SessionEndedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionEnded")
local SessionResultsEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SessionResults")
local UpdateCharacterEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateCharacter")
local ShowMessagePopupBindableEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowMessagePopupBindable")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


-- Keep track of player status
local function setIsLocalPlayerInGameSession(isActive)
  Player:SetAttribute(Globals.PLAYER_IS_IN_GAME_SESSION_ATTRIBUTE_NAME, isActive)
end
local function isLocalPlayerInGameSession()
  return Player:GetAttribute(Globals.PLAYER_IS_IN_GAME_SESSION_ATTRIBUTE_NAME)
end
setIsLocalPlayerInGameSession(false)


-- Folder to hold UserThumbnailGui images
local UserThumbsFolder = Instance.new("Folder", PlayerGui)
UserThumbsFolder.Name = "UserThumbsFolder"

-- Show lobby user menu icons
local lobbyScreenGui = nil
local lobbyFrame = nil
local avatarIcon = nil
local avatarIconId = "rbxassetid://6847150302"  -- https://icon-icons.com/icon/avatar-default-user/92824
local playIcon = nil
local playIconId = "rbxassetid://6855026893"  -- https://graphiccave.com/project/play-icon-vector-and-png-free-download/
local spectateIcon = nil
local spectateIconId = "rbxassetid://6999948582"  -- https://www.flaticon.com/free-icon/eye-close-up_63568
local spectateTargetTextLabel = nil  -- TextLabel showing spectate target

-- For late joiners, show countdown for an existing game in session
local alreadyInSessionCountdownFrame = nil
local alreadyInSessionCountdownTitle = "Game in session -- Time remaining:"
local alreadyInSessionCountdownValue = nil

-- List of players already in game session
local playerNamesInSession = {}


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
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
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

  if not alreadyInSessionCountdownFrame then
    alreadyInSessionCountdownFrame = Util:CreateInstance("Frame", {
        Name = "AlreadyInSessionCountdownFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.85, 0),
        Size = UDim2.new(1.0, 0, 0.3, 0),
        BackgroundTransparency = 1.0,
        BorderSizePixel = 0,
        Active = false,
        Visible = false,
      }, lobbyScreenGui)
    local titleTextLabel = Util:CreateInstance("TextLabel", {
        Name = "AlreadyInSessionCountdown",
        Text = alreadyInSessionCountdownTitle,
        Font = Enum.Font.SourceSansSemibold,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.25, 0),
        Size = UDim2.new(1.0, 0, 0.4, 0),
        BackgroundTransparency = 1.0,
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
      }, alreadyInSessionCountdownFrame)
    alreadyInSessionCountdownValue = Util:CreateInstance("TextLabel", {
        Name = "Value",
        Text = "",
        Font = Enum.Font.SourceSansSemibold,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1.0, 0, 0.4, 0),
        BackgroundTransparency = 1.0,
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
      }, alreadyInSessionCountdownFrame)

    spectateIcon = Util:CreateInstance("ImageButton", {
        Name = "spectateIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.9, 0, 0.5, 0),
        Size = UDim2.new(0.42, 0, 0.42, 0),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Image = spectateIconId,
        BackgroundTransparency = 1.0,
      }, alreadyInSessionCountdownFrame)
    local spectateIconScale = Util:CreateInstance("UIScale", {
        Scale = 1.0,
      }, spectateIcon)
    spectateTargetTextLabel = Util:CreateInstance("TextLabel", {
        Name = "spectateTargetTextLabel",
        Text = "Click to Spectate",
        Font = Enum.Font.SourceSansSemibold,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 1.0, 0),
        Size = UDim2.new(2.5, 0, 0.3, 0),
        BackgroundTransparency = 1.0,
        TextColor3 = Color3.new(1, 1, 1),
        TextScaled = true,
      }, spectateIcon)

    addEnlargeOnMouseHover(spectateIcon, spectateIconScale)

    if true then -- Disabled for now
      spectateIcon.Visible = false
      spectateIcon.Active = false
    end
  end
end


local function showAlreadyInSessionCountdownFrame()
  if alreadyInSessionCountdownFrame and alreadyInSessionCountdownFrame.Active == false then
    alreadyInSessionCountdownFrame.Active = true
    alreadyInSessionCountdownFrame.Visible = true
  end
end

local function hideAlreadyInSessionCountdownFrame()
  if alreadyInSessionCountdownFrame and alreadyInSessionCountdownFrame.Active == true then
    alreadyInSessionCountdownFrame.Active = false
    alreadyInSessionCountdownFrame.Visible = false
  end
end
SessionEndedEvent.OnClientEvent:Connect(hideAlreadyInSessionCountdownFrame)

-- For players not in game session, show game countdown
local function updateAlreadyInSessionCountdown(timeLeft)
  if not isLocalPlayerInGameSession() then
    showAlreadyInSessionCountdownFrame()

    if alreadyInSessionCountdownValue then
      alreadyInSessionCountdownValue.Text = tostring(timeLeft)
    end
  end
end
SessionUpdateTimerCountdownEvent.OnClientEvent:Connect(updateAlreadyInSessionCountdown)


-- Show score gui (takes up whole screen) on top of other guis
local function showScoreGui(pointsEarned, numTotal, numCompleted, numFailed, mapLevel, playerWithBestScore, playerWithBestAssists)
  Promise.try(function()
    local scoreScreenGui = Util:CreateInstance("ScreenGui", {
        Name = "ScoreScreenGui",
        DisplayOrder = 1,
      }, PlayerGui)
    ScoreGui.Show(scoreScreenGui, pointsEarned, numTotal, numCompleted, numFailed, mapLevel, playerWithBestScore, playerWithBestAssists)
  end)
end


local function showLobbyGui()
  lobbyScreenGui.Enabled = true
end

local function showSessionResults(pointsEarned, numTotal, numCompleted, numFailed, mapLevel, playerWithBestScore, playerWithBestAssists)
  showScoreGui(pointsEarned, numTotal, numCompleted, numFailed, mapLevel, playerWithBestScore, playerWithBestAssists)
  showLobbyGui()
  setIsLocalPlayerInGameSession(false)

  hideAlreadyInSessionCountdownFrame()
end
SessionResultsEvent.OnClientEvent:Connect(showSessionResults)

local function hideLobbyGui()
  lobbyScreenGui.Enabled = false
  AvatarGui.Close()
  setIsLocalPlayerInGameSession(true)

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
  local isSessionActive = GetSessionStatusFn:InvokeServer()
  if isSessionActive then
    -- Wait for session to end
    ShowMessagePopupBindableEvent:Fire("Wait for session to end", 1.8)
  else
    AvatarGui.Close()
    PlayGui.Toggle()
    SoundModule.PlayMouseClick(PlayerGui)
  end
end
playIcon.Activated:Connect(onPlayIconClick)


local function onSpectateIconClick()
  local isSessionActive = GetSessionStatusFn:InvokeServer()
  if isSessionActive then
    for idx = 1, #playerNamesInSession do
      local iPlayerName = playerNamesInSession[idx]
      --print("iPlayerName=".. iPlayerName)
      if iPlayerName ~= Player.Name then
        if spectateTargetTextLabel then
          spectateTargetTextLabel.Text = iPlayerName
          -- TODO
          -- Get player
          -- Set camera
        end
      end
    end
  end
end
spectateIcon.Activated:Connect(onSpectateIconClick)

local function hidePlayGui()
  PlayGui.Close()
end
SelectLevelRequestSentEvent.Event:Connect(hidePlayGui)



-- Voting


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

-- See Game.server.lua for playerLevelVotes format
local function onLevelRequestVotesEvent(playerLevelVotes)
  print("Received LevelRequestVotesEvent")

  -- If player is in game session, then do nothing
  if isLocalPlayerInGameSession() then
    return
  end

  -- Check if this was triggered by a new player
  if not playerLevelVotes then
    local isSessionActive = GetSessionStatusFn:InvokeServer()
    if isSessionActive then
      print("Session is active")
      -- Show 'in session' countdown
      showAlreadyInSessionCountdownFrame()

      -- Don't show user vote thumbnails
      return
    end

    -- Request vote info
    playerLevelVotes = GetLevelRequestVotesFn:InvokeServer()
    print("playerLevelVotes = GetLevelRequestVotesFn:InvokeServer()")
  end

  if true then -- Debug
    for _, pv in pairs(playerLevelVotes) do
      print(string.format("  playerLevelVotes: Player %s (%d) votes for %s", pv['PlayerName'], pv['PlayerId'], pv['LevelVote']))
    end
  end

  -- Create sorted list of player names and another list with corresponding user IDs
  local playerNames = {}
  local playerNameToIdMap = {}
  for _, plr in pairs(Players:GetPlayers()) do
    table.insert(playerNames, plr.Name)
    table.insert(playerNameToIdMap, { ['PlayerName'] = plr.Name, ['PlayerId'] = plr.UserId } )
    --table.insert(playerNameToIdMap, { ['PlayerName'] = "WhoooDattt".."2", ['PlayerId'] = plr.UserId } )-- testing
  end
  --table.insert(playerNames, "WhoooDattt".."2") -- testing
  --table.insert(playerNames, "WhoooDattt".."3") -- testing
  --table.insert(playerNames, "WhoooDattt".."4") -- testing
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
      --if currentPlayerName == "WhoooDattt3" then-- testing
      --  plrId = getPlayerIdFromName(playerNameToIdMap, "WhoooDattt")-- testing
      --  print("    ".. currentPlayerName.. " plrId=".. tostring(plrId))-- testing
      --end-- testing
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


-- Make random map level voting frames visible
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



-- Start by showing lobby gui
showLobbyGui()

-- Get list of players currently in session, if any
playerNamesInSession = GetNamesOfPlayersInSessionFn:InvokeServer()

-- Check if should show new player message
Util:RealWait(Globals.LOADING_SCREEN_LENGTH + 5)
local playerPoints = GetPlayerPointsFn:InvokeServer() or 0
if playerPoints < 10 then
  local introScreenGui = Util:CreateInstance("ScreenGui", {
      Name = "Intro",
    }, nil)
  local thumb = UserThumbnailGui.GetImageThumbnail(Assets.CHARACTER_SMILING_MOUTH_OPEN, UDim2.new(0.3, 0, 0.3, 0), nil, 3)
  local introText = [[Welcome! Choose your <font color="rgb(19,153,255)">Avatar</font> and click the <font color="rgb(19,153,255)">Play</font> button when ready.]]
  local msg = FrameFactory.GetTypedMessageFrame(introText, UDim2.new(0.5, 0, 0.2, 0), nil, 2, false)
  if thumb and msg then
    introScreenGui.Parent = PlayerGui
    thumb.Position = UDim2.new(0.2, 0, 0.5, 0)
    thumb.Parent = introScreenGui
    msg.Position = UDim2.new(0.3, 0, 0.55, 0)
    msg.Parent = introScreenGui

    local exitButton = Util:CreateInstance("TextButton", {
        Name = "ExitButton",
        Position = UDim2.new(0.0, 0, 0.0, 0),
        Size = UDim2.new(1.0, 0, 1.0, 0),
        BackgroundTransparency = 1.0,
      }, msg)
    exitButton.Activated:Connect(function()
      if thumb then
        thumb:Destroy()
      end
      msg:Destroy()
    end)
    Promise.delay(8):andThen(function()
      if thumb then
        thumb:Destroy()
      end
      if msg then
        msg:Destroy()
      end

      local thumb2 = UserThumbnailGui.GetImageThumbnail(Assets.CHARACTER_SMILING_EYES_CLOSED, UDim2.new(0.3, 0, 0.3, 0), nil, 3)
      local introText2 = [[Pressing <font color="rgb(19,153,255)">Jump</font> will simply change the camera <font color="rgb(19,153,255)">Zoom</font>.]]
      local msg2 = FrameFactory.GetTypedMessageFrame(introText2, UDim2.new(0.5, 0, 0.2, 0), nil, 2, false)
      if thumb2 and msg2 then
        thumb2.Position = UDim2.new(0.2, 0, 0.5, 0)
        thumb2.Parent = introScreenGui
        msg2.Position = UDim2.new(0.3, 0, 0.55, 0)
        msg2.Parent = introScreenGui

        local exitButton2 = Util:CreateInstance("TextButton", {
            Name = "ExitButton",
            Position = UDim2.new(0.0, 0, 0.0, 0),
            Size = UDim2.new(1.0, 0, 1.0, 0),
            BackgroundTransparency = 1.0,
          }, msg2)
        exitButton2.Activated:Connect(function()
          introScreenGui:Destroy()
        end)
        Promise.delay(8):andThen(function()
          if introScreenGui then
            introScreenGui:Destroy()
          end
        end)
      end
    end)
  end
end

