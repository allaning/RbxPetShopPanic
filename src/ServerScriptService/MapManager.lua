-- Maps should be in folders divided by level. The folders should be named as the level, e.g. "1", "2", etc.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Themes = require(ReplicatedStorage.Themes)
local Util = require(ReplicatedStorage.Util)
local Promise = require(ReplicatedStorage.Vendor.Promise)

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

local consumerClass = require(ReplicatedStorage.Consumers.Consumer)

local consumerFactory = require(ReplicatedStorage.Consumers.ConsumerFactory)
local productFactory = require(ReplicatedStorage.Products.ProductFactory)
local factoryFactory = require(ReplicatedStorage.Factories.FactoryFactory)
local transformerFactory = require(ReplicatedStorage.Transformers.TransformerFactory)

local trashBinClass = require(ReplicatedStorage.TrashBins.TrashBin)


local WALL_STR = "Wall"
local FLOOR_STR = "Floor"
local PRODUCER_PLOT_STR = "ProducerPlot"
local CONSUMER_PLOT_STR = "ConsumerPlot"
local TRASH_BIN_PLOT_STR = "TrashBinPlot"
local TABLE_PLOT_STR = "TablePlot"
local SPAWN_PLOT_STR = "SpawnPlot"

local MAX_SEARCH_FOR_PLOTS = 1000


local MapManager = {}

MapManager.MAP_LEVEL_ATTRIBUTE_NAME = "Level"
MapManager.MAP_LEVEL_MULTIPLIER = 1


-- List of inputs
MapManager.inputs = {}

-- List of consumer instances
MapManager.consumers = {}

-- List of factory instances
MapManager.factories = {}

-- List of transformer instances
MapManager.transformers = {}

-- List of product instances
MapManager.products = {}

-- List of trash bin instances
MapManager.trashBins = {}

-- List of table models
MapManager.tableModels = {}

-- List of spawn plot parts
MapManager.spawnPlotParts = {}


-- Iterate over table and return true if it contains an object with object:GetName() matching name
local function containsInstanceNamed(tab, name)
  if Util:TableLength(tab) > 0 then
    for index, instance in pairs(tab) do
      if instance:GetName() == name then
        return true, index
      end
    end
  end
  return false, 0
end


