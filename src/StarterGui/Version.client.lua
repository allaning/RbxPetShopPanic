-- Show main lobby gui, e.g. avatar icon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
local Version = require(ReplicatedStorage.Version)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


local function showVersionNumber()
  local versionScreenGui = Util:CreateInstance("ScreenGui", {
      Name = "VersionScreenGui",
    }, PlayerGui)
  local versionTextLabel = Util:CreateInstance("TextLabel", {
      Name = "Version",
      Text = "Version ".. Version.VERSION_NUMBER,
      Font = Enum.Font.SourceSans,
      Position = UDim2.new(0.88, 0, 0.97, 0),
      Size = UDim2.new(0.12, 0, 0.03, 0),
      BackgroundTransparency = 1.0,
      TextColor3 = Color3.new(1, 1, 1),
      TextScaled = true,
      ZIndex = 10,
    }, versionScreenGui)
end

showVersionNumber()
print("SW Version: ".. Version.VERSION_NUMBER)

