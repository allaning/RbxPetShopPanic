local Util = {}

local BadgeService = game:GetService("BadgeService")
local RunService = game:GetService("RunService")

local StarterGui = game:GetService("StarterGui")
--local whiteScreenGui = StarterGui:WaitForChild("Generic"):WaitForChild("WhiteScreenGui")
--local blackScreenGui = StarterGui:WaitForChild("Generic"):WaitForChild("BlackScreenGui")

local MarketplaceService = game:GetService("MarketplaceService")


-- Accurate wait
-- https://devforum.roblox.com/t/avoiding-wait-and-why/244015/61
function Util:RealWait(seconds)
  local seconds = seconds or 0.003
  local total = 0
  repeat
    total = total + RunService.Heartbeat:Wait()
  until total >= seconds
end

-- Returns the size of specified list.
-- Note: Using the # operator to get table size is unreliable.
-- https://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
function Util:TableLength(T)
  local count = 0
  if T then
    for _ in pairs(T) do count = count + 1 end
  else
    count = -1
  end
  return count
end

function Util:GetTableStringSimple(T)
  local str = ""
  if T then
    local HttpService = game:GetService('HttpService')
    str = HttpService:JSONEncode(T)
  end
  return str
end

-- Returns status, index of item
function Util:Contains(tab, val)
  if Util:TableLength(tab) > 0 then
    for index, value in ipairs(tab) do
      if value == val then
        return true, index
      end
    end
  end
  return false, 0
end

-- Returns subset of table, like python slice
-- Ref: https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice
function Util:TableSlice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end

  return sliced
end

-- Returns status, index of item removed
function Util:RemoveFirstInstanceFromTable(tab, val)
  if Util:TableLength(tab) > 0 then
    for index = 1, Util:TableLength(tab) do
      if tab[index] == val then
        table.remove(tab, index)
        return true, index
      end
    end
  end
  return false, 0
end

