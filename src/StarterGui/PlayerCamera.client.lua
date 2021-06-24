-- Creates a top-down camera for each player. Should be used as a LocalScript
-- https://education.roblox.com/en-us/resources/arcade-game-top-down-camera

-- Get service needed for events used in this script
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Settings = require(ReplicatedStorage.Settings)

local ContextActionService = game:GetService("ContextActionService")

local Players = game:GetService("Players")


-- Variables for the camera and player
local camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer

local character = Player.Character or Player.CharacterAdded:wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Constant variable used to set the camera's offset from the player
local X_ANGLE = 0
local Y_HEIGHT_LIST = { 10, 20, 32 }
local Z_ANGLE_LIST = { 12, 16, 18 }

local currentIdx = 2  -- Start at medium height
local currentCameraOffset = Vector3.new(X_ANGLE, Y_HEIGHT_LIST[currentIdx], Z_ANGLE_LIST[currentIdx])

if Settings.IsFixedCameraAngle then
  -- Enables the camera to do what this script says
  camera.CameraType = Enum.CameraType.Scriptable

  -- Called every time the screen refreshes
  local function onRenderStep()
    -- Check if the player's character has spawned
    if character then
      local playerPosition = humanoidRootPart.Position
      currentCameraOffset = Vector3.new(X_ANGLE, Y_HEIGHT_LIST[currentIdx], Z_ANGLE_LIST[currentIdx])
      local cameraPosition = playerPosition + currentCameraOffset

      -- make the camera follow the player
      camera.CoordinateFrame = CFrame.new(cameraPosition, playerPosition)
    end
  end
  RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onRenderStep)
end


-- Setting up the action handling function
local function handleAction(actionName, inputState, inputObj)
  if inputState == Enum.UserInputState.Begin then
    if currentIdx == 3 then
      currentIdx = 1
    else
      currentIdx += 1
    end
  end
  -- Since this function does not return anything, this handler will
  -- "sink" the input and no other action handlers will be called after
  -- this one.
end


-- Bind the action to the handler

-- Ref: https://developer.roblox.com/en-us/api-reference/function/ContextActionService/BindAction
ContextActionService:BindAction("BoundAction", handleAction, false, Enum.KeyCode.Space)

-- Ref: https://devforum.roblox.com/t/bind-function-to-mobile-jump-button/767565
local touchGui = Player:WaitForChild("PlayerGui"):WaitForChild("TouchGui", 30)
if touchGui then
  local jumpButton = touchGui:WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
  local function startedToHold()
    handleAction(nil, Enum.UserInputState.Begin, nil)
  end
  jumpButton.MouseButton1Down:Connect(startedToHold)
end

