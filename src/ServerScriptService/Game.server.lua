local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local wsMapsFolder = Workspace:WaitForChild("Maps")
local wsConsumersFolder = Workspace:WaitForChild("Consumers")
local wsFactoriesFolder = Workspace:WaitForChild("Factories")
local wsTransformersFolder = Workspace:WaitForChild("Transformers")
local wsTrashBinsFolder = Workspace:WaitForChild("TrashBins")

local assetsFolder = ServerStorage:WaitForChild("Assets")
local serverMapsFolder = assetsFolder:WaitForChild("Maps")
local serverConsumersFolder = assetsFolder:WaitForChild("Consumers")
local serverFactoriesFolder = assetsFolder:WaitForChild("Factories")
local serverProductsFolder = assetsFolder:WaitForChild("Products")
local serverTransformersFolder = assetsFolder:WaitForChild("Transformers")
local serverTrashBinsFolder = assetsFolder:WaitForChild("TrashBins")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Promise = require(ReplicatedStorage.Vendor.Promise)

local consumerFactory = require(ReplicatedStorage.Consumers.ConsumerFactory)
local consumerClass = require(ReplicatedStorage.Consumers.Consumer)

local productFactory = require(ReplicatedStorage.Products.ProductFactory)
local productClass = require(ReplicatedStorage.Products.Product)

local factoryFactory = require(ReplicatedStorage.Factories.FactoryFactory)
local factoryClass = require(ReplicatedStorage.Factories.Factory)

local transformerFactory = require(ReplicatedStorage.Transformers.TransformerFactory)
local transformerClass = require(ReplicatedStorage.Transformers.Transformer)

local trashBinClass = require(ReplicatedStorage.TrashBins.TrashBin)


local MAX_SEARCH_FOR_PLOTS = 1000
local PRODUCT_PLAYER_WELD_NAME = "ProductPlayerWeld"


-- List of factory instances
local factories = {}

-- List of transformer instances
local transformers = {}

-- List of product instances
local products = {}

-- List of trash bin instances
local trashBins = {}


