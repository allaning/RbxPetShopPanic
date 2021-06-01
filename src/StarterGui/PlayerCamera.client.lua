-- Creates a top-down camera for each player. Should be used as a LocalScript
-- https://education.roblox.com/en-us/resources/arcade-game-top-down-camera

-- Get service needed for events used in this script
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Settings = require(ReplicatedStorage.Settings)


-- Variables for the camera and player
local camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer

local character = Player.Character or Player.CharacterAdded:wait()


if Settings.IsFixedCameraAngle then
  -- Constant variable used to set the camera's offset from the player
  local X_ANGLE = 0
  local Y_HEIGHT = 20
  local Z_ANGLE = 16
  local CAMERA_OFFSET = Vector3.new(X_ANGLE, Y_HEIGHT, Z_ANGLE)

  -- Enables the camera to do what this script says
  camera.CameraType = Enum.CameraType.Scriptable

  -- Called every time the screen refreshes
  local function onRenderStep()
    -- Check if the player's character has spawned
    if character then
      local playerPosition = character.HumanoidRootPart.Position
      local cameraPosition = playerPosition + CAMERA_OFFSET

      -- make the camera follow the player
      camera.CoordinateFrame = CFrame.new(cameraPosition, playerPosition)
    end
  end
  RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onRenderStep)
end

