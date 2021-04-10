local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local wsMapsFolder = Workspace:WaitForChild("Maps")
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

local productFactory = require(ReplicatedStorage.Products.ProductFactory)
local product = require(ReplicatedStorage.Products.Product)

local factoryFactory = require(ReplicatedStorage.Factories.FactoryFactory)
local factory = require(ReplicatedStorage.Factories.Factory)


local MAX_SEARCH_FOR_PLOTS = 1000


-- List of factory instances
local factories = {}


-- Find random available plot on map
local function getAvailablePlot(map)
  local rand = Random.new()
  local mapObjects = map:GetChildren()
  while #mapObjects > 0 do
    local randNum = rand:NextInteger(1, #mapObjects)
    local obj = mapObjects[randNum]
    if obj.Name == "ProducerPlot" then
      local assetName = obj:GetAttribute("AssetName")
      if assetName == "" then
        --print("       Found available plot")
        return obj
      end
    end
    table.remove(mapObjects, randNum)
  end
end


-- Detect when prompt is triggered
local function onPromptTriggered(promptObject, player)
  print("onPromptTriggered: ".. promptObject.Name)
  local product = promptObject.Parent.Parent
  local character = Util:GetCharacterFromPlayer(player)

  -- Weld product to character
  local hand = Util:GetRightHandFromPlayer(player)
  if hand then
    product.CFrame = hand.CFrame
    Util:WeldModelToPart(product, hand)
  else
    error("Unable to find hand for ".. player.Name)
  end

  -- Reparent the product to the player
  local productsFolder = character:WaitForChild("Products", 2)
  if not productsFolder then
    productsFolder = Instance.new("Folder", character)
    productsFolder.Name = "Products"
  end
  product.Parent = productsFolder

  -- Destroy the proximity prompt
  local promptAttachment = product:WaitForChild("PromptAttachment")
  if promptAttachment then
    promptAttachment:Destroy()
  end

end

-- Connect prompt events to handling functions
ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)


local function onGameStart()
  -- Select a map
  -- aing Hardcoded for now
  local map = serverMapsFolder:WaitForChild("Level1_1")
  -- Make plots transparent
  for _, obj in pairs(map:GetDescendants()) do
    if obj.Name == "ConsumerPlot" or obj.Name == "ProducerPlot" then
      obj.Transparency = 1
    end
  end
  map.Parent = wsMapsFolder

  -- Look for the consumers and find their producers
  for _, consumer in pairs(serverConsumersFolder:GetChildren()) do
    local partCount = #consumer:GetChildren()
    print("Consumer: ".. consumer.Name)
    local inputStr = consumer:GetAttribute("Input")
    print("  Input=".. inputStr)

    -- Find the producers of the input (the names should match)
    -- Everything should start from a Factory (versus Transformer or Aggregator)
    local isDone = false
    local count = 0
    while not isDone do
      for _, transformerModel in pairs(serverTransformersFolder:GetChildren()) do
        if transformerModel.Name == inputStr then
          -- Find available plot on map
          local plot = getAvailablePlot(map)
          if plot then
            plot:SetAttribute("AssetName", inputStr)

            -- Get its input and update the inputStr to follow the chain all the way back to the factory
            local transformerInputStr = transformerModel:GetAttribute("Input")
            if transformerInputStr then
              inputStr = transformerInputStr
            end

            -- Copy to workspace
            local transformerClone = transformerModel:Clone()
            transformerClone.PrimaryPart.Position = plot.Position
            transformerClone.Parent = wsTransformersFolder
            break
          end
        end
      end
      for _, factoryModel in pairs(serverFactoriesFolder:GetChildren()) do
        if factoryModel.Name == inputStr then
          local partCount = #factoryModel:GetChildren()
          print("   Factory: ".. factoryModel.Name.. "; parts=".. tostring(partCount))

          -- Find available plot on map
          local plot = getAvailablePlot(map)
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