-- Find random available plot on map
local function getAvailablePlot(map, plotType)
  local rand = Random.new()
  local mapObjects = map:GetChildren()
  while #mapObjects > 0 do
    local randNum = rand:NextInteger(1, #mapObjects)
    local obj = mapObjects[randNum]
    if string.find(obj.Name, plotType) then
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
  return getAvailablePlot(map, CONSUMER_PLOT_STR)
end

local function getAvailableProducerPlot(map)
  return getAvailablePlot(map, PRODUCER_PLOT_STR)
end


function MapManager.ColorizeMap(map)
  -- Choose random color scheme
  local rand = Random.new()
  local color = Themes.ColorSchemes[ rand:NextInteger(1, #(Themes.ColorSchemes)) ]

  local wallColor = color["Wall"]
  for _, obj in pairs(map:GetChildren()) do
    --print("  map: ".. obj.Name)
    if string.find(obj.Name, WALL_STR) then
      --print ("wallColor: ".. color["Wall"].R.. ",".. color["Wall"].G.. ",".. color["Wall"].B)
      local colorObj = Color3.fromRGB( color["Wall"].R, color["Wall"].G, color["Wall"].B )
      obj.Color = colorObj
    elseif string.find(obj.Name, FLOOR_STR) then
      --print ("floorColor: ".. color["Floor"].R.. ",".. color["Floor"].G.. ",".. color["Floor"].B)
      local colorObj = Color3.fromRGB( color["Floor"].R, color["Floor"].G, color["Floor"].B )
      obj.Color = colorObj
    end
  end
end

local function createConsumer(consumerModel, inputStr, map, currentConsumerUid, difficultyLevel)
  print("aing function createConsumer(consumerModel, inputStr, map, currentConsumerUid, difficultyLevel=".. difficultyLevel)
  currentConsumerUid = currentConsumerUid or consumerClass.UID_UNINITIALIZED
  local consumerInstance = consumerFactory.GetConsumer(consumerModel.Name, inputStr, difficultyLevel)
  local consumerClone = consumerModel:Clone()
  consumerInstance:SetModel(consumerClone)
  consumerInstance:SetUid(currentConsumerUid)
  local consumerPlot = getAvailableConsumerPlot(map)
  if consumerPlot then
    consumerPlot:SetAttribute("AssetName", consumerInstance:GetName())
    local consumerHeightPos = Vector3.new(0, consumerClone.PrimaryPart.Position.Y, 0)
    -- Check for custom position offset
    local primaryPartPositionOffset = consumerClone:GetAttribute("PrimaryPartPositionOffset") or Vector3.new(0, 0, 0)
    consumerClone:SetPrimaryPartCFrame(consumerPlot.CFrame + consumerHeightPos + primaryPartPositionOffset)

    -- Set consumer direction to face the middle
    local targetPos = Vector3.new(0, consumerClone.PrimaryPart.Position.Y, consumerClone.PrimaryPart.Position.Z)
    consumerClone.PrimaryPart.CFrame = CFrame.new(consumerClone.PrimaryPart.Position, targetPos)

    -- consumerClone.PrimaryPart.CFrame = consumerPlot.CFrame -- This will work if model is welded
    consumerClone.Parent = wsConsumersFolder
  end
  return consumerInstance
end

local function createTransformer(transformerModel, outputProductStr, map)
  -- Find available plot on map
  local plot = getAvailableProducerPlot(map)
  if plot then
    plot:SetAttribute("AssetName", outputProductStr)
    local transformerClone = transformerModel:Clone()
    local transformTimeSec = transformerClone:GetAttribute("TransformTimeSec")
    local transformerName = transformerClone:GetAttribute("TransformerName") or transformerClone.Name

    -- Create product
    local productModel = serverProductsFolder:FindFirstChild(outputProductStr)
    local productInstance = productFactory.GetProduct(outputProductStr, productModel)

    -- Get its input and set the new transformer's input (a return value) to follow the chain all the way back to the factory
    local inputStr = ""
    local transformerInputStr = transformerModel:GetAttribute(consumerClass.INPUT_ATTR_NAME)
    if transformerInputStr then
      inputStr = transformerInputStr
    end

    -- Create object instances
    local transformerInstance = transformerFactory.GetTransformer(transformerName, transformerInputStr, transformTimeSec)
    transformerInstance:SetModel(transformerClone)
    transformerInstance:SetProduct(productInstance)
    transformerInstance:Run()

    -- Move to workspace
    transformerClone:SetPrimaryPartCFrame(plot.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
    transformerClone.Parent = wsTransformersFolder

    return transformerInstance, productInstance, inputStr
  end
end

local function createFactory(factoryModel, inputStr, map)
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

    -- Move factory to workspace
    factoryClone:SetPrimaryPartCFrame(plot.CFrame) -- Set PrimaryPart CFrame so whole model moves with it
    factoryClone.Parent = wsFactoriesFolder

    return factoryInstance, productInstance
  end
end

local function createTrashBinAtPlot(trashBinModel, plot)
  -- Get copy of trash bin
  local trashBinClone = trashBinModel:Clone()

  -- Create object instance
  local trashBinInstance = trashBinClass.new()
  trashBinInstance:SetModel(trashBinClone)
  trashBinInstance:Run()

  -- Move to workspace
  trashBinClone:SetPrimaryPartCFrame(plot.CFrame)
  trashBinClone.Parent = wsTrashBinsFolder

  return trashBinInstance
end

local function createTableAtPlot(tableModel, plot)
  -- Copy table
  local tableClone = tableModel:Clone()

  -- Move to workspace
  tableClone:SetPrimaryPartCFrame(plot.CFrame)
  tableClone.Parent = wsTablesFolder

  return tableClone
end

function MapManager.GetSpawns()
  if #(MapManager.spawnPlotParts) > 0 then
    return MapManager.spawnPlotParts
  end
end

function MapManager.GetNumConsumers()
  return #(MapManager.consumers)
end

local function cleanup(obj)
  if obj[Cleanup] then
    obj:Cleanup()
  end
end

local function cleanupList(list)
  for idx = #list, 1, -1 do
    cleanup(list[idx])
  end
end

local function destroyObjectList(list)
  for _, obj in pairs(list) do
    obj:Destroy()
  end
end

function MapManager.Cleanup(map)
  cleanupList(MapManager.consumers)
  MapManager.consumers = {}
  cleanupList(MapManager.factories)
  MapManager.factories = {}
  cleanupList(MapManager.transformers)
  MapManager.transformers = {}
  cleanupList(MapManager.products)
  MapManager.products = {}
  cleanupList(MapManager.trashBins)
  MapManager.trashBins = {}

  destroyObjectList(MapManager.tableModels)
  MapManager.tableModels = {}
  destroyObjectList(MapManager.spawnPlotParts)
  MapManager.spawnPlotParts = {}

  map:Destroy()

  -- Destroy other objects in Workspace
  destroyObjectList(wsConsumersFolder:GetChildren())
  destroyObjectList(wsFactoriesFolder:GetChildren())
  destroyObjectList(wsTransformersFolder:GetChildren())
  destroyObjectList(wsTablesFolder:GetChildren())
  destroyObjectList(wsTrashBinsFolder:GetChildren())
end

function MapManager.InitializeMap(level, playerCount)
  local playerCount = playerCount or 1

  -- Choose random map of specified level
  local rand = Random.new()
  local levelMapFolder = serverMapsFolder:WaitForChild(level)
  local levelMaps = levelMapFolder:GetChildren()
  local randomMap = levelMaps[ rand:NextInteger(1, #levelMaps) ]
  --aing randomMap = serverMapsFolder["3"]:FindFirstChild("3.2") --aing testing specific map

  -- Create map
  local map = randomMap:Clone()
  -- Make plots transparent
  for _, obj in pairs(map:GetDescendants()) do
    if string.find(obj.Name, CONSUMER_PLOT_STR) or string.find(obj.Name, PRODUCER_PLOT_STR) or string.find(obj.Name, TRASH_BIN_PLOT_STR) or string.find(obj.Name, TABLE_PLOT_STR) or string.find(obj.Name, SPAWN_PLOT_STR) then
      obj.Transparency = 1
    end
  end
  map.Parent = wsMapsFolder

  -- Get map level
  local mapLevel = map:GetAttribute(MapManager.MAP_LEVEL_ATTRIBUTE_NAME) or 1

  -- Look for the consumers and find their producers
  local currentConsumerUid = 1
  for consumerModelIdx, consumerModel in pairs(serverConsumersFolder:GetChildren()) do
    local inputAttribute = consumerModel:GetAttribute(consumerClass.INPUT_ATTR_NAME)
    print("Consumer: ".. consumerModel.Name.. "; Input=".. inputAttribute)

    -- Check if consumer has a map level requirement
    local consumerMapLevel = consumerModel:GetAttribute(consumerClass.MINIMUM_MAP_LEVEL) or 1
    if mapLevel >= consumerMapLevel then
      -- Create consumer
      local consumerInstance = createConsumer(consumerModel, inputAttribute, map, currentConsumerUid, playerCount)
      currentConsumerUid += 1
      table.insert(MapManager.consumers, consumerInstance)

      -- Process multiple inputs
      -- Make sure it creats all product factories
      local consumerInputs = string.split(inputAttribute, consumerClass.INPUT_DELIMITER_STR)
      for _, inputStr in ipairs(consumerInputs) do
        inputStr = Util:Trim(inputStr)
        print("In MapManager.InitializeMap() inputStr=".. inputStr)

        -- Find the producers of the input (the names should match)
        -- Everything should start from a Factory (versus Transformer or Aggregator)
        local isDoneFindingFactory = false
        local count = 0
        while not isDoneFindingFactory do
          for _, transformerModel in pairs(serverTransformersFolder:GetChildren()) do
            -- Note that for Transformers, the Transformer name is the name of the output product
            if transformerModel.Name == inputStr then
              -- Found Transformer that outputs product named inputStr

              -- Check if this is a new Transformer or a repeat
              if not containsInstanceNamed(MapManager.transformers, inputStr) then
                -- This is a new Transformer
                local transformerInstance, productInstance, newInputStr = createTransformer(transformerModel, inputStr, map)
                if transformerInstance and productInstance and newInputStr then
                  -- Update current Consumer with the product info
                  consumerInstance:SetInput(inputStr)
                  consumerInstance:SetInputModel(productInstance:GetModel()) -- TODO: refactor
                  print("consumerInstance:SetInputModel(productInstance:GetModel() ".. productInstance:GetName())

                  table.insert(MapManager.transformers, transformerInstance)
                  table.insert(MapManager.products, productInstance)
                  table.insert(MapManager.inputs, inputStr)
                  inputStr = newInputStr
                  break
                end
              else
                -- This Transformer was already processed
                -- Get its input to follow the chain all the way back to the factory
                local transformerInputStr = transformerModel:GetAttribute(consumerClass.INPUT_ATTR_NAME)
                if transformerInputStr then
                  inputStr = transformerInputStr
                  break
                end
              end
            end
          end
          for _, factoryModel in pairs(serverFactoriesFolder:GetChildren()) do
            if factoryModel.Name == inputStr then
              -- Check if this is a new Factory or a repeat
              if not containsInstanceNamed(MapManager.factories, inputStr) then
                -- This is a new Factory
                local factoryInstance, productInstance = createFactory(factoryModel, inputStr, map)
                if factoryInstance and productInstance then
                  table.insert(MapManager.factories, factoryInstance)
                  table.insert(MapManager.products, productInstance)
                  table.insert(MapManager.inputs, inputStr)

                  isDoneFindingFactory = true
                  break
                end
              else
                -- This Factory was already processed
                -- Do nothing
              end
            end
          end

          count += 1
          if count > MAX_SEARCH_FOR_PLOTS then
            isDoneFindingFactory = true
          end
        end -- while
      end

      -- Start the consumer
      consumerInstance:Run()

    end -- consumer
  end -- consumerMapLevel


  -- Place tables and trash bins
  local trashBinModel = serverTrashBinsFolder:WaitForChild("TrashBin")
  local tableModel = serverTablesFolder:WaitForChild("Table")
  for _, obj in pairs(map:GetChildren()) do
    if string.find(obj.Name, TRASH_BIN_PLOT_STR) then
      local trashBinInstance = createTrashBinAtPlot(trashBinModel, obj)
      table.insert(MapManager.trashBins, trashBinInstance)
    elseif string.find(obj.Name, TABLE_PLOT_STR) then
      local tableClone = createTableAtPlot(tableModel, obj)
      table.insert(MapManager.tableModels, tableClone)
    end
  end

  -- Fill in empty producer plots
  local emptyProducererPlot = getAvailableProducerPlot(map)
  while emptyProducererPlot do
    emptyProducererPlot:SetAttribute("AssetName", "Table")

    -- Copy table
    local tableClone = serverTablesFolder:FindFirstChild("Table"):Clone()

    -- Move to workspace
    tableClone:SetPrimaryPartCFrame(emptyProducererPlot.CFrame)
    tableClone.Parent = wsTablesFolder

    emptyProducererPlot = getAvailableProducerPlot(map)
  end

  -- Put spawn plots in table
  local mapObjects = map:GetChildren()
  for idx, object in pairs(mapObjects) do
    if string.find(object.Name, SPAWN_PLOT_STR) then
      table.insert(MapManager.spawnPlotParts, object)
    end
  end

  MapManager.ColorizeMap(map)

  -- Add ceiling barrier to block cheaters
  local ceilingBarrier = Util:CreateInstance("Part", {
      Name = "ceilingBarrier",
      Position = Vector3.new(map.PrimaryPart.Position.X, 12, map.PrimaryPart.Position.Z),
      Size = Vector3.new(200, 1, 160),
      Anchored = true,
      CastShadow = false,
      Transparency = 1.0,
      CanCollide = true,
    }, map)

  return map

end

function MapManager.Initialize()
  for idx, mapFolder in pairs(serverMapsFolder:GetChildren()) do
    Promise.try(function()
      local mapLevel = tonumber(mapFolder.Name)
      -- Set map models to level based on mapFolder name
      for _, mapModel in pairs(mapFolder:GetChildren()) do
        mapModel:SetAttribute(MapManager.MAP_LEVEL_ATTRIBUTE_NAME, mapLevel)
      end
    end)
  end
end

return MapManager
