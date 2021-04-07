local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local wsMapsFolder = Workspace:WaitForChild("Maps")
local wsFactoriesFolder = Workspace:WaitForChild("Factories")
local wsTransformersFolder = Workspace:WaitForChild("Transformers")

local assetsFolder = ServerStorage:WaitForChild("Assets")
local serverMapsFolder = assetsFolder:WaitForChild("Maps")
local serverConsumersFolder = assetsFolder:WaitForChild("Consumers")
local serverFactoriesFolder = assetsFolder:WaitForChild("Factories")
local serverTransformersFolder = assetsFolder:WaitForChild("Transformers")


local MAX_SEARCH_FOR_PLOTS = 1000


-- Find the source of an item
local function findSource(name)
  -- aing
end


-- Find random available plot on map
local function getAvailablePlot(map, inputStr)
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
      for _, transformer in pairs(serverTransformersFolder:GetChildren()) do
        if transformer.Name == inputStr then
          -- Find available plot on map
          local plot = getAvailablePlot(map, inputStr)
          if plot then
            plot:SetAttribute("AssetName", inputStr)

            -- Get its input and update the inputStr to follow the chain all the way back to the factory
            local transformerInputStr = transformer:GetAttribute("Input")
            if transformerInputStr then
              inputStr = transformerInputStr
            end

            -- Copy to workspace
            local clone = transformer:Clone()
            clone.PrimaryPart.Position = plot.Position
            clone.Parent = wsTransformersFolder
            break
          end
        end
      end
      for _, factory in pairs(serverFactoriesFolder:GetChildren()) do
        if factory.Name == inputStr then
          local partCount = #factory:GetChildren()
          print("   Factory: ".. factory.Name.. "; parts=".. tostring(partCount))

          -- Find available plot on map
          local plot = getAvailablePlot(map, inputStr)
          if plot then
            plot:SetAttribute("AssetName", inputStr)
            -- Copy to workspace
            local clone = factory:Clone()
            clone.PrimaryPart.Position = plot.Position
            clone.Parent = wsFactoriesFolder

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

