-- Avatars
--[[
Avatar rules:
  - Should be in ReplicatedStorage/Avatar/Characters/XX_Description
  - Top level must be a Character with PrimaryPart HumanoidRootPart
  - Optional: Add a Number Attribute named CostPoints to specify Points required to equip Character
  - Optional: Add a Number Attribute named CostRobux to specify Robux required to buy Character
  - Optional: Add Vector3 Attribute named ViewportCameraPosition to specify custom position for ViewportFrame Camera
  - Optional: Add Vector3 Attribute named ViewportTargetPositionOffset to specify target position offset for ViewportFrame Camera

  To make pets based on a template model but with different colors:
  - Create template model in ReplicatedStorage/Avatar/ShoulderPetTemplates/
  - The template model must have a part with "PrimaryPart" in the name, which will be set as the PrimaryPart of the copy
  - Add string Attribute named ModelTemplateName with name of template model
  - Add Color3 attribute named Color to rename all template Parts containing "ToColor" in name
]]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Themes = require(ReplicatedStorage.Themes)
local ViewportFrameFactory = require(ReplicatedStorage.Gui.ViewportFrameFactory)
local SoundModule = require(ReplicatedStorage.SoundModule)
local Avatars = require(ReplicatedStorage.Avatars)
local ModelUtil = require(ReplicatedStorage.ModelUtil)
local Util = require(ReplicatedStorage.Util)

local RunService = game:GetService("RunService")

local StarterGui = game:GetService("StarterGui")
local FrameFactory = require(StarterGui.FrameFactory)

local SelectCharacterRequestEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectCharacterRequest")
local SelectShoulderPetRequestEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SelectShoulderPetRequest")
local ProductIdsOwnedChangedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ProductIdsOwnedChanged")
local GetOwnedProductIdsFn = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("GetOwnedProductIds")

local CharacterFolder = ReplicatedStorage:WaitForChild("Avatar"):WaitForChild("Characters")
local ShoulderPetFolder = ReplicatedStorage:WaitForChild("Avatar"):WaitForChild("ShoulderPets")
local ShoulderPetTemplateFolder = ReplicatedStorage:WaitForChild("Avatar"):WaitForChild("ShoulderPetTemplates")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local CHARACTER_THUMB_SIZE_SCALE_X = 0.18
local CHARACTER_THUMB_SIZE_SCALE_Y = 0.07

local SHOULDER_PET_THUMB_SIZE_SCALE_X = 0.18
local SHOULDER_PET_THUMB_SIZE_SCALE_Y = 0.05

local INFO_FRAME_NAME = "InfoFrame"


local AvatarGui = {}


AvatarGui.Frame = nil
AvatarGui.OuterFrame = nil
AvatarGui.CharacterTabButton = nil
AvatarGui.CharacterScrollingFrame = nil
AvatarGui.ShoulderPetTabButton = nil
AvatarGui.ShoulderPetScrollingFrame = nil
AvatarGui.BoostsTabButton = nil
AvatarGui.BoostsScrollingFrame = nil

-- List of frames for this gui
local avatarFrames = {}


local function clearInfoFrames()
  local oldInfoFrame = AvatarGui.Frame:FindFirstChild(INFO_FRAME_NAME)
  if oldInfoFrame then
    oldInfoFrame:Destroy()
  end
end

-- Disable frames, except for exceptFrames (optional)
local function disableAvatarFrames(exceptFrames)
  for _, f in pairs(avatarFrames) do
    for __, except in pairs(exceptFrames) do
      if f == except then
        --print("if exceptFrames and f == exceptFrames then")
        f.Active = true
        f.Visible = true
      else
        --print("NOT if exceptFrames and f == exceptFrames then")
        f.Active = false
        f.Visible = false
      end
    end
  end

  clearInfoFrames()
end

