-- Creates a top-down camera for each player. Should be used as a LocalScript
-- https://education.roblox.com/en-us/resources/arcade-game-top-down-camera

-- Get service needed for events used in this script
--aing local Workspace = game:GetService("Workspace")
--aing local ReplicatedStorage = game:GetService("ReplicatedStorage")
--aing local RunService = game:GetService("RunService")
--aing local Settings = require(ReplicatedStorage.Settings)

--aing local ContextActionService = game:GetService("ContextActionService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
--aing local PlayerGui = Player:WaitForChild("PlayerGui")

-- 05/22/2022 Changing from fixed camera position to setting a max zoom distance
Player.CameraMaxZoomDistance = 28-- 32



-- Commented out the following code, which sets camera angle at fixed points

--aing -- Variables for the camera and player
--aing local camera = Workspace.CurrentCamera
--aing local Player = Players.LocalPlayer
--aing 
--aing local character = Player.Character or Player.CharacterAdded:wait()
--aing local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
--aing 
--aing -- Constant variable used to set the camera's offset from the player
--aing local X_ANGLE = 0
--aing local Y_HEIGHT_LIST = { 10, 20, 32 }
--aing local Z_ANGLE_LIST = { 12, 16, 18 }
--aing 
--aing local currentIdx = 2  -- Start at medium height
--aing local currentCameraOffset = Vector3.new(X_ANGLE, Y_HEIGHT_LIST[currentIdx], Z_ANGLE_LIST[currentIdx])
--aing 
--aing if Settings.IsFixedCameraAngle then
--aing   -- Enables the camera to do what this script says
--aing   camera.CameraType = Enum.CameraType.Scriptable
--aing 
--aing   -- Called every time the screen refreshes
--aing   local function onRenderStep()
--aing     -- Check if the player's character has spawned
--aing     if character then
--aing       local playerPosition = humanoidRootPart.Position
--aing       currentCameraOffset = Vector3.new(X_ANGLE, Y_HEIGHT_LIST[currentIdx], Z_ANGLE_LIST[currentIdx])
--aing       local cameraPosition = playerPosition + currentCameraOffset
--aing 
--aing       -- make the camera follow the player
--aing       camera.CoordinateFrame = CFrame.new(cameraPosition, playerPosition)
--aing     end
--aing   end
--aing   RunService:BindToRenderStep("Camera", Enum.RenderPriority.Camera.Value, onRenderStep)
--aing end


--aing -- Setting up the action handling function
--aing local function handleAction(actionName, inputState, inputObj)
--aing   if inputState == Enum.UserInputState.Begin then
--aing     if currentIdx == 3 then
--aing       currentIdx = 1
--aing     else
--aing       currentIdx += 1
--aing     end
--aing   end
--aing   -- Since this function does not return anything, this handler will
--aing   -- "sink" the input and no other action handlers will be called after
--aing   -- this one.
--aing end
--aing 
--aing 
--aing -- Bind the action to the handler
--aing 
--aing -- PC
--aing -- Ref: https://developer.roblox.com/en-us/api-reference/function/ContextActionService/BindAction
--aing ContextActionService:BindAction("BoundAction", handleAction, false, Enum.KeyCode.Space)
--aing 
--aing -- Mobile
--aing -- Ref: https://devforum.roblox.com/t/bind-function-to-mobile-jump-button/767565
--aing local touchGui = PlayerGui:WaitForChild("TouchGui", 8)
--aing if touchGui then
--aing   local touchControl = touchGui:WaitForChild("TouchControlFrame", 8)
--aing   if touchControl then
--aing     local jumpButton = touchControl:WaitForChild("JumpButton", 8)
--aing     if jumpButton then
--aing       local function startedToHold()
--aing         handleAction(nil, Enum.UserInputState.Begin, nil)
--aing       end
--aing       print("jumpButton.MouseButton1Down:Connect(startedToHold)")
--aing       jumpButton.MouseButton1Down:Connect(startedToHold)
--aing     end
--aing   end
--aing end

