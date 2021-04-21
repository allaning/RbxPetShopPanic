-- Creates rotating radial background image

-- TODO: This has not been used or tested yet; See Animal Rescue InitializePlayer onShowAnimalSplashScreenForPlayer()

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local RadialBackgroundFactory = {}

function RadialBackgroundFactory.GetRotatingRadialImage(degreesPerSecond, transparency)
  local degreesPerSecond = degreesPerSecond or 15
  local transparency = transparency or 0.5

  local radial = Instance.new("ImageLabel")
  radial.Image = "rbxassetid://6502649167"
  radial.AnchorPoint = Vector2.new(0.5, 0.5)
  radial.Position = UDim2.new(0.5, 0, 0.5, 0)
  radial.Size = UDim2.new(0.9, 0, 0.9, 0)
  radial.SizeConstraint = Enum.SizeConstraint.RelativeXX
  radial.BackgroundTransparency = 1
  radial.ImageTransparency = transparency
  --radial.ZIndex = 10
  radial.Visible = true
  --radial.Parent = image

  -- Rotate radial bg
  local function onRenderStep(deltaTime)
    local deltaRotation = deltaTime * degreesPerSecond
    radial.Rotation = radial.Rotation + deltaRotation
  end
  RunService.RenderStepped:Connect(onRenderStep)

  return radial
end

return RadialBackgroundFactory
