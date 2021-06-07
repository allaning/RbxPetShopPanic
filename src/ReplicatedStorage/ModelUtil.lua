local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Avatars = require(ReplicatedStorage.Avatars)


local ModelUtil = {}


function ModelUtil.SetPrimaryPartAndColors(model)
  local partColor = model:GetAttribute(Avatars.TEMPLATE_COPY_COLOR_ATTR_NAME)
  if partColor then
    -- Calculate Darker color
    local currentHue = 0.0
    local currentSat = 0.0
    local currentVal = 0.0
    local currentHue, currentSat, currentVal = Color3.toHSV(partColor)
    currentVal = currentVal - 0.3
    local darkerColor = Color3.fromHSV(currentHue, currentSat, currentVal)

    for _, obj in pairs(model:GetDescendants()) do
      if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        if string.find(obj.Name, "PrimaryPart") then
          model.PrimaryPart = obj
        end
        if string.find(obj.Name, "ToColor") then
          obj.Color = partColor
        elseif string.find(obj.Name, "Darker") then
          obj.Color = darkerColor
        end
      end
    end
  end
end

return ModelUtil