local function initializeTabButton(buttonObject, title, yPositionScale, dependentFrameList)
  local zIndex = 1
  local tabShadow = Util:CreateInstance("Frame", {
      Name = title.. "TabShadow",
      Position = UDim2.new(-0.115, 0, yPositionScale+0.01, 0),
      Size = UDim2.new(0.15, 0, 0.1, 0),
      BackgroundTransparency = 0.0,
      BackgroundColor3 = Themes[Themes.CurrentTheme].TextColor2,
      ZIndex = zIndex,
    }, AvatarGui.Frame)
  local uiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(0, 10),
    }, tabShadow)

  zIndex += 1
  buttonObject = Util:CreateInstance("TextButton", {
      Name = title.. "TabButton",
      Position = UDim2.new(-0.12, 0, yPositionScale, 0),
      Size = UDim2.new(0.15, 0, 0.1, 0),
      BackgroundTransparency = 0.0,
      BackgroundColor3 = Themes[Themes.CurrentTheme].BorderColor,
      TextColor3 = Color3.fromRGB(190, 190, 49),
      TextStrokeTransparency = 1.0,
      Font = Enum.Font.LuckiestGuy,
      TextColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
      TextScaled = true,
      Text = title,
      ZIndex = zIndex,
    }, AvatarGui.Frame)
  local uiCorner = Util:CreateInstance("UICorner", {
      CornerRadius = UDim.new(0, 10),
    }, buttonObject)

  -- Add dependent frames to avatarFrames list
  for _, f in pairs(dependentFrameList) do
    table.insert(avatarFrames, f)
  end

  buttonObject.Activated:Connect(function()
    disableAvatarFrames(dependentFrameList)
  end)

  -- aing -- Temporary
  if title == "Boosts" then
    local comingSoon = Util:CreateInstance("TextLabel", {
        Name = "ComingSoon",
        Text = "Coming Soon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.4, 0, 0.5, 0),
        Size = UDim2.new(0.8, 0, 0.5, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        TextColor3 = Color3.new(1, 1, 0),
        Font = Enum.Font.FredokaOne,
        TextStrokeTransparency = 0.0,
        Rotation = -30,
        ZIndex = zIndex,
      }, buttonObject)
  end

end

local function initializeTabButtons()
  -- 05/22/2022 Removing option
  -- initializeTabButton(AvatarGui.CharacterTabButton, "Character", 0.30, {AvatarGui.CharacterScrollingFrame})

  initializeTabButton(AvatarGui.ShoulderPetTabButton, "Shoulder Pet", 0.45, {AvatarGui.ShoulderPetScrollingFrame})

  -- Maybe one day...
  -- initializeTabButton(AvatarGui.BoostsTabButton, "Boosts", 0.60, {AvatarGui.BoostsScrollingFrame})
end

local function initializeCharacterFrame()
  -- Scrolling frame
  AvatarGui.CharacterScrollingFrame = Util:CreateInstance("ScrollingFrame", {
      Name = "Characters",
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.335, 0, 0.55, 0),
      Size = UDim2.new(0.58, 0, 0.7, 0),
      CanvasSize = UDim2.new(0, 0, 4.0, 0),  -- TODO: Increase Y
      BackgroundTransparency = 0.0,
      BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
      BorderSizePixel = 2,
      BorderColor3 = Themes[Themes.CurrentTheme].BorderColor,
      ScrollBarImageColor3 = Themes[Themes.CurrentTheme].BorderColor,
    }, AvatarGui.Frame)
  local uiGridLayout = Util:CreateInstance("UIGridLayout", {
      CellSize = UDim2.new(CHARACTER_THUMB_SIZE_SCALE_X, 0, CHARACTER_THUMB_SIZE_SCALE_Y, 0),
      SortOrder = Enum.SortOrder.LayoutOrder,
    }, AvatarGui.CharacterScrollingFrame)

  -- Add character buttons
  -- Get sorted list of subdirectories
  local subdirNameList = {}
  for _, subdir in pairs(CharacterFolder:GetChildren()) do
    table.insert(subdirNameList, subdir.Name)
  end
  table.sort(subdirNameList)
  local layoutOrder = 1  -- Specify order for UIGridLayout
  for subdirIdx = 1, #subdirNameList do
    local subdirCharacters = CharacterFolder:WaitForChild(subdirNameList[subdirIdx]):GetChildren()
    for idx = 1, #subdirCharacters do
      --print("CharacterFolder: ".. model.Name)
      local model = subdirCharacters[idx]
      local charFrame = Util:CreateInstance("Frame", {
          Name = model.Name.. "Frame",
          BackgroundTransparency = 1.0,
          LayoutOrder = layoutOrder,
        }, AvatarGui.CharacterScrollingFrame)
      local viewport, clone = ViewportFrameFactory.GetViewportFrame(model, Vector3.new(-1.2, 2.0, -5.2))
      viewport.Parent = charFrame

      -- Thumbnail label (shows on bottom of character thumbnail)
      local thumbLabel = model:GetAttribute(Avatars.THUMB_LABEL_ATTR_NAME)
      local thumbTextLabel = nil
      if thumbLabel then
        thumbTextLabel = Util:CreateInstance("TextLabel", {
            Name = "thumbTextLabel",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.89, 0),
            Size = UDim2.new(0.8, 0, 0.15, 0),
            BackgroundTransparency = 1.0,
            TextColor3 = Color3.fromRGB(190, 190, 49),
            TextStrokeTransparency = 1.0,
            Font = Enum.Font.LuckiestGuy,
            TextScaled = true,
            Text = thumbLabel,
          }, charFrame)
      end

      -- If premium product, check if player owns product
      local costRobux = model:GetAttribute(Avatars.COST_ROBUX_ATTR_NAME)
      local productId = -1
      local productList = {}
      if costRobux then
        productId = model:GetAttribute(Avatars.PRODUCT_ID_ATTR_NAME)
        -- Update gui if products owned changes
        local function updateThumbLabel(productList)
          local isOwned = Util:Contains(productList, productId)
          if isOwned then
            thumbTextLabel.Text = "Owned"
          end
        end
        productList = GetOwnedProductIdsFn:InvokeServer()
        updateThumbLabel(productList)
        ProductIdsOwnedChangedEvent.OnClientEvent:Connect(updateThumbLabel)
      end

      -- Thumbnail button
      local charButton = Util:CreateInstance("TextButton", {
          Name = "ThumbnailButton",
          Position = UDim2.new(0.0, 0, 0.0, 0),
          Size = UDim2.new(1.0, 0, 1.0, 0),
          Transparency = 1.0,
        }, charFrame)
      charButton.Activated:Connect(function()
          -- Remove old Info frames
          clearInfoFrames()

          -- Info frame
          local infoFrame = Util:CreateInstance("Frame", {
              Name = INFO_FRAME_NAME,
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.8, 0, 0.55, 0),
              Size = UDim2.new(0.3, 0, 0.8, 0),
              BackgroundTransparency = 0.0,
              BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
              BorderSizePixel = 0,
            }, AvatarGui.Frame)

          local cloneViewportFrame = Util:CreateInstance("Frame", {
              Name = model.Name.. "CloneViewportFrame",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.45, 0),
              Size = UDim2.new(0.9, 0, 0.9, 0),
              BackgroundTransparency = 1.0,
            }, infoFrame)
          local viewportCopy, cloneCopy = ViewportFrameFactory.GetViewportFrame(model, Vector3.new(-1.2, 2.0, -5.2))
          viewportCopy.Parent = cloneViewportFrame

          local charTitle = Util:CreateInstance("TextLabel", {
              Name = "CharacterTitle",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.02, 0),
              Size = UDim2.new(0.8, 0, 0.1, 0),
              BackgroundTransparency = 1.0,
              TextScaled = true,
              Text = "",  -- This will be set to the selected model name and used in the remote event
              TextColor3 = Themes[Themes.CurrentTheme].TextColor2,
              TextStrokeTransparency = 1.0,
              Font = Enum.Font.FredokaOne,
            }, infoFrame)
          local charDescription = Util:CreateInstance("TextLabel", {
              Name = "CharacterDescription",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.83, 0),
              Size = UDim2.new(0.85, 0, 0.15, 0),
              BackgroundTransparency = 1.0,
              TextColor3 = Themes[Themes.CurrentTheme].TextColor,
              Font = Enum.Font.FredokaOne,
              TextScaled = true,
              --TextSize = 22,
              TextXAlignment = Enum.TextXAlignment.Center,
              TextYAlignment = Enum.TextYAlignment.Top,
              Text = "",  -- This will be set when a character icon is clicked
            }, infoFrame)
          local charEquipBtn = Util:CreateInstance("TextButton", {
              Name = "EquipCharacter",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.95, 0),
              Size = UDim2.new(0.5, 0, 0.15, 0),
              BackgroundTransparency = 0.0,
              BackgroundColor3 = Themes[Themes.CurrentTheme].BorderColor,
              BorderSizePixel = 0,
              Text = "   MORPH   ",
              Font = Enum.Font.Bangers,
              TextColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
              TextScaled = true,
            }, infoFrame)
          local uiCorner = Util:CreateInstance("UICorner", {
              CornerRadius = UDim.new(0, 10),
            }, charEquipBtn)

          charTitle.Text = model.Name
          SoundModule.PlayMouseClick(PlayerGui)

          -- Check for requirements
          local costPoints = model:GetAttribute(Avatars.COST_POINTS_ATTR_NAME)
          if costPoints then
            charDescription.Text = "Stars needed: ".. tostring(costPoints).. "\n"
          end
          if costRobux then
            local function showIfOwnProduct(productList)
              local isOwned = Util:Contains(productList, productId)
              if isOwned then
                charDescription.Text = "Owned\n"
              else
                charDescription.Text = charDescription.Text.. "Robux: ".. tostring(costRobux).. "\n"
              end
            end
            productList = GetOwnedProductIdsFn:InvokeServer()
            showIfOwnProduct(productList)
            -- Update gui if products owned changes
            ProductIdsOwnedChangedEvent.OnClientEvent:Connect(showIfOwnProduct)
          end

          charEquipBtn.Activated:Connect(function()
            SoundModule.PlayMouseClick(PlayerGui)
            -- 05/22/2022 Remove due to SelectCharacter.server.lua:transform() problem
            -- SelectCharacterRequestEvent:FireServer(subdirNameList[subdirIdx], charTitle.Text)
            --print(string.format("SelectCharacterRequestEvent:FireServer(subdirNameList[subdirIdx] %s, charTitle.Text %s)", subdirNameList[subdirIdx], charTitle.Text))
          end)

          -- Rotate model
          local degreesPerSecond = 20
          local function onHeartbeat(deltaTime)
            if AvatarGui.OuterFrame.Active and cloneCopy and cloneCopy.PrimaryPart then
              local deltaRotation = deltaTime * degreesPerSecond
              cloneCopy:SetPrimaryPartCFrame(cloneCopy.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(deltaRotation), 0))
              --print("rotate: ".. model.Name)
            end
          end
          RunService.Heartbeat:Connect(onHeartbeat)

        end)
      layoutOrder += 1
    end
  end  -- CharacterFolder