function Util:ShallowTableCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function Util:DeepTableCopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[Util:DeepTableCopy(orig_key)] = Util:DeepTableCopy(orig_value)
    end
    setmetatable(copy, Util:DeepTableCopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end


-- Return true if every item in partialList is in fullList; false otherwise
function Util:IsSubsetOfList(partialList, fullList)
  for _, val in pairs(partialList) do
    local isFound = false
    for _, currentFullList in pairs(fullList) do
      if val == currentFullList then
        isFound = true
        break
      end
    end

    if not isFound then
      return false
    end
  end

  return true
end


-- Trim leading and trailing spaces
function Util:Trim(str)
  local result = string.gsub(str, '^%s+', '')
  result = string.gsub(result, '%s+$', '')
  return result
end


function Util:IsChild(parent, childName)
  for _, obj in pairs(parent:GetChildren()) do
    if obj.Name == childName then
      return true
    end
  end
  return false
end


function Util:GetChildWithName(parent, childName)
  for _, obj in pairs(parent:GetChildren()) do
    if obj.Name == childName then
      return obj
    end
  end
end


function Util:GetDescendantWithName(parent, childName)
  for _, obj in pairs(parent:GetDescendants()) do
    if obj.Name == childName then
      return obj
    end
  end
end


-- Create an instance of a class and set properties
function Util:CreateInstance(className, properties, parent)
  local instance = Instance.new(className)
  for i, v in pairs(properties) do
    instance[i] = v
  end
  if parent then
    instance.Parent = parent
  end
  return instance
end


-- Returns a comma separated string representing num, e.g. if num=123456789 then retruns "123,456,789"
function Util:ConvertComma(num)
  local x = tostring(num)
  if #x>=10 then
    local important = (#x-9)
    return x:sub(0,(important))..","..x:sub(important+1,important+3)..","..x:sub(important+4,important+6)..","..x:sub(important+7)
  elseif #x>= 7 then
    local important = (#x-6)
    return x:sub(0,(important))..","..x:sub(important+1,important+3)..","..x:sub(important+4)
  elseif #x>=4 then
    return x:sub(0,(#x-3))..","..x:sub((#x-3)+1)
  else
    return num
  end
end


-- Return true if floating point number are equivalent
-- Optional 3rd arg to specify precision
local EPSILON = 0.000001
function Util:AreFloatsEquivalent(arg1, arg2, epsilon)
  if not epsilon then
    epsilon = EPSILON
  end
  if arg1 and arg2 then
    if math.abs(arg1 - arg2) < epsilon then
      return true
    end
  end
  return false
end


function Util:IsPartNeon(part)
  if part then
    if part.Material == Enum.Material.Neon then
      return true
    end
  end
  return false
end


function Util:GetCharacterFromPlayer(player)
  return player.Character or player.CharacterAdded:wait()
end


-- Get player torso, R6 or R15
function Util:GetTorsoFromPlayer(player)
  local human = nil
  if player then
    local humanR15 = Util:GetCharacterFromPlayer(player):FindFirstChild("UpperTorso")
    if humanR15 then
      human = humanR15
    else
      local humanR6 = Util:GetCharacterFromPlayer(player):FindFirstChild("Torso")
      if humanR6 then
        human = humanR6
      end
    end
  end
  return human
end


function Util:GetRightHandFromPlayer(player)
  local hand = nil
  if player then
    hand = Util:GetCharacterFromPlayer(player):WaitForChild("RightHand", 2)
  end
  return hand
end


-- Fade out/in
-- Usage:
--	-- Fade out
--	local fadeScreenGui = util:FadeOutLight(player)
--	-- Fade in
--	if fadeScreenGui then
--		util:FadeIn(player, fadeScreenGui)
--	end

function Util:FadeOut(player, fadeScreenGui)
  if not player then return nil end

  if fadeScreenGui then
    local fadeFrame = fadeScreenGui:FindFirstChild("Frame")
    if fadeFrame then
      fadeScreenGui.Enabled = true
      fadeScreenGui.Frame.Visible = true
      local playerGui = player:FindFirstChild("PlayerGui")
      if playerGui then
        fadeScreenGui.Parent = playerGui

        for iTrans = 1, 0, -0.1 do
          fadeFrame.Transparency = iTrans
          RunService.Heartbeat:Wait(0.4)
        end

        RunService.Heartbeat:Wait(0.1)
      end
    end
    return fadeScreenGui
  end
end

function Util:FadeOutLight(player)
  if not player then return nil end

  local fadeScreenGui = whiteScreenGui:Clone()
  if fadeScreenGui then
    fadeScreenGui = Util:FadeOut(player, fadeScreenGui)
  end

  return fadeScreenGui
end

function Util:FadeOutDark(player)
  if not player then return nil end

  local fadeScreenGui = blackScreenGui:Clone()
  if fadeScreenGui then
    fadeScreenGui = Util:FadeOut(player, fadeScreenGui)
  end

  return fadeScreenGui
end

function Util:FadeIn(player, fadeScreenGui)
  if fadeScreenGui then
    RunService.Heartbeat:Wait(0.1)

    local fadeFrame = fadeScreenGui:FindFirstChild("Frame")
    for iTrans = 0, 1, 0.05 do
      fadeFrame.Transparency = iTrans
      RunService.Heartbeat:Wait(0.4)
    end

    fadeScreenGui:Destroy()
  end
end



function Util:MakeModelCanCollide(model, canCollide)
  for _, obj in ipairs(model:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
      obj.CanCollide = canCollide
    end
  end
end


function Util:MakeModelAnchored(model, anchored)
  for _, obj in ipairs(model:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
      obj.Anchored = anchored
    end
  end
end


function Weld(x, y, weldName)
  local weldName = weldName or "Weld"
  local W = Instance.new("Weld")
  W.Name = weldName
  W.Part0 = x
  W.Part1 = y
  local CJ = CFrame.new(x.Position)
  local C0 = x.CFrame:inverse()*CJ
  local C1 = y.CFrame:inverse()*CJ
  W.C0 = C0
  W.C1 = C1
  W.Parent = x
end
function Set(A, top, weldName)
  if A ~= top then
    if A.className == "BasePart" or A.className == "MeshPart" or A.className == "WedgePart" then
      Weld(top, A, weldName)
      A.Anchored = false
    else
      local C = A:GetChildren()
      for i=1, #C do
        Set(C[i], top, weldName)
      end
    end
  end
end

-- Weld a Model to a Part; The Weld instances will be under the Part
function Util:WeldModelToPart(aModel, aPart, weldName)
  Set(aModel, aPart, weldName)
end



-- Get price of developer product
function Util:GetProductPrice(productId)
  local price = -1
  local ProductInfo
  local success, err = pcall(function() ProductInfo = MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product) end)
  if success then
    if ProductInfo then
      price = ProductInfo.PriceInRobux
    end
  else
    warn("Error getting price for product ".. tostring(productId)..": ".. tostring(err))
  end
  return price
end



function Util:AwardBadge(playerId, badgeID)
  local hasBadge = false

  -- Check if the player already has the badge
  local success, message = pcall(function()
    hasBadge = BadgeService:UserHasBadgeAsync(playerId, badgeID)
  end)

  -- If there's an error, issue a warning and exit the function
  if not success then
    warn("Error while checking if player has badge: " .. tostring(message))
    return
  end

  if hasBadge == false and BadgeService:IsLegal(badgeID) and not BadgeService:IsDisabled(badgeID) then
    print("Badge awarded to playerId=".. playerId.. ", badgeID = ".. badgeID)
    BadgeService:AwardBadge(playerId, badgeID)
  end
end



-- BITWISE functions

function Util:IsBitSet(value, bitmask)
  return bit32.btest(value, bitmask)
end

-- Returns value with bit set based on a bitmask, not bit number
function Util:GetSetBit(value, bitmask)
  return bit32.bor(value, bitmask)
end

-- Returns value with bit cleared based on a bitmask, not bit number
-- Bit mask should be the bit to clear, e.g. to clear bit 2, pass 0x0002
function Util:GetClearedBit(value, bitmask)
  local inverseMask = bit32.bxor(bitmask, 0xFFFFFFFF)
  return bit32.band(value, inverseMask)
end



-- SERVER SIDE UTILITY FUNCTIONS

-- Get player torso, R6 or R15
function Util:ServerGetTorsoFromPlayer(player)
  local human = nil
  if player then
    local character = player.Character or player.CharacterAdded:wait()
    if character then
      local humanR15 = player.Character:FindFirstChild("UpperTorso")
      if humanR15 then
        human = humanR15
      else
        local humanR6 = player.Character:FindFirstChild("Torso")
        if humanR6 then
          human = humanR6
        end
      end
    end
  end

  return human
end

function Util:GetHumanoidRootPart(player)
  local character = player.Character or player.CharacterAdded:wait()
  return character:WaitForChild("HumanoidRootPart")
end

function Util:GetHumanoid(player)
  local character = player.Character or player.CharacterAdded:wait()
  local human = character:FindFirstChildOfClass("Humanoid")
  if human then
    return human
  end
end

function Util:ServerGetPlayerByName(playerName)
  local players = game:GetService("Players")
  for _, player in pairs(players:GetPlayers()) do
    if player.Name == playerName then
      return player
    end
  end
end

function Util:ServerGetPlayerByUserId(userId)
  local players = game:GetService("Players")
  for _, player in pairs(players:GetPlayers()) do
    if player.UserId == userId then
      return player
    end
  end
end


return Util
