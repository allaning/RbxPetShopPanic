local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TransformsFolder = ReplicatedStorage:WaitForChild("Transformers")
local TransformBeginEvent = TransformsFolder:WaitForChild("Events"):WaitForChild("TransformBegin")
local ProgressBarFactory = require(ReplicatedStorage.Gui.ProgressBarFactory)
local Promise = require(ReplicatedStorage.Vendor.Promise)

--local Players = game:GetService("Players")
--local Player = Players.LocalPlayer
--local PlayerGui = Player:WaitForChild("PlayerGui")


local function showTransformInProgress(subjectPosition, durationSec)
  --print("In progress: ".. subjectPosition.X.. ",".. subjectPosition.Y.. ",".. subjectPosition.Z.. "; ".. tostring(durationSec))
  -- Create progress bar above transformer
  local billboardGui = ProgressBarFactory.GetAutoProgressBar()
  local billboardPart = Instance.new("Part", Workspace)
  billboardPart.Name = "TransformerBillboardPart"
  billboardPart.Position = subjectPosition + Vector3.new(-1, 3, 0)
  billboardPart.CFrame = billboardPart.CFrame * CFrame.Angles(0, math.rad(180), 0) -- Rotate front to face player
  billboardPart.Anchored = true
  billboardPart.CanCollide = false
  billboardPart.Transparency = 1.0
  billboardGui.Adornee = billboardPart
  billboardGui.Parent = billboardPart

  -- Tween bar
  ProgressBarFactory.TweenAutoProgressBar(billboardGui, durationSec)
  Promise.delay(durationSec):andThen(function()
    billboardPart:Destroy()
  end)
end
TransformBeginEvent.OnClientEvent:Connect(showTransformInProgress)

