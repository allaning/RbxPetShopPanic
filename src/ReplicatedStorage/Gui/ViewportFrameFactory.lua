-- Creates ViewportFrames

local ViewportFrameFactory = {}


-- Create an instance of a class and set properties
local function createInstance(className, properties, parent)
  local instance = Instance.new(className)
  for i, v in pairs(properties) do
    instance[i] = v
  end
  if parent then
    instance.Parent = parent
  end
  return instance
end


function ViewportFrameFactory.GetViewportFrame(model)
  if model then
    local viewportFrame = Instance.new("ViewportFrame")
    viewportFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    viewportFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    viewportFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
    viewportFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    viewportFrame.BackgroundTransparency = 0.0
    viewportFrame.BorderSizePixel = 0

    local clone = model:Clone()
    local part = clone.PrimaryPart
    if part then
      clone:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 0, 0)))
      clone.Parent = viewportFrame

      local viewportCamera = Instance.new("Camera")
      viewportFrame.CurrentCamera = viewportCamera
      viewportCamera.Parent = viewportFrame
      viewportCamera.CFrame = CFrame.new(Vector3.new(0, 0.5, 1.9), part.Position)

      return viewportFrame
    end
  else
    error("Input model is nil; Unable to create ViewportFrame")
  end
end


return ViewportFrameFactory
