local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local AnimationModule = require(ReplicatedStorage.AnimationModule)
local Players = game:GetService("Players")

local Util = require(ReplicatedStorage.Util)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local MapManager = require(ServerScriptService.MapManager)
local ProductClass = require(ReplicatedStorage.Products.Product)
local ConsumerClass = require(ReplicatedStorage.Consumers.Consumer)
local TransformerClass = require(ReplicatedStorage.Transformers.Transformer)
local Session = require(ReplicatedStorage.Session)

local ConsumerInputReceivedEvent = ReplicatedStorage.Events.ConsumerInputReceived
local SelectLevelRequestEvent = ReplicatedStorage.Events.SelectLevelRequest
local LevelRequestVotesEvent = ReplicatedStorage.Events.LevelRequestVotes
local SessionCountdownBeginEvent = ReplicatedStorage.Events.SessionCountdownBegin
local SessionUpdateTimerCountdownEvent = ReplicatedStorage.Events.SessionUpdateTimerCountdown
local SessionBeginEvent = ReplicatedStorage.Events.SessionBegin
local SessionEndedEvent = ReplicatedStorage.Events.SessionEnded
local SessionScoreEvent = ReplicatedStorage.Events.SessionScore
local ShowMessagePopupEvent = ReplicatedStorage.Events.ShowMessagePopup


local PRODUCT_PLAYER_WELD_NAME = "ProductPlayerWeld"


-- Keep track of player level votes; List of players and their votes
-- Format: {
--            { 'PlayerName' = player.Name, 'PlayerId' = player.UserId, 'LevelVote' = levelRequest },
--            { 'PlayerName' = player.Name, 'PlayerId' = player.UserId, 'LevelVote' = levelRequest },
--         }
local playerLevelVotes = {}


local session = nil
local lobbySpawn = nil


-- Remove Player ForceField
Promise.try(function()
  for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj.Name == "SpawnLocation" then
      lobbySpawn = obj
      obj.Duration = 0
      break
    end
  end
end)


local function getCharacterProduct(character)
  if character then
    --print("getPlayerProduct for ".. character.Name)
    local characterProductsFolder = character:WaitForChild("Products", 2)
    if characterProductsFolder then
      for _, currentProduct in pairs(characterProductsFolder:GetChildren()) do
        -- Return the first product
        return currentProduct
      end
    else
      error("Could not find player Products folder for ".. character.Parent.Name)
    end
  end
end

local function getPlayersCharacterAndCurrentProduct(player)
  local currentProduct = nil
  local character = Util:GetCharacterFromPlayer(player)
  if character then
    currentProduct = getCharacterProduct(character)
  end
  return character, currentProduct
end

local function getProductAttachmentPart(model)
  -- Check if model has an attachment Part for the product
  for ___, currentModelPart in pairs(model:GetDescendants()) do
    if currentModelPart.Name == ConsumerClass.PRODUCT_ATTACHMENT_PART_NAME and currentModelPart:IsA("BasePart") then
      return currentModelPart
    end
  end

  -- Create a default attachment Part
  -- NOTE: This hasn't been tested
  local attachmentPart = nil
  local primaryPart = model.PrimaryPart
  if primaryPart then
    attachmentPart = Instance.new("Part", primaryPart)
    attachmentPart.Name = ConsumerClass.PRODUCT_ATTACHMENT_PART_NAME
    attachmentPart.Position = primaryPart.Position + Vector3.new(0, 6, 0)
    attachmentPart.Size = Vector3.new(0.5, 0.5, 0.5)
    Util:WeldModelToPart(attachmentPart, primaryPart, ConsumerClass.PRODUCT_ATTACHMENT_PART_NAME.."Weld")
    attachmentPart.Transparency = 1.0
    attachmentPart.CanCollide = false
    attachmentPart.CastShadow = false
  end
  return attachmentPart
end

