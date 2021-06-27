local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage.Util)
local Globals = require(ReplicatedStorage.Globals)
local Assets = require(ReplicatedStorage.Assets)
local TweenService = game:GetService("TweenService")

local UpdateCharacterEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UpdateCharacter")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Character = Util:GetCharacterFromPlayer(Player)
local Humanoid = Character:WaitForChild("Humanoid");


-- Ref: https://developer.roblox.com/en-us/api-reference/function/Chat/SetBubbleChatSettings
local ChatService = game:GetService("Chat")
ChatService:SetBubbleChatSettings({
    --BackgroundColor3 = Color3.fromRGB(228, 210, 228),
    TextSize = 22,
    Font = Enum.Font.Cartoon,
    BubbleDuration = 5,
    VerticalStudsOffset = 0.5,
    BubblesSpacing = 4,
    Transparency = 0.0,
  })
ChatService.BubbleChatEnabled = true


-- Morph
-- https://devforum.roblox.com/t/character-morph-script/1199389
local function updateCharacter(hipHeight)
  Promise.try(function()
    for i=1,120 do
      Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
      RunService.Heartbeat:wait()
    end
  end)
end
UpdateCharacterEvent.OnClientEvent:Connect(updateCharacter)


-- Loading screen
-- Ref: https://devforum.roblox.com/t/create-a-fade-in-logo-for-a-loading-screen/406287/1
-- Only do this for the real game
if game.PlaceId == Globals.MAIN_PLACE_ID then
  local loadingScreenGui = Util:CreateInstance("ScreenGui", {
      Name = "LoadingScreenGui",
    }, PlayerGui)
  local loadingScreenFrame = Util:CreateInstance("Frame", {
      Name = "LoadingScreenFrame",
      Position = UDim2.new(0.0, 0, -0.05, 0),
      Size = UDim2.new(1.0, 0, 1.05, 0),
      BackgroundColor3 = Color3.fromRGB(50, 50, 50),
      BackgroundTransparency = 0.0,
    }, loadingScreenGui)
  local logoImage = Util:CreateInstance("ImageLabel", {
      Name = "LogoImage",
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.new(0.5, 0, 0.5, 0),
      Size = UDim2.new(0.42, 0, 0.42, 0),
      SizeConstraint = Enum.SizeConstraint.RelativeYY,
      Image = Assets.LOGO_700x700_8BIT,
      BackgroundTransparency = 1.0,
    }, loadingScreenFrame)
  local uiGradient = Util:CreateInstance("UIGradient", {
      Rotation = -90,
    }, logoImage)

  uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), -- REQUIRED PT @ 0
    ColorSequenceKeypoint.new(0.005, Color3.fromRGB(43, 43, 43)), -- REQUIRED PT @ 0
    ColorSequenceKeypoint.new(1, Color3.fromRGB(96, 96, 96)), -- REQUIRED PT @ 1
  })

  local tweenInfo = TweenInfo.new(Globals.LOADING_SCREEN_LENGTH, Enum.EasingStyle.Linear)
  Util:RealWait(2) -- so the player can spawn in

  local info = {}
  info.Offset = Vector2.new(0, -1) -- creates the tween target, you will have to mess with this if you use different angles (this is from the bottom, -90)

  local tween = TweenService:Create(uiGradient, tweenInfo, info)
  tween:Play()

  Util:RealWait(Globals.LOADING_SCREEN_LENGTH + 1) -- waits for tween to finish + optional delay

  loadingScreenGui:Destroy()
end


local coreCall do
  local MAX_RETRIES = 8
  function coreCall(method, ...)
    local result = {}
    for retries = 1, MAX_RETRIES do
      result = {pcall(StarterGui[method], StarterGui, ...)}
      if result[1] then
        break
      end
      RunService.Stepped:Wait()
    end
    return unpack(result)
  end
end
-- Disable Reset button
coreCall('SetCore', 'ResetButtonCallback', false)

