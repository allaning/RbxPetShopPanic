local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)
local Util = require(ReplicatedStorage.Util)
local ProgressBarFactory = require(ReplicatedStorage.Gui.ProgressBarFactory)
local ViewportFrameFactory = require(ReplicatedStorage.Gui.ViewportFrameFactory)
local TweenGuiFactory = require(ReplicatedStorage.Gui.TweenGuiFactory)
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
  local baseplate = Workspace:WaitForChild("Baseplate")
  baseplate.Color = Color3.fromRGB(80, 109, 84)
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


local function getViewportSurfaceGuiName(consumerUid)
  return "ViewportSurfaceGui_".. tostring(consumerUid)
end

local REQUEST_INPUT_GUI_BILLBOARD_PART_NAME = "RequestInputGuiBillboardPart"
local REQUEST_INPUT_GUI_HEIGHT_ABOVE_PART = -1 -- Start lower since tweening up

-- Show a request above the consumer for some input product
local function showRequestInputGui(model, attachmentPart, productModel)
  --print("In showRequestInputGui")
  if model and attachmentPart and productModel then
    local billboardPart = Util:GetChildWithName(attachmentPart, REQUEST_INPUT_GUI_BILLBOARD_PART_NAME)
    if not billboardPart then
      billboardPart = Instance.new("Part")
      billboardPart.Name = REQUEST_INPUT_GUI_BILLBOARD_PART_NAME
      billboardPart.Position = attachmentPart.Position + Vector3.new(0, REQUEST_INPUT_GUI_HEIGHT_ABOVE_PART, -2) -- Above and farther from camera
      billboardPart.Size = Vector3.new(3, 3, 0.001)
      billboardPart.Color = Color3.fromRGB(124, 225, 255)
      billboardPart.CFrame = billboardPart.CFrame * CFrame.Angles(math.rad(-35), math.rad(180), 0) -- Rotate front to face player and tilt
      billboardPart.Anchored = true
      billboardPart.CanCollide = false
      billboardPart.CastShadow = false
      billboardPart.Transparency = 0.0
    end

    local surfaceGui = Instance.new("SurfaceGui")
    local modelUid = model:GetAttribute(consumerClass.UID_ATTRIBUTE_NAME) or ""
    surfaceGui.Name = getViewportSurfaceGuiName(modelUid)
    local viewport = ViewportFrameFactory.GetViewportFrame(productModel)
    viewport.Parent = surfaceGui
    surfaceGui.Adornee = billboardPart
    surfaceGui.Parent = surfaceGuiFolder
    billboardPart.Parent = attachmentPart

    SoundModule.PlayDrip(attachmentPart)
    local goalPosition = billboardPart.Position + Vector3.new(0, 1, 0)
    TweenGuiFactory.SpringUpPart(goalPosition , billboardPart)
  end
end
ShowOverheadBillboardEvent.OnClientEvent:Connect(showRequestInputGui)

-- Update an existing part
local function updateRequestInputGui(model, attachmentPart, color)
  if model and attachmentPart then
    local billboardPart = Util:GetChildWithName(attachmentPart, REQUEST_INPUT_GUI_BILLBOARD_PART_NAME)
    if billboardPart then
      if color then
        billboardPart.Color = color
        -- Bounce
        billboardPart.Position = billboardPart.Position + Vector3.new(0, -1, 0)
        local goalPosition = billboardPart.Position + Vector3.new(0, 1, 0)
        TweenGuiFactory.SpringUpPart(goalPosition , billboardPart)
      else
        billboardPart:Destroy()
        -- TODO: Fail
      end
    end
  end
end
UpdateOverheadBillboardEvent.OnClientEvent:Connect(updateRequestInputGui)

-- This is triggered when a consumer receives its input
local function onConsumerInputReceived(model)
  --print("In onConsumerInputReceived")
  if model then
    local attachmentPart = consumerClass.GetRequestInputGuiAttachmentPart(model)
    if attachmentPart then
      local billboardPart = attachmentPart:FindFirstChild(REQUEST_INPUT_GUI_BILLBOARD_PART_NAME)
      if billboardPart then
        SoundModule.PlaySquish(attachmentPart)
        billboardPart:Destroy()
      end
    end
  end
end
ConsumerInputReceivedEvent.OnClientEvent:Connect(onConsumerInputReceived)


local TRANSFORMER_BILLBOARD_PART_NAME = "TransformerBillboardPart"
local PROGRESS_BAR_HEIGHT_ABOVE_PART = 3

-- Show a progress bar above a transformer
local function showTransformInProgress(attachmentPart, durationSec)
  --print("In progress: ".. attachmentPart.Position.X.. ",".. attachmentPart.Position.Y.. ",".. attachmentPart.Position.Z.. "; ".. tostring(durationSec))
  -- Create progress bar above transformer
  local billboardGui = ProgressBarFactory.GetAutoProgressBar()
  if billboardGui then
    local billboardPart = Util:GetChildWithName(attachmentPart, TRANSFORMER_BILLBOARD_PART_NAME)
    if not billboardPart  then
      billboardPart = Instance.new("Part", attachmentPart)
      billboardPart.Name = TRANSFORMER_BILLBOARD_PART_NAME
      billboardPart.Position = attachmentPart.Position + Vector3.new(0, PROGRESS_BAR_HEIGHT_ABOVE_PART, 0)
      billboardPart.CFrame = billboardPart.CFrame * CFrame.Angles(0, math.rad(180), 0) -- Rotate front to face player
      billboardPart.Anchored = true
      billboardPart.CanCollide = false
      billboardPart.Transparency = 1.0
    end
    billboardGui.Adornee = billboardPart
    billboardGui.Parent = billboardPart

    -- Tween bar
    ProgressBarFactory.TweenAutoProgressBar(billboardGui, durationSec)
    Promise.delay(durationSec):andThen(function()
      billboardPart:Destroy()
    end)
  end
end
TransformBeginEvent.OnClientEvent:Connect(showTransformInProgress)