local function handleConsumerPrompt(consumerModel, player)
  if consumerModel and consumerModel:IsA("Model") then
    local consumerInputStr = consumerModel:GetAttribute(ConsumerClass.CURRENT_REQUESTED_INPUT_ATTR_NAME)
    --print("Consumer: ".. consumerModel.Name.. "; Input=".. consumerInputStr)

    -- Check if consumer is currently requesting an input
    local isRequestingInput = consumerModel:GetAttribute(ConsumerClass.IS_REQUESTING_INPUT_ATTR_NAME)
    if isRequestingInput then
      local character, currentProduct = getPlayersCharacterAndCurrentProduct(player)
      if character and currentProduct then
        --SoundModule.PlaySwitch3(character)  -- Client will handle sound

        -- Break welds between product and player
        local hand = Util:GetRightHandFromPlayer(player)
        for __, descendant in ipairs(hand:GetChildren()) do
          if descendant.Name == PRODUCT_PLAYER_WELD_NAME then
            descendant:Destroy()
          end
        end

        -- Check if model already has an attachment Part for the product
        local attachmentPart = getProductAttachmentPart(consumerModel)
        if attachmentPart then
          currentProduct:SetPrimaryPartCFrame(attachmentPart.CFrame)
          Util:WeldModelToPart(currentProduct, attachmentPart, "ProductConsumerWeld")
        end

        -- Reparent product to consumer
        local consumerProductsFolder = consumerModel:WaitForChild("Products", 2)
        if not consumerProductsFolder then
          consumerProductsFolder = Instance.new("Folder", consumerModel)
          consumerProductsFolder.Name = "Products"
        end
        currentProduct.Parent = consumerProductsFolder

        -- Remove product after delay (non-blocking)
        Promise.delay(ConsumerClass.DEFAULT_CONSUME_TIME_SEC):andThen(function()
          currentProduct:Destroy()
        end)

        if currentProduct.Name == consumerInputStr then
          -- Correct input
          ConsumerInputReceivedEvent:FireAllClients(consumerModel, true)
          AnimationModule.PlayVictoryAnimation(consumerModel)
          session:IncrementScore(ProductClass.DEFAULT_POINTS)
          SessionScoreEvent:FireAllClients(session:GetScore())
          print("Score=".. tostring(session:GetScore()))
        else
          -- Wrong input
          ConsumerInputReceivedEvent:FireAllClients(consumerModel, false)
          AnimationModule.PlayDefeatAnimation(consumerModel)
        end
      end
    end -- isRequestingInput
  end
end

local function handleProductPrompt(productModel, player)
  if productModel and productModel:IsA("Model") then
    local character = Util:GetCharacterFromPlayer(player)
    local productsFolder = character:WaitForChild("Products", 2)
    if not productsFolder then
      productsFolder = Instance.new("Folder", character)
      productsFolder.Name = "Products"
    end

    -- If player already holding product, then do nothing
    local playerProducts = productsFolder:GetChildren()
    if #playerProducts > 0 then
      -- Player already has product
      return
    end

    -- Weld product to character
    local primaryPart = productModel.PrimaryPart
    local hand = Util:GetRightHandFromPlayer(player)
    if hand then
      if primaryPart then
        productModel:SetPrimaryPartCFrame(hand.CFrame)
        -- Rotate model so it's upright in hand
        productModel:SetPrimaryPartCFrame(hand.CFrame * CFrame.Angles(math.rad(-90), 0, 0))
      else
        -- Just use another part
        primaryPart = productModel:FindFirstChildWhichIsA("BasePart")
        primaryPart.CFrame = hand.CFrame
        warn(script.Name.. " could not find PrimaryPart for ".. productModel.Name)
      end
      Util:WeldModelToPart(productModel, hand, PRODUCT_PLAYER_WELD_NAME)
      SoundModule.PlaySwitch3(hand)
    else
      error("Unable to find hand for ".. player.Name)
    end

    -- Reparent the product to the player
    productModel.Parent = productsFolder

    -- Destroy the proximity prompt
    local promptAttachment = primaryPart:WaitForChild("PromptAttachment")
    if promptAttachment then
      promptAttachment:Destroy()
    end
  end
