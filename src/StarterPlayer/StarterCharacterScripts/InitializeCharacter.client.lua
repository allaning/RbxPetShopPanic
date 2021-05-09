local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Util = require(ReplicatedStorage.Util)
local ProgressBarFactory = require(ReplicatedStorage.Gui.ProgressBarFactory)
local DecalFactory = require(ReplicatedStorage.Gui.DecalFactory)
local ViewportFrameFactory = require(ReplicatedStorage.Gui.ViewportFrameFactory)
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
local ParticleEmitterFactory = require(ReplicatedStorage.Gui.ParticleEmitterFactory)
local Settings = require(ReplicatedStorage.Settings)
local SoundModule = require(ReplicatedStorage.SoundModule)

local consumerClass = require(ReplicatedStorage.Consumers.Consumer)

local TransformsFolder = ReplicatedStorage:WaitForChild("Transformers")
local TransformBeginEvent = TransformsFolder:WaitForChild("Events"):WaitForChild("TransformBegin")
local ShowOverheadBillboardEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowOverheadBillboard")
local UpdateOverheadBillboardEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateOverheadBillboard")
local ConsumerInputReceivedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ConsumerInputReceived")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local character = Player.Character or Player.CharacterAdded:wait()
local Humanoid = character:WaitForChild("Humanoid");


Promise.try(function()
  -- Update things in Workspace
  local baseplate = Workspace:WaitForChild("Baseplate", 8)
  if baseplate then
    baseplate.Color = Color3.fromRGB(80, 109, 84)
  end
end)

if Settings.IsJumpDisabled then
  -- Disable jumping
  Humanoid.Changed:Connect(function()
    Humanoid.Jump = false
  end)
end

-- Create place for SurfaceGuis
local surfaceGuiFolder = Instance.new("Folder", PlayerGui)
surfaceGuiFolder.Name = "SurfaceGuis"
surfaceGuiFolder.Parent = PlayerGui


local function getSurfaceGuiName(uid)
  local uid = uid or ""
  return "SurfaceGui_".. tostring(uid)
end

local function findSurfaceGui(uid)
  local uid = uid or ""
  for _, obj in pairs(surfaceGuiFolder:GetChildren()) do
    if obj.Name == getSurfaceGuiName(uid) then
      return obj
    end
  end
end

local function destroySurfaceGui(uid)
  local uid = uid or ""
  local gui = findSurfaceGui(uid)
  if gui then
    gui:Destroy()
  end
end


local REQUEST_INPUT_GUI_BILLBOARD_PART_NAME = "RequestInputGuiBillboardPart"
local REQUEST_INPUT_GUI_HEIGHT_ABOVE_PART = -1 -- Start lower since tweening up

-- Show a request above the consumer for some input product
local function showRequestInputGui(model, attachmentPart, productModel)
  --print("In showRequestInputGui")
  if model and attachmentPart and productModel then
    print("In showRequestInputGui; model=".. model.Name.. "; product=".. productModel.Name)
    local billboardPart = Util:GetChildWithName(attachmentPart, REQUEST_INPUT_GUI_BILLBOARD_PART_NAME)
    if not billboardPart then
      billboardPart = Util:CreateInstance("Part", {
        Name = REQUEST_INPUT_GUI_BILLBOARD_PART_NAME,
        Position = attachmentPart.Position + Vector3.new(0, REQUEST_INPUT_GUI_HEIGHT_ABOVE_PART, -2), -- Above and farther from camera
        Size = Vector3.new(3, 3, 0.001),
        Color = Color3.fromRGB(124, 225, 255),
        Anchored = true,
        CanCollide = false,
        CastShadow = false,
        Transparency = 0.0,
      }, nil)
      billboardPart.CFrame = billboardPart.CFrame * CFrame.Angles(math.rad(-35), math.rad(180), 0) -- Rotate front to face player and tilt,
    end

    -- Setup Viewport
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = getSurfaceGuiName(model:GetAttribute(consumerClass.UID_ATTRIBUTE_NAME))
    local viewport = ViewportFrameFactory.GetViewportFrame(productModel)
    viewport.Parent = surfaceGui
    surfaceGui.Adornee = billboardPart
    surfaceGui.Parent = surfaceGuiFolder
    billboardPart.Parent = attachmentPart

    SoundModule.PlayAssetIdStr(attachmentPart, consumerClass.INPUT_REQUEST_BEGIN_SOUND)
    local goalPosition = billboardPart.Position + Vector3.new(0, 1, 0)
    TweenGuiFactory.SpringUpPart(goalPosition, billboardPart)
  end
end
ShowOverheadBillboardEvent.OnClientEvent:Connect(showRequestInputGui)


local function createTransparentPart(partName, parentPart)
  local transparentPart = Util:CreateInstance("Part", {
      Name = partName,
      Anchored = true,
      CanCollide = false,
      CastShadow = false,
      Massless = true,
      Size = Vector3.new(0.1, 0.1, 0.1),
      Transparency = 1,
    }, nil)
  if parentPart then
    transparentPart.Position = parentPart.Position
    transparentPart.Parent = parentPart
  end
  return transparentPart
end

local REQUEST_GUI_PARTICLE_PART_NAME = "RequestGuiParticlePart"

