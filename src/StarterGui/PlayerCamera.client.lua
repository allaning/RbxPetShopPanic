--Creates a top-down camera for each player. Should be used as a     LocalScript
-- https://education.roblox.com/en-us/resources/arcade-game-top-down-camera

--Get service needed for events used in this script
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables for the camera and player
local camera = Workspace.CurrentCamera
local player = Players.LocalPlayer

-- Constant variable used to set the camera's offset from the player
local X_ANGLE = -22
local Y_HEIGHT = 24
local CAMERA_OFFSET = Vector3.new(X_ANGLE, Y_HEIGHT, 0)

-- Enables the camera to do what this script says
camera.CameraType = Enum.CameraType.Scriptable

local character = player.Character or player.CharacterAdded:wait()
local Humanoid = character:WaitForChild("Humanoid");


-- Disable jumping
Humanoid.Changed:Connect(function()
	Humanoid.Jump = false
end)


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