end

local function handleTransformerPrompt(transformerModel, player)
  if transformerModel and transformerModel:IsA("Model") then
    local transformerInputStr = transformerModel:GetAttribute(TransformerClass.INPUT_ATTR_NAME)
    --print("Transformer: ".. transformerModel.Name.. "; Input=".. transformerInputStr)

    -- Check if player is holding the right input
    local showInputNeededMessage = true
    local character, currentProduct = getPlayersCharacterAndCurrentProduct(player)
    if character and currentProduct then
      if currentProduct.Name == transformerInputStr then
        SoundModule.PlaySwitch3(character)
        showInputNeededMessage = false

        -- Break welds between product and player
        local hand = Util:GetRightHandFromPlayer(player)
        for __, descendant in ipairs(hand:GetChildren()) do
          if descendant.Name == PRODUCT_PLAYER_WELD_NAME then
            descendant:Destroy()
          end
        end

        -- Check if model already has an attachment Part for the product
        local attachmentPart = getProductAttachmentPart(transformerModel)
        if attachmentPart then
          currentProduct:SetPrimaryPartCFrame(attachmentPart.CFrame)
          Util:WeldModelToPart(currentProduct, attachmentPart, PRODUCT_PLAYER_WELD_NAME)
        end

        -- Reparent product to transformer
        local transformerProductsFolder = transformerModel:WaitForChild("Products", 2)
        if not transformerProductsFolder then
          transformerProductsFolder = Instance.new("Folder", transformerModel)
          transformerProductsFolder.Name = "Products"
        end
        currentProduct.Parent = transformerProductsFolder
      end
    end

    if showInputNeededMessage then
      ShowMessagePopupEvent:FireClient(player, "Need ".. transformerInputStr.. "!", 1.8)
    end
  end
end

local function handleTrashBinPrompt(trashBinModel, player)
  if trashBinModel and trashBinModel:IsA("Model") then
    local character, currentProduct = getPlayersCharacterAndCurrentProduct(player)
    if character and currentProduct then
      SoundModule.PlaySwitch3(character)

      -- Break welds between product and player
      local hand = Util:GetRightHandFromPlayer(player)
      for __, descendant in ipairs(hand:GetChildren()) do
        if descendant.Name == PRODUCT_PLAYER_WELD_NAME then
          descendant:Destroy()
        end
      end

      -- Check if model already has an attachment Part for the product
      local attachmentPart = getProductAttachmentPart(trashBinModel)
      if attachmentPart then
        Util:MakeModelCanCollide(currentProduct, false)
        currentProduct:SetPrimaryPartCFrame(attachmentPart.CFrame)
        --Util:WeldModelToPart(currentProduct, attachmentPart, "ProductTrashBinWeld")
      end

      -- Reparent product to trashBin
      local trashBinProductsFolder = trashBinModel:WaitForChild("Products", 2)
      if not trashBinProductsFolder then
        trashBinProductsFolder = Instance.new("Folder", trashBinModel)
        trashBinProductsFolder.Name = "Products"
      end
      currentProduct.Parent = trashBinProductsFolder

      -- Make product "fall" straight down then destroy
      Promise.try(function()
        for iter = 1, 5 do
          yOffset = iter * -0.035
          currentProduct:SetPrimaryPartCFrame(attachmentPart.CFrame + Vector3.new(0, yOffset, 0))
          Util:RealWait()
        end
        currentProduct:Destroy()
      end)
    end
  end
end

local function getElementModelAndType(object)
  local promptModel = object.Parent.Parent.Parent -- Get the product Model
  if promptModel then
    local promptModelTypeName = ""
    -- Get the type of object as a string, e.g. "Product", "Consumer", etc.
    local promptModelFolder = promptModel:FindFirstAncestorWhichIsA("Folder")
    if promptModelFolder then
      promptModelTypeName = promptModelFolder.Name
    end
    return promptModel, promptModelTypeName
  else
    error("Game.getElementType() Could not find Model for ".. object.Parent.Parent.Name)
  end