end

local function initializeShoulderPetFrame()
  -- Scrolling frame
  AvatarGui.ShoulderPetScrollingFrame = Util:CreateInstance("ScrollingFrame", {
      Name = "ShoulderPets",
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.335, 0, 0.55, 0),
      Size = UDim2.new(0.58, 0, 0.7, 0),
      CanvasSize = UDim2.new(0, 0, 4.0, 0),  -- TODO: Increase Y
      BackgroundTransparency = 0.0,
      BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
      BorderSizePixel = 2,
      BorderColor3 = Themes[Themes.CurrentTheme].BorderColor,
      ScrollBarImageColor3 = Themes[Themes.CurrentTheme].BorderColor,
      --Active = false,
      --Visible = false,
    }, AvatarGui.Frame)
  local uiGridLayout = Util:CreateInstance("UIGridLayout", {
      CellSize = UDim2.new(SHOULDER_PET_THUMB_SIZE_SCALE_X, 0, SHOULDER_PET_THUMB_SIZE_SCALE_Y, 0),
      SortOrder = Enum.SortOrder.LayoutOrder,
    }, AvatarGui.ShoulderPetScrollingFrame)

  -- Add pet buttons
  -- Get sorted list of subdirectories
  local subdirNameList = {}
  for _, subdir in pairs(ShoulderPetFolder:GetChildren()) do
    table.insert(subdirNameList, subdir.Name)
  end
  table.sort(subdirNameList)
  local layoutOrder = 1  -- Specify order for UIGridLayout
  for subdirIdx = 1, #subdirNameList do
    local subdirCharacters = ShoulderPetFolder:WaitForChild(subdirNameList[subdirIdx]):GetChildren()
    for idx = 1, #subdirCharacters do
      --print("ShoulderPetFolder: ".. model.Name)
      local model = subdirCharacters[idx]

      -- Check if the model is based on a template
      local templateModelName = model:GetAttribute(Avatars.TEMPLATE_MODEL_ATTR_NAME)
      if templateModelName then
        local existingAccessory = model:FindFirstChildWhichIsA("Accessory")
        if not existingAccessory then
          local templateModel = ShoulderPetTemplateFolder:WaitForChild(templateModelName, 1)
          if templateModel then
            local accessory = templateModel:FindFirstChildWhichIsA("Accessory")
            if accessory then
              local accessoryClone = accessory:Clone()
              accessoryClone.Parent = model
              -- Set PrimaryPart and color parts
              ModelUtil.SetPrimaryPartAndColors(model)
            end
          end
        end
      end

      local charFrame = Util:CreateInstance("Frame", {
          Name = model.Name.. "Frame",
          BackgroundTransparency = 1.0,
          LayoutOrder = layoutOrder,
        }, AvatarGui.ShoulderPetScrollingFrame)
      local viewport, clone = ViewportFrameFactory.GetViewportFrame(model, Vector3.new(-0.8, 1.2, -2.8))
      viewport.Parent = charFrame

      -- Thumbnail label (shows on bottom of character thumbnail)
      local thumbLabel = model:GetAttribute(Avatars.THUMB_LABEL_ATTR_NAME)
      local thumbTextLabel = nil
      if thumbLabel then
        thumbTextLabel = Util:CreateInstance("TextLabel", {
            Name = "thumbTextLabel",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.89, 0),
            Size = UDim2.new(0.8, 0, 0.15, 0),
            BackgroundTransparency = 1.0,
            TextColor3 = Color3.fromRGB(190, 190, 49),
            TextStrokeTransparency = 1.0,
            Font = Enum.Font.LuckiestGuy,
            TextScaled = true,
            Text = thumbLabel,
          }, charFrame)
      end

      -- If premium product, check if player owns product
      local costRobux = model:GetAttribute(Avatars.COST_ROBUX_ATTR_NAME)
      local productId = -1
      local productList = {}
      if costRobux then
        productId = model:GetAttribute(Avatars.PRODUCT_ID_ATTR_NAME)
        -- Update gui if products owned changes
        local function updateThumbLabel(productList)
          local isOwned = Util:Contains(productList, productId)
          if isOwned then
            thumbTextLabel.Text = "Owned"
          end
        end
        productList = GetOwnedProductIdsFn:InvokeServer()
        updateThumbLabel(productList)
        ProductIdsOwnedChangedEvent.OnClientEvent:Connect(updateThumbLabel)
      end

      -- Thumbnail button
      local charButton = Util:CreateInstance("TextButton", {
          Name = "ThumbnailButton",
          Position = UDim2.new(0.0, 0, 0.0, 0),
          Size = UDim2.new(1.0, 0, 1.0, 0),
          Transparency = 1.0,
        }, charFrame)
      charButton.Activated:Connect(function()
          -- Remove old Info frames
          clearInfoFrames()

          -- Info frame
          local infoFrame = Util:CreateInstance("Frame", {
              Name = INFO_FRAME_NAME,
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.8, 0, 0.55, 0),
              Size = UDim2.new(0.3, 0, 0.8, 0),
              BackgroundTransparency = 0.0,
              BackgroundColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
              BorderSizePixel = 0,
            }, AvatarGui.Frame)

          local cloneViewportFrame = Util:CreateInstance("Frame", {
              Name = model.Name.. "CloneViewportFrame",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.45, 0),
              Size = UDim2.new(0.9, 0, 0.9, 0),
              BackgroundTransparency = 1.0,
            }, infoFrame)
          local viewportCopy, cloneCopy = ViewportFrameFactory.GetViewportFrame(model, Vector3.new(-1.0, 1.0, -3.6))
          viewportCopy.Parent = cloneViewportFrame

          local charTitle = Util:CreateInstance("TextLabel", {
              Name = "CharacterTitle",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.02, 0),
              Size = UDim2.new(0.8, 0, 0.1, 0),
              BackgroundTransparency = 1.0,
              TextScaled = true,
              Text = "",  -- This will be set to the selected model name and used in the remote event
              TextColor3 = Themes[Themes.CurrentTheme].TextColor2,
              TextStrokeTransparency = 1.0,
              Font = Enum.Font.FredokaOne,
            }, infoFrame)
          local charDescription = Util:CreateInstance("TextLabel", {
              Name = "CharacterDescription",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.83, 0),
              Size = UDim2.new(0.85, 0, 0.15, 0),
              BackgroundTransparency = 1.0,
              TextColor3 = Themes[Themes.CurrentTheme].TextColor,
              Font = Enum.Font.FredokaOne,
              TextScaled = true,
              --TextSize = 22,
              TextXAlignment = Enum.TextXAlignment.Center,
              TextYAlignment = Enum.TextYAlignment.Top,
              Text = "",  -- This will be set when a character icon is clicked
            }, infoFrame)
          local shoulderPetEquipBtn = Util:CreateInstance("TextButton", {
              Name = "EquipCharacter",
              AnchorPoint = Vector2.new(0.5, 0.5),
              Position = UDim2.new(0.5, 0, 0.95, 0),
              Size = UDim2.new(0.5, 0, 0.15, 0),
              BackgroundTransparency = 0.0,
              BackgroundColor3 = Themes[Themes.CurrentTheme].BorderColor,
              BorderSizePixel = 0,
              Text = "   EQUIP   ",
              Font = Enum.Font.Bangers,
              TextColor3 = Themes[Themes.CurrentTheme].InnerFrameColor,
              TextScaled = true,
            }, infoFrame)
          local uiCorner = Util:CreateInstance("UICorner", {
              CornerRadius = UDim.new(0, 10),
            }, shoulderPetEquipBtn)

          charTitle.Text = model.Name
          SoundModule.PlayMouseClick(PlayerGui)

          -- Check for requirements
          local costPoints = model:GetAttribute(Avatars.COST_POINTS_ATTR_NAME)
          if costPoints then
            charDescription.Text = "Stars needed: ".. tostring(costPoints).. "\n"
          end
          if costRobux then
            local function showIfOwnProduct(productList)
              local isOwned = Util:Contains(productList, productId)
              if isOwned then
                charDescription.Text = "Owned\n"
              else
                charDescription.Text = charDescription.Text.. "Robux: ".. tostring(costRobux).. "\n"
              end
            end
            productList = GetOwnedProductIdsFn:InvokeServer()
            showIfOwnProduct(productList)
            -- Update gui if products owned changes
            ProductIdsOwnedChangedEvent.OnClientEvent:Connect(showIfOwnProduct)
          end

          shoulderPetEquipBtn.Activated:Connect(function()
            SoundModule.PlayMouseClick(PlayerGui)
            SelectShoulderPetRequestEvent:FireServer(subdirNameList[subdirIdx], charTitle.Text)
            --print(string.format("SelectShoulderPetRequestEvent:FireServer(subdirNameList[subdirIdx] %s, charTitle.Text %s)", subdirNameList[subdirIdx], charTitle.Text))
          end)

          -- Rotate model
          local degreesPerSecond = 20
          local function onHeartbeat(deltaTime)
            if AvatarGui.OuterFrame.Active and cloneCopy and cloneCopy.PrimaryPart then
              local deltaRotation = deltaTime * degreesPerSecond
              cloneCopy:SetPrimaryPartCFrame(cloneCopy.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(deltaRotation), 0))
              --print("rotate: ".. model.Name)
            end
          end
          RunService.Heartbeat:Connect(onHeartbeat)

        end)
      layoutOrder += 1
    end
  end  -- ShoulderPetFolder
