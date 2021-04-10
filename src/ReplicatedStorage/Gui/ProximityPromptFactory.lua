-- Creates ProximityPrompts
-- https://developer.roblox.com/en-us/articles/proximity-prompts
-- Customization: https://devforum.roblox.com/t/proximity-prompt-studio-beta/844107

local ProximityPromptFactory = {}

function ProximityPromptFactory.SetHotkey(prompt, hotkey)
  prompt.KeyboardKeyCode = hotkey
end

function ProximityPromptFactory.SetMaxDistance(prompt, distance)
  prompt.MaxActivationDistance = distance
end

function ProximityPromptFactory.GetDefaultProximityPrompt(objectText, actionText)
  local prompt = Instance.new("ProximityPrompt")
  prompt.Name = objectText
  prompt.ObjectText = objectText
  prompt.ActionText = actionText
  return prompt
end

return ProximityPromptFactory