end

-- Detect when prompt is triggered
-- This happens after HoldDuration is met, if any
local function onPromptTriggered(promptObject, player)
  local promptModel, promptModelTypeName = getElementModelAndType(promptObject)
  --print("onPromptTriggered: Folder=".. promptModelTypeName)

  -- Invoke the appropriate handler
  if promptModelTypeName == "Products" then
    handleProductPrompt(promptModel, player)
  elseif promptModelTypeName == "Consumers" then
    handleConsumerPrompt(promptModel, player)
  elseif promptModelTypeName == "Transformers" then
    handleTransformerPrompt(promptModel, player)
  elseif promptModelTypeName == "TrashBins" then
    handleTrashBinPrompt(promptModel, player)
  end
end
-- Connect prompt events to handling functions
ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)


local function onPromptHoldBegan(promptObject, player)
  local promptModel, promptModelTypeName = getElementModelAndType(promptObject)
  if promptModel and promptModelTypeName then
    if promptModelTypeName == "Consumers" or promptModelTypeName == "Transformers" then

      -- For Transformers, don't let player waste time if not correct type
      if promptModelTypeName == "Transformers" then
        -- Check if player is holding the right input
        local character, currentProduct = getPlayersCharacterAndCurrentProduct(player)
        if character then
          local transformerInputStr = promptModel:GetAttribute(TransformerClass.INPUT_ATTR_NAME)
          if not currentProduct or currentProduct.Name ~= transformerInputStr then
            -- Wrong input type
            ShowMessagePopupEvent:FireClient(player, "Need ".. transformerInputStr.. "!", 1.8)
            return
          end
        end
      end

      local holdAnimId = promptModel:GetAttribute(ConsumerClass.PROXIMITY_HOLD_ANIMATION_ATTR_NAME)
      if holdAnimId then
        local human = Util:GetHumanoid(player)
        if human then
          -- Face player toward ProximityHoldTargetPart, if exists
          local humanoidRootPart = Util:GetHumanoidRootPart(player)
          if humanoidRootPart then
            local targetPart = Util:GetDescendantWithName(promptModel, ConsumerClass.PROXIMITY_HOLD_TARGET_PART_NAME)
            if targetPart then
              local targetPos = Vector3.new(targetPart.Position.X, humanoidRootPart.Position.Y, targetPart.Position.Z)
              humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, targetPos)
            end
          end

          -- Play animation
          AnimationModule.PlayAssetIdStr(human, holdAnimId, AnimationModule.IS_LOOPED)
        end
      end
    end
  end
end
ProximityPromptService.PromptButtonHoldBegan:Connect(onPromptHoldBegan)


local function onPromptHoldEnded(promptObject, player)
  local promptModel = promptObject.Parent.Parent.Parent -- Get the product Model
  if promptModel then
    local holdAnimId = promptModel:GetAttribute(ConsumerClass.PROXIMITY_HOLD_ANIMATION_ATTR_NAME)
    if holdAnimId then
      local human = Util:GetHumanoid(player)
      if human then
        AnimationModule.Stop(human)
      end
    end
  end
end
ProximityPromptService.PromptButtonHoldEnded:Connect(onPromptHoldEnded)


