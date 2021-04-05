local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local wsFactoriesFolder = Workspace:WaitForChild("Factories")
local serverFactoriesFolder = ServerStorage:WaitForChild("Factories")

-- Iterate over the factories
for _, obj in pairs(serverFactoriesFolder:GetChildren()) do
  local partCount = #obj:GetChildren()
  print("Found ".. obj.Name.. "; parts=".. tostring(partCount))

  -- TODO: Determine which ones to spawn and where
  local clone = obj:Clone()
  clone.Parent = wsFactoriesFolder
end
