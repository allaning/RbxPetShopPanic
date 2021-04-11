local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local wsMapsFolder = Workspace:WaitForChild("Maps")
local wsConsumersFolder = Workspace:WaitForChild("Consumers")
local wsFactoriesFolder = Workspace:WaitForChild("Factories")
local wsTransformersFolder = Workspace:WaitForChild("Transformers")

local assetsFolder = ServerStorage:WaitForChild("Assets")
local serverMapsFolder = assetsFolder:WaitForChild("Maps")
local serverConsumersFolder = assetsFolder:WaitForChild("Consumers")
local serverFactoriesFolder = assetsFolder:WaitForChild("Factories")
local serverProductsFolder = assetsFolder:WaitForChild("Products")
local serverTransformersFolder = assetsFolder:WaitForChild("Transformers")

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


local MAX_SEARCH_FOR_PLOTS = 1000


-- List of factory instances
local factories = {}

-- List of transformer instances
local transformers = {}

-- List of product instances
local products = {}


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

local function handleConsumerPrompt(consumerModel, player)
  if consumerModel and consumerModel:IsA("Model") then
    local consumerInputStr = consumerModel:GetAttribute("Input")
    print("Consumer: ".. consumerModel.Name.. "; Input=".. consumerInputStr)
    local primaryPart = consumerModel.PrimaryPart

    -- Check if player is holding the right input
    local character = Util:GetCharacterFromPlayer(player)
    if character then
      local characterProductsFolder = character:WaitForChild("Products", 2)
      if characterProductsFolder then
        for _, currentProduct in pairs(characterProductsFolder:GetChildren()) do
          if currentProduct.Name == consumerInputStr then
            SoundModule.PlaySwitch3(character)

            -- Break welds between product and player
            local hand = Util:GetRightHandFromPlayer(player)
            for __, descendant in ipairs(hand:GetChildren()) do
              if descendant.Name == "ProductPlayerWeld" then
                descendant:Destroy()
              end
            end

            -- Check if model already has an attachment Part for the product
            local attachmentPart = nil
            for ___, currentConsumerModelPart in pairs(consumerModel:GetDescendants()) do
              if currentConsumerModelPart.Name == "ProductAttachmentPart" then
                attachmentPart = currentConsumerModelPart
                break
              end
            end
            if not attachmentPart then
              -- Create a default attachment Part
              if primaryPart then
                attachmentPart = Instance.new("Part", primaryPart)
                attachmentPart.Name = "ProductAttachmentPart"
                attachmentPart.Position = Vector3.new(0, 3, 0)
                attachmentPart.Size = Vector3.new(0.1, 0.1, 0.1)
                attachmentPart.Transparency = 1.0
                attachmentPart.CastShadow = false
              end
            end
            currentProduct:SetPrimaryPartCFrame(attachmentPart.CFrame)
            Util:WeldModelToPart(currentProduct, attachmentPart, "ProductConsumerWeld")

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

            break
          end
        end
      else
        error("Could not find player Products folder for ".. player.Name)
      end
    end
  end
end

local function handleProductPrompt(productModel, player)
  if productModel and productModel:IsA("Model") then
    local primaryPart = productModel.PrimaryPart

    -- TODO
    -- If player already holding product, then swap

    -- Weld product to character
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
      Util:WeldModelToPart(productModel, hand, "ProductPlayerWeld")
      SoundModule.PlaySwitch3(hand)
    else
      error("Unable to find hand for ".. player.Name)
    end

    -- Reparent the product to the player
    local character = Util:GetCharacterFromPlayer(player)
    local productsFolder = character:WaitForChild("Products", 2)
    if not productsFolder then
      productsFolder = Instance.new("Folder", character)
      productsFolder.Name = "Products"
    end
    productModel.Parent = productsFolder

    -- Destroy the proximity prompt
    local promptAttachment = primaryPart:WaitForChild("PromptAttachment")
    if promptAttachment then
      promptAttachment:Destroy()
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
        print("TRANSFORMER")
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
  -- aing Hardcoded for now
  local map = serverMapsFolder:WaitForChild("Level1"):WaitForChild("1.1")
  -- Make plots transparent
  for _, obj in pairs(map:GetDescendants()) do
    if obj.Name == "ConsumerPlot" or obj.Name == "ProducerPlot" then
      obj.Transparency = 1
    end
  end
  map.Parent = wsMapsFolder

  -- Look for the consumers and find their producers
  for _, consumerModel in pairs(serverConsumersFolder:GetChildren()) do
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
        if transformerModel.Name == inputStr then
          -- Find available plot on map
          local plot = getAvailableProducerPlot(map)
          if plot then
            plot:SetAttribute("AssetName", inputStr)
            local transformerClone = transformerModel:Clone()

            -- Get its input and update the inputStr to follow the chain all the way back to the factory
            local transformerInputStr = transformerModel:GetAttribute("Input")
            if transformerInputStr then
              inputStr = transformerInputStr
            end

            -- Create object instances
            local transformerInstance = transformerFactory.GetTransformer(transformerModel.Name)
            transformerInstance:SetModel(transformerClone)
            transformerInstance:Run()
            table.insert(transformers, transformerInstance)

            -- Copy to workspace
            transformerClone :SetPrimaryPartCFrame(plot.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
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

            -- Copy factory to workspace
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

end

onGameStart()