local function onGameStart(winningLevel)
  -- Select a map
  local map = MapManager.InitializeMap(winningLevel)

  -- Spawn players into map
  local playerList = {}
  local spawns = MapManager.GetSpawns()
  if spawns and #spawns > 0 then
    playerList = Players:GetPlayers()
    for idx, spawn in pairs(spawns) do
      if playerList[idx] then
        print("Spawning into game map: ".. playerList[idx].Name)
        local torso = Util:GetTorsoFromPlayer(playerList[idx])
        if torso then
          local yOffset = 4
          local humanoid = Util:GetHumanoid(playerList[idx])
          if humanoid then
            yOffset = humanoid.HipHeight + 1
          end
          torso.CFrame = CFrame.new(spawn.Position + Vector3.new(0, yOffset, 0))
        else
          error("Unable to find torso for ".. playerList[idx].Name)
        end
      end
    end
  else
    error("Unable to get spawn plots from MapManager")
  end

  session = Session.new()

  Promise.try(function()
    SessionCountdownBeginEvent:FireAllClients(session:GetDuration())
    Util:RealWait(4)  -- Wait for "Ready" countdown
    SessionBeginEvent:FireAllClients()

    local timerUpdateIntervalSec = 1
    session:Start()
    while not session:IsDone() do
      local remainingTime = math.ceil(session:GetRemainingTime())
      if remainingTime >= 0 then
        SessionUpdateTimerCountdownEvent:FireAllClients(remainingTime)
        print("SessionUpdateTimerCountdownEvent:FireAllClients(): ".. tostring(math.ceil(session:GetRemainingTime())))
        Util:RealWait(timerUpdateIntervalSec)
        print("Elapsed Time: ".. tostring(session:GetElapsedTime()))
      end
    end

    SessionEndedEvent:FireAllClients(session:GetScore())
    Util:RealWait(Session.POST_GAME_COOLDOWN_PERIOD_SEC)

    -- Spawn players into lobby
    for idx, player in pairs(playerList) do
      -- Remove any product player might be holding
      local character, product = getPlayersCharacterAndCurrentProduct(player)
      if product then
        product:Destroy()
      end

      print("Spawning into lobby: ".. playerList[idx].Name)
      local torso = Util:GetTorsoFromPlayer(playerList[idx])
      if torso then
        local xOffset = 6
        local yOffset = 4
        local humanoid = Util:GetHumanoid(playerList[idx])
        if humanoid then
          yOffset = humanoid.HipHeight + 1
        end
        torso.CFrame = CFrame.new(lobbySpawn.Position + Vector3.new(idx * xOffset, yOffset, 0))
      else
        error("Unable to find torso for ".. playerList[idx].Name)
      end
    end

    -- Cleanup
    MapManager.Cleanup(map)

  end)
end


local function onSelectLevelRequestEvent(player, levelRequest)
  print(string.format("Player %s voted for %s", player.Name, levelRequest))

  -- TODO: Wait for all votes
  -- Find player vote, if any
  local foundPlayerVote = false
  for idx, playerVote in pairs(playerLevelVotes) do
    if player.Name == playerVote['PlayerName'] then
      playerVote['LevelVote'] = levelRequest
      foundPlayerVote = true
      break
    end
  end
  if not foundPlayerVote then
    -- Add player's vote
    table.insert(playerLevelVotes, { ['PlayerName'] = player.Name, ['PlayerId'] = player.UserId, ['LevelVote'] = levelRequest })
  end

  if false then -- Debug
    for _, pv in pairs(playerLevelVotes) do
      print(string.format("  playerLevelVotes: Player %s (%d) votes for %s", pv['PlayerName'], pv['PlayerId'], pv['LevelVote']))
    end
  end

  -- Send clients a list of players and their level votes
  LevelRequestVotesEvent:FireAllClients(playerLevelVotes)

  -- If all players voted, then choose random vote
  local winningLevel = ""
  local numPlayers = Util:TableLength(Players:GetPlayers())
  if numPlayers == Util:TableLength(playerLevelVotes) then
    if numPlayers == 1 then
      winningLevel = levelRequest
    else
      -- TODO
      -- Choose random vote
    end
  end

  if winningLevel and winningLevel ~= "" then
    -- Start the game session
    --aing onGameStart(winningLevel)
    -- Clear level votes
    playerLevelVotes = {}
  end
end
SelectLevelRequestEvent.OnServerEvent:Connect(onSelectLevelRequestEvent)

