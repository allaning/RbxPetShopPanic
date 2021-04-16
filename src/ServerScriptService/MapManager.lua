local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Themes = require(ReplicatedStorage.Themes)

local wsMapsFolder = Workspace:WaitForChild("Maps")
local wsConsumersFolder = Workspace:WaitForChild("Consumers")
local wsFactoriesFolder = Workspace:WaitForChild("Factories")
local wsTransformersFolder = Workspace:WaitForChild("Transformers")
local wsTablesFolder = Workspace:WaitForChild("Tables")
local wsTrashBinsFolder = Workspace:WaitForChild("TrashBins")

local assetsFolder = ServerStorage:WaitForChild("Assets")
local serverMapsFolder = assetsFolder:WaitForChild("Maps")
local serverConsumersFolder = assetsFolder:WaitForChild("Consumers")
local serverFactoriesFolder = assetsFolder:WaitForChild("Factories")
local serverProductsFolder = assetsFolder:WaitForChild("Products")
local serverTransformersFolder = assetsFolder:WaitForChild("Transformers")
local serverTablesFolder = assetsFolder:WaitForChild("Tables")
local serverTrashBinsFolder = assetsFolder:WaitForChild("TrashBins")

local consumerFactory = require(ReplicatedStorage.Consumers.ConsumerFactory)
local productFactory = require(ReplicatedStorage.Products.ProductFactory)
local factoryFactory = require(ReplicatedStorage.Factories.FactoryFactory)
local transformerFactory = require(ReplicatedStorage.Transformers.TransformerFactory)

local trashBinClass = require(ReplicatedStorage.TrashBins.TrashBin)

local MAX_SEARCH_FOR_PLOTS = 1000


local MapManager = {}


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


function MapManager.ColorizeMap(map)
  -- Choose random color scheme
  local rand = Random.new()
  local color = Themes.ColorSchemes[ rand:NextInteger(1, #(Themes.ColorSchemes)) ]

  local wallColor = color["Wall"]
  for _, obj in pairs(map:GetChildren()) do
    --print("  map: ".. obj.Name)
    if obj.Name == "Wall" then
      --print ("wallColor: ".. color["Wall"].R.. ",".. color["Wall"].G.. ",".. color["Wall"].B)
      local colorObj = Color3.fromRGB( color["Wall"].R, color["Wall"].G, color["Wall"].B )
      obj.Color = colorObj
    elseif obj.Name == "Floor" then
      --print ("floorColor: ".. color["Floor"].R.. ",".. color["Floor"].G.. ",".. color["Floor"].B)
      local colorObj = Color3.fromRGB( color["Floor"].R, color["Floor"].G, color["Floor"].B )
      obj.Color = colorObj
    end
  end
end

function MapManager.InitializeMap()
  -- aing Hardcoded for now
  local map = serverMapsFolder:WaitForChild("Level1"):WaitForChild("1.1")
  -- Make plots transparent
  for _, obj in pairs(map:GetDescendants()) do
    if obj.Name == "ConsumerPlot" or obj.Name == "ProducerPlot" or obj.Name == "TrashBinPlot" or obj.Name == "TablePlot" then
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


  -- Place tables and trash bins
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
    elseif obj.Name == "TablePlot" then
      -- Copy table
      local tableClone = serverTablesFolder:FindFirstChild("Table"):Clone()

      -- Move to workspace
      tableClone:SetPrimaryPartCFrame(obj.CFrame)
      tableClone.Parent = wsTablesFolder
    end
  end

  -- Fill in empty producer plots
  local emptyConsumerPlot = getAvailableProducerPlot(map)
  while emptyConsumerPlot do
    emptyConsumerPlot:SetAttribute("AssetName", "Table")

    -- Copy table
    local tableClone = serverTablesFolder:FindFirstChild("Table"):Clone()

    -- Move to workspace
    tableClone:SetPrimaryPartCFrame(emptyConsumerPlot .CFrame)
    tableClone.Parent = wsTablesFolder

    emptyConsumerPlot = getAvailableProducerPlot(map)
  end

  MapManager.ColorizeMap(map)

  return map

end

return MapManager
