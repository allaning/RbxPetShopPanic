local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Themes = require(ReplicatedStorage.Themes)
local Util = require(ReplicatedStorage.Util)

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

local MAX_SEARCH_FOR_PLOTS = 1000


local MapManager = {}


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

local function createConsumer(consumerModel, inputStr, map, currentConsumerUid)
  currentConsumerUid = currentConsumerUid or consumerClass.UID_UNINITIALIZED
  local consumerInstance = consumerFactory.GetConsumer(consumerModel.Name, inputStr)
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
  map:Destroy()
  cleanupList(MapManager.consumers)
  cleanupList(MapManager.factories)
  cleanupList(MapManager.transformers)
  cleanupList(MapManager.products)
  cleanupList(MapManager.trashBins)
  destroyObjectList(MapManager.tableModels)
  destroyObjectList(MapManager.spawnPlotParts)

  -- Destroy objects in Workspace
  destroyObjectList(wsConsumersFolder:GetChildren())
  destroyObjectList(wsFactoriesFolder:GetChildren())
  destroyObjectList(wsTransformersFolder:GetChildren())
  destroyObjectList(wsTablesFolder:GetChildren())
  destroyObjectList(wsTrashBinsFolder:GetChildren())
end

function MapManager.InitializeMap()
  -- aing Hardcoded for now
  local map = serverMapsFolder:WaitForChild("Level 1"):WaitForChild("1.1"):Clone()
  -- Make plots transparent
  for _, obj in pairs(map:GetDescendants()) do
    if obj.Name == "ConsumerPlot" or obj.Name == "ProducerPlot" or obj.Name == "TrashBinPlot" or obj.Name == "TablePlot" or obj.Name == "SpawnPlot" then
      obj.Transparency = 1
    end
  end
  map.Parent = wsMapsFolder

  -- Look for the consumers and find their producers
  local currentConsumerUid = 1
  for consumerModelIdx, consumerModel in pairs(serverConsumersFolder:GetChildren()) do
    local inputAttribute = consumerModel:GetAttribute(consumerClass.INPUT_ATTR_NAME)
    print("Consumer: ".. consumerModel.Name.. "; Input=".. inputAttribute)

    -- Create consumer
    local consumerInstance = createConsumer(consumerModel, inputAttribute, map, currentConsumerUid)
    currentConsumerUid += 1
    table.insert(MapManager.consumers, consumerInstance)

    -- Process multiple inputs
    -- TODO: Make sure it creats all product factories
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


  -- Place tables and trash bins
  local trashBinModel = serverTrashBinsFolder:WaitForChild("TrashBin")
  local tableModel = serverTablesFolder:WaitForChild("Table")
  for _, obj in pairs(map:GetChildren()) do
    if obj.Name == "TrashBinPlot" then
      local trashBinInstance = createTrashBinAtPlot(trashBinModel, obj)
      table.insert(MapManager.trashBins, trashBinInstance)
    elseif obj.Name == "TablePlot" then
      local tableClone = createTableAtPlot(tableModel, obj)
      table.insert(MapManager.tableModels, tableClone)
    end
  end

  -- Fill in empty producer plots
  local emptyConsumerPlot = getAvailableProducerPlot(map)
  while emptyConsumerPlot do
    emptyConsumerPlot:SetAttribute("AssetName", "Table")

    -- Copy table
    local tableClone = serverTablesFolder:FindFirstChild("Table"):Clone()

    -- Move to workspace
    tableClone:SetPrimaryPartCFrame(emptyConsumerPlot.CFrame)
    tableClone.Parent = wsTablesFolder

    emptyConsumerPlot = getAvailableProducerPlot(map)
  end

  -- Put spawn plots in table
  local mapObjects = map:GetChildren()
  for idx, object in pairs(mapObjects) do
    if object.Name == "SpawnPlot" then
      table.insert(MapManager.spawnPlotParts, object)
    end
  end

  MapManager.ColorizeMap(map)

  return map

end

return MapManager
