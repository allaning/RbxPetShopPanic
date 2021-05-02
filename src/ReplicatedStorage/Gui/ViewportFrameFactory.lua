-- Creates ViewportFrames

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)


local ViewportFrameFactory = {}


-- Returns ViewportFrame containing image of model
function ViewportFrameFactory.GetViewportFrame(model)
  if model then
    local cameraPosition = model:GetAttribute("ViewportCameraPosition") or Vector3.new(0, 0.5, 1.9)
    local targetPositionOffset = model:GetAttribute("ViewportTargetPositionOffset") or Vector3.new(0, 0, 0)

    local viewportFrame = Instance.new("ViewportFrame")
    local viewportFrame = Util:CreateInstance("ViewportFrame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0.9, 0, 0.9, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.0,
        BorderSizePixel = 0,
      }, nil)

    local clone = model:Clone()
    local part = clone.PrimaryPart
    if part then
      clone:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 0, 0)))
      clone.Parent = viewportFrame

      local viewportCamera = Instance.new("Camera")
      viewportFrame.CurrentCamera = viewportCamera
      viewportCamera.Parent = viewportFrame
      viewportCamera.CFrame = CFrame.new(cameraPosition, part.Position + targetPositionOffset)

      return viewportFrame
    end
  else
    error("Input model is nil; Unable to create ViewportFrame")
  end
end


return ViewportFrameFactory