-- Update an existing part, e.g. the customer input request guis
-- If no color is provided, then the gui will be destroyed
local function updateRequestInputGui(model, attachmentPart, color)
  if model and attachmentPart then
    local billboardPart = Util:GetChildWithName(attachmentPart, REQUEST_INPUT_GUI_BILLBOARD_PART_NAME)
    if billboardPart then
      -- Setup particles
      local emitter = nil
      local parentPart = Util:GetChildWithName(attachmentPart, REQUEST_GUI_PARTICLE_PART_NAME)
      if parentPart then
        emitter = Util:GetChildWithName(parentPart, "ParticleEmitter")
      else
        parentPart = createTransparentPart(REQUEST_GUI_PARTICLE_PART_NAME, attachmentPart)
        parentPart.Position = parentPart.Position + Vector3.new(0, REQUEST_INPUT_GUI_HEIGHT_ABOVE_PART, -2) -- Match billboard part created previously
        emitter = ParticleEmitterFactory.AttachFizzleEmitter(parentPart, false)
      end
      if not emitter then
        emitter = ParticleEmitterFactory.AttachFizzleEmitter(parentPart, false)
      end

      if color then
        billboardPart.Color = color
        TweenGuiFactory.BouncePart(billboardPart)
      else
        -- Remove the gui, e.g. time expired
        billboardPart:Destroy()
        SoundModule.PlayAssetIdStr(attachmentPart, consumerClass.INPUT_REQUEST_EXPIRED_SOUND)

        if emitter then
          emitter.Enabled = true
          Promise.delay(0.4):andThen(function()
            emitter.Enabled = false
          end)
        end

        -- Destroy in PlayerGui
        destroySurfaceGui(model:GetAttribute(consumerClass.UID_ATTRIBUTE_NAME))
      end
    end
  end
end
UpdateOverheadBillboardEvent.OnClientEvent:Connect(updateRequestInputGui)

-- This is triggered when a consumer receives its input
local function onConsumerInputReceived(model, isCorrectInput)
  --print("In onConsumerInputReceived")
  if model then
    local attachmentPart = consumerClass.GetRequestInputGuiAttachmentPart(model)
    if attachmentPart then
      local billboardPart = attachmentPart:FindFirstChild(REQUEST_INPUT_GUI_BILLBOARD_PART_NAME)
      if billboardPart then
        -- Destroy any existing gui in billboardPart
        for _, child in pairs(billboardPart:GetChildren()) do
          child:Destroy()
        end

        -- Show new image
        local image = DecalFactory.CONSUMER_RECEIVED_NIL_DECAL
        if isCorrectInput then
          image = DecalFactory.GetImage(DecalFactory.CONSUMER_RECEIVED_CORRECT_INPUT_DECAL)
          SoundModule.PlayAssetIdStr(attachmentPart, consumerClass.INPUT_REQUEST_RECEIVED_SOUND, 1)
        else
          image = DecalFactory.GetImage(DecalFactory.CONSUMER_RECEIVED_INCORRECT_INPUT_DECAL)
          SoundModule.PlayAssetIdStr(attachmentPart, consumerClass.INPUT_REQUEST_EXPIRED_SOUND, 1)
        end
        image.Parent = billboardPart
        billboardPart.Color = Color3.new(1, 1, 1)  -- Make it white
        TweenGuiFactory.BouncePart(billboardPart)

        Promise.delay(1):andThen(function()
          billboardPart:Destroy()
        end)
      end
    end

    -- Destroy in PlayerGui
    destroySurfaceGui(model:GetAttribute(consumerClass.UID_ATTRIBUTE_NAME))
  end
end
ConsumerInputReceivedEvent.OnClientEvent:Connect(onConsumerInputReceived)


local TRANSFORMER_BILLBOARD_PART_NAME = "TransformerBillboardPart"
local TRANSFORMER_PARTICLE_PART_NAME = "TransformerParticlePart"

local PROGRESS_BAR_HEIGHT_ABOVE_PART = 3

-- Show a progress bar above a transformer
local function showTransformInProgress(attachmentPart, durationSec)
  --print("In progress: ".. attachmentPart.Position.X.. ",".. attachmentPart.Position.Y.. ",".. attachmentPart.Position.Z.. "; ".. tostring(durationSec))
  -- Create progress bar above transformer
  local billboardGui = ProgressBarFactory.GetAutoProgressBar()
  if billboardGui then
    local billboardPart = Util:GetChildWithName(attachmentPart, TRANSFORMER_BILLBOARD_PART_NAME)
    if not billboardPart  then
      billboardPart = Util:CreateInstance("Part", {
          Name = TRANSFORMER_BILLBOARD_PART_NAME,
          Position = attachmentPart.Position + Vector3.new(0, PROGRESS_BAR_HEIGHT_ABOVE_PART, 0),
          Anchored = true,
          CanCollide = false,
          Transparency = 1.0,
        }, attachmentPart)
    end
    billboardGui.Adornee = billboardPart
    billboardGui.Parent = billboardPart

    -- Setup particles
    local emitter = nil
    local parentPart = Util:GetChildWithName(attachmentPart, TRANSFORMER_PARTICLE_PART_NAME)
    if parentPart then
      emitter = Util:GetChildWithName(parentPart, "ParticleEmitter")
    else
      parentPart = createTransparentPart(TRANSFORMER_PARTICLE_PART_NAME, attachmentPart)
      emitter = ParticleEmitterFactory.AttachSparkleEmitter(parentPart, false)
    end
    if not emitter then
      emitter = ParticleEmitterFactory.AttachSparkleEmitter(parentPart, false)
    end

    -- Tween bar
    ProgressBarFactory.TweenAutoProgressBar(billboardGui, durationSec)
    Promise.delay(durationSec):andThen(function()
      billboardPart:Destroy()

      -- Show particles
      if emitter then
        emitter.Enabled = true
        Promise.delay(0.5):andThen(function()
          emitter.Enabled = false
        end)
      end
    end)
  end
end
TransformBeginEvent.OnClientEvent:Connect(showTransformInProgress)