-- Find random available plot on map
local function getAvailablePlot(map, plotType)
  local rand = Random.new()
  local mapObjects = map:GetChildren()
  while #mapObjects > 0 do
    local randNum = rand:NextInteger(1, #mapObjects)
    local obj = mapObjects[randNum]
    if obj.Name == plotType then
      local assetName = obj:GetAttribute("AssetName")
      if assetName == "" then
        --print("       Found available plot: ".. plotType)
        return obj
      end
    end
    table.remove(mapObjects, randNum)
  end
end

local function getAvailableConsumerPlot(map)
  return getAvailablePlot(map, "ConsumerPlot")
end

local function getAvailableProducerPlot(map)
  return getAvailablePlot(map, "ProducerPlot")
end

local function getCharacterProduct(character)
  if character then
    print("getPlayerProduct for ".. character.Name)
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
    if currentModelPart.Name == "ProductAttachmentPart" then
      return currentModelPart
    end
  end

  -- Create a default attachment Part
  -- NOTE: This isn't working right...
  local attachmentPart = nil
  local primaryPart = model.PrimaryPart
  if primaryPart then
    attachmentPart = Instance.new("Part", primaryPart)
    attachmentPart.Name = "ProductAttachmentPart"
    attachmentPart.Position = primaryPart.Position + Vector3.new(0, 6, 0)
    attachmentPart.Size = Vector3.new(0.5, 0.5, 0.5)
    Util:WeldModelToPart(attachmentPart, primaryPart, "ProductAttachmentPartWeld")
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
    local primaryPart = consumerModel.PrimaryPart

    -- Check if player is holding the right input
    local character = Util:GetCharacterFromPlayer(player)
    if character then
      local currentProduct = getCharacterProduct(character)
      if currentProduct then
        if currentProduct.Name == consumerInputStr then
          SoundModule.PlaySwitch3(character)

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

          -- Remove product after delay
          Promise.delay(consumerClass.DEFAULT_CONSUME_TIME_SEC):andThen(function()
            currentProduct:Destroy()
          end)
        end
      end
    end
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
            Util:WeldModelToPart(currentProduct, attachmentPart, "ProductTransformerWeld")
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
          currentProduct:SetPrimaryPartCFrame(attachmentPart.CFrame)
          Util:WeldModelToPart(currentProduct, attachmentPart, "ProductTrashBinWeld")
        end

        -- Reparent product to trashBin
        local trashBinProductsFolder = trashBinModel:WaitForChild("Products", 2)
        if not trashBinProductsFolder then
          trashBinProductsFolder = Instance.new("Folder", trashBinModel)
          trashBinProductsFolder.Name = "Products"
        end
        currentProduct.Parent = trashBinProductsFolder

        -- Remove product after delay
        Promise.delay(0.2):andThen(function()
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
  -- Select a map TODO
  -- aing Hardcoded for now
  local map = serverMapsFolder:WaitForChild("Level1"):WaitForChild("1.1")
  -- Make plots transparent
  for _, obj in pairs(map:GetDescendants()) do
    if obj.Name == "ConsumerPlot" or obj.Name == "ProducerPlot" or obj.Name == "TrashBinPlot" then
      obj.Transparency = 1
    end
  end
  map.Parent = wsMapsFolder

  -- Look for the consumers and find their producers
  for consumerModelIdx, consumerModel in pairs(serverConsumersFolder:GetChildren()) do
    local inputStr = consumerModel:GetAttribute("Input")
    print("Consumer: ".. consumerModel.Name.. "; Input=".. inputStr)

    -- Create consumer
    local consumerInstance = consumerFactory.GetConsumer(consumerModel.Name, inputStr)
    local consumerClone = consumerModel:Clone()
    consumerInstance:SetModel(consumerClone)
    local consumerPlot = getAvailableConsumerPlot(map)
    if consumerPlot then
      consumerPlot:SetAttribute("AssetName", consumerInstance:GetName())
      consumerClone:SetPrimaryPartCFrame(consumerPlot.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
      consumerClone.PrimaryPart.CFrame = CFrame.new(consumerPlot.Position, map.PrimaryPart.Position)
      -- consumerClone.PrimaryPart.CFrame = consumerPlot.CFrame -- This will work if model is welded
      consumerClone.Parent = wsConsumersFolder
      consumerInstance:Run()
    end

    -- Find the producers of the input (the names should match)
    -- Everything should start from a Factory (versus Transformer or Aggregator)
    local isDone = false
    local count = 0
    while not isDone do
      for _, transformerModel in pairs(serverTransformersFolder:GetChildren()) do
        -- Note that for Transformers, the Transformer name is the name of the output product
        if transformerModel.Name == inputStr then
          -- Found Transformer that outputs product named inputStr

          -- Find available plot on map
          local plot = getAvailableProducerPlot(map)
          if plot then
            plot:SetAttribute("AssetName", inputStr)
            local transformerClone = transformerModel:Clone()
            local transformTimeSec = transformerClone:GetAttribute("TransformTimeSec")
            local transformerName = transformerClone:GetAttribute("TransformerName")

            -- Create product
            local productModel = serverProductsFolder:FindFirstChild(inputStr)
            local productInstance = productFactory.GetProduct(inputStr, productModel)

            -- Get its input and update the inputStr to follow the chain all the way back to the factory
            local transformerInputStr = transformerModel:GetAttribute("Input")
            if transformerInputStr then
              inputStr = transformerInputStr
            end

            -- Create object instances
            local transformerInstance = transformerFactory.GetTransformer(transformerName, transformerInputStr, transformTimeSec)
            transformerInstance:SetModel(transformerClone)
            transformerInstance:SetProduct(productInstance)
            transformerInstance:Run()
            table.insert(transformers, transformerInstance)
            table.insert(products, productInstance)

            -- Move to workspace
            transformerClone:SetPrimaryPartCFrame(plot.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
            transformerClone.Parent = wsTransformersFolder
            break
          end
        end
      end
      for _, factoryModel in pairs(serverFactoriesFolder:GetChildren()) do
        if factoryModel.Name == inputStr then
          -- Find available plot on map
          local plot = getAvailableProducerPlot(map)
          if plot then
            plot:SetAttribute("AssetName", inputStr)
            -- Get a copy of the factory model and check stats
            local factoryClone = factoryModel:Clone()
            local spawnDelaySec = factoryClone:GetAttribute("SpawnDelaySec")

            -- Create product
            local productModel = serverProductsFolder:FindFirstChild(inputStr)
            local productInstance = productFactory.GetProduct(inputStr, productModel)

            -- Create object instances
            local factoryInstance = factoryFactory.GetFactory(inputStr, spawnDelaySec)
            factoryInstance:SetModel(factoryClone)
            factoryInstance:SetProduct(productInstance)
            factoryInstance:Run()
            table.insert(factories, factoryInstance)
            table.insert(products, productInstance)

            -- Move factory to workspace
            factoryClone:SetPrimaryPartCFrame(plot.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
            factoryClone.Parent = wsFactoriesFolder

            isDone = true
            break
          end
        end
      end

      count += 1
      if count > MAX_SEARCH_FOR_PLOTS then
        isDone = true
      end
    end -- while
  end -- consumer


  -- Place trash bins
  for _, obj in pairs(map:GetChildren()) do
    if obj.Name == "TrashBinPlot" then
      -- Get copy of trash bin
      local trashBinClone = serverTrashBinsFolder:FindFirstChild("TrashBin"):Clone()

      -- Create object instance
      local trashBinInstance = trashBinClass.new()
      trashBinInstance:SetModel(trashBinClone)
      trashBinInstance:Run()
      table.insert(trashBins, trashBinInstance)

      -- Move to workspace
      trashBinClone:SetPrimaryPartCFrame(obj.CFrame)
      trashBinClone.Parent = wsTrashBinsFolder
    end
  end

end

onGameStart()

