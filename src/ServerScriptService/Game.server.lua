local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Util = require(ReplicatedStorage.Util)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local consumerClass = require(ReplicatedStorage.Consumers.Consumer)
local MapManager = require(ServerScriptService.MapManager)

local ConsumerInputReceivedEvent = ReplicatedStorage.Events.ConsumerInputReceived


local PRODUCT_PLAYER_WELD_NAME = "ProductPlayerWeld"


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

local function getProductAttachmentPart(model)
  -- Check if model has an attachment Part for the product
  for ___, currentModelPart in pairs(model:GetDescendants()) do
    if currentModelPart.Name == consumerClass.PRODUCT_ATTACHMENT_PART_NAME and currentModelPart:IsA("BasePart") then
      return currentModelPart
    end
  end

  -- Create a default attachment Part
  -- NOTE: This isn't working right...
  local attachmentPart = nil
  local primaryPart = model.PrimaryPart
  if primaryPart then
    attachmentPart = Instance.new("Part", primaryPart)
    attachmentPart.Name = consumerClass.PRODUCT_ATTACHMENT_PART_NAME
    attachmentPart.Position = primaryPart.Position + Vector3.new(0, 6, 0)
    attachmentPart.Size = Vector3.new(0.5, 0.5, 0.5)
    Util:WeldModelToPart(attachmentPart, primaryPart, consumerClass.PRODUCT_ATTACHMENT_PART_NAME.."Weld")
    attachmentPart.Transparency = 1.0
    attachmentPart.CanCollide = false
    attachmentPart.CastShadow = false
  end
  return attachmentPart
end

local function handleConsumerPrompt(consumerModel, player)
  if consumerModel and consumerModel:IsA("Model") then
    local consumerInputStr = consumerModel:GetAttribute("Input")
    print("Consumer: ".. consumerModel.Name.. "; Input=".. consumerInputStr)

    -- Check if consumer is currently requesting an input
    local isRequestingInput = consumerModel:GetAttribute(consumerClass.IS_REQUESTING_INPUT_ATTR_STR)
    if isRequestingInput then
      local primaryPart = consumerModel.PrimaryPart

      -- Check if player is holding the right input
      local character = Util:GetCharacterFromPlayer(player)
      if character then
        local currentProduct = getCharacterProduct(character)
        if currentProduct then
          if currentProduct.Name == consumerInputStr then
            --SoundModule.PlaySwitch3(character)  -- Client will handle sound

            -- Break welds between product and player
            local hand = Util:GetRightHandFromPlayer(player)
            for __, descendant in ipairs(hand:GetChildren()) do
              if descendant.Name == consumerInputStr..PRODUCT_PLAYER_WELD_NAME then
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

            ConsumerInputReceivedEvent:FireAllClients(consumerModel)

            -- Remove product after delay
            Promise.delay(consumerClass.DEFAULT_CONSUME_TIME_SEC):andThen(function()
              currentProduct:Destroy()
            end)
          end
        end -- currentProduct
      end -- primaryPart
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
      Util:WeldModelToPart(productModel, hand, productModel.Name..PRODUCT_PLAYER_WELD_NAME)
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
    local transformerInputStr = transformerModel:GetAttribute("Input")
    print("Transformer: ".. transformerModel.Name.. "; Input=".. transformerInputStr)
    local primaryPart = transformerModel.PrimaryPart

    -- Check if player is holding the right input
    local character = Util:GetCharacterFromPlayer(player)
    if character then
      local currentProduct = getCharacterProduct(character)
      if currentProduct then
        if currentProduct.Name == transformerInputStr then
          SoundModule.PlaySwitch3(character)

          -- Break welds between product and player
          local hand = Util:GetRightHandFromPlayer(player)
          for __, descendant in ipairs(hand:GetChildren()) do
            if descendant.Name == transformerInputStr..PRODUCT_PLAYER_WELD_NAME then
              descendant:Destroy()
            end
          end

          -- Check if model already has an attachment Part for the product
          local attachmentPart = getProductAttachmentPart(transformerModel)
          if attachmentPart then
            currentProduct:SetPrimaryPartCFrame(attachmentPart.CFrame)
            Util:WeldModelToPart(currentProduct, attachmentPart, transformerInputStr..PRODUCT_PLAYER_WELD_NAME)
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
    end
  end
end

local function handleTrashBinPrompt(trashBinModel, player)
  if trashBinModel and trashBinModel:IsA("Model") then
    local primaryPart = trashBinModel.PrimaryPart

    local character = Util:GetCharacterFromPlayer(player)
    if character then
      local currentProduct = getCharacterProduct(character)
      if currentProduct then
        SoundModule.PlaySwitch3(character)

        -- Break welds between product and player
        local hand = Util:GetRightHandFromPlayer(player)
        for __, descendant in ipairs(hand:GetChildren()) do
          if descendant.Name == currentProduct.Name..PRODUCT_PLAYER_WELD_NAME then
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
end

-- Detect when prompt is triggered
local function onPromptTriggered(promptObject, player)
  local promptModel = promptObject.Parent.Parent.Parent -- Get the product Model
  if promptModel then
    -- Get the type of object as a string, e.g. "Product", "Consumer", etc.
    local promptModelFolder = promptModel:FindFirstAncestorWhichIsA("Folder")
    if promptModelFolder then
      local promptModelTypeName = promptModelFolder.Name
      print("onPromptTriggered: Folder=".. promptModelTypeName)

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
  else
    error("Game.onPromptTriggered() Could not find Model for ".. promptObject.Parent.Parent.Name)
  end
end

-- Connect prompt events to handling functions
ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)


local function onGameStart()
  -- Select a map
  local map = MapManager.InitializeMap()

end

onGameStart()