end

function AvatarGui.Initialize()
  if not AvatarGui.Frame then
    AvatarGui.Frame, AvatarGui.OuterFrame = FrameFactory.GetLargeLobbyFrame()
    AvatarGui.Frame.Name = "AvatarGui.Frame"
    AvatarGui.OuterFrame.Name = "AvatarGui.OuterFrame"
    AvatarGui.OuterFrame.Position = UDim2.new(0.5, 0, 0.4, 0)

    -- Title
    local title = Util:CreateInstance("TextLabel", {
        Name = "Avatar",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.08, 0),
        Size = UDim2.new(0.3, 0, 0.12, 0),
        BackgroundTransparency = 1.0,
        TextScaled = true,
        Text = "AVATAR",
        TextColor3 = Themes[Themes.CurrentTheme].TextColor,
        Font = Enum.Font.FredokaOne,
      }, AvatarGui.Frame)

    -- 05/22/2022 Disabling character morph option
    -- initializeCharacterFrame()

    initializeShoulderPetFrame()

    initializeTabButtons()

  end
  return AvatarGui.OuterFrame
end

function AvatarGui.Open()
  if not AvatarGui.Frame then
    AvatarGui.Initialize()
  end
  AvatarGui.OuterFrame.Active = true
  AvatarGui.OuterFrame.Visible = true
end

function AvatarGui.Close()
  if not AvatarGui.Frame then
    AvatarGui.Initialize()
  end
  AvatarGui.OuterFrame.Active = false
  AvatarGui.OuterFrame.Visible = false
end

function AvatarGui.Toggle()
  if AvatarGui.OuterFrame.Active == true then
    AvatarGui.OuterFrame.Active = false
    AvatarGui.OuterFrame.Visible = false
  else
    AvatarGui.OuterFrame.Active = true
    AvatarGui.OuterFrame.Visible = true
  end
end

return AvatarGui

