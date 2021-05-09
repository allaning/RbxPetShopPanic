local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Vendor.Promise)
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")


-- Ref: https://developer.roblox.com/en-us/api-reference/function/Chat/SetBubbleChatSettings
local ChatService = game:GetService("Chat")
ChatService:SetBubbleChatSettings({
    --BackgroundColor3 = Color3.fromRGB(228, 210, 228),
    TextSize = 22,
    Font = Enum.Font.Cartoon,
    BubbleDuration = 5,
    VerticalStudsOffset = 0.5,
    BubblesSpacing = 4,
    Transparency = 0.2,
  })
ChatService.BubbleChatEnabled = true


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

