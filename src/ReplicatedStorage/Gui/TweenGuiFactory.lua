-- Creates gui tween effects
-- Using Flipper: https://github.com/Reselim/Flipper

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flipper = require(ReplicatedStorage.Vendor.Flipper)


local TweenGuiFactory = {}

-- Tween Parts

local springProps = {
  frequency = 3.5,
  dampingRatio = 0.3, -- The lower the number, the more bounce before settling
}

function TweenGuiFactory.SpringUpPart(goalPosition, tweenPart)
  local motor = Flipper.GroupMotor.new({
    X = tweenPart.Position.X,
    Y = tweenPart.Position.Y,
    Z = tweenPart.Position.Z,
  })
  motor:onStep(function(values)
    tweenPart.Position = Vector3.new(values.X, values.Y, values.Z)
  end)
  motor:onComplete(function()
    --print("Motor completed")
  end)
  motor:setGoal({
    X = Flipper.Spring.new(goalPosition.X, springProps),
    Y = Flipper.Spring.new(goalPosition.Y, springProps),
    Z = Flipper.Spring.new(goalPosition.Z, springProps),
  })
end

function TweenGuiFactory.BouncePart(tweenPart)
  local goalPosition = tweenPart.Position
  tweenPart.Position = tweenPart.Position + Vector3.new(0, -1, 0)
  TweenGuiFactory.SpringUpPart(goalPosition, tweenPart)
end


-- Tween Frame

local frameSpringProps = {
  frequency = 8.0,
  dampingRatio = 0.3, -- The lower the number, the more bounce before settling
}

function TweenGuiFactory.SpringUpFrame(tweenFrame)
  local motor = Flipper.GroupMotor.new({
    X = tweenFrame.Position.X.Scale,
    Y = tweenFrame.Position.Y.Scale,
  })
  motor:onStep(function(values)
    tweenFrame.Position = UDim2.new(values.X, 0, values.Y, 0)
  end)
  motor:onComplete(function()
    --print("Motor completed")
  end)
  motor:setGoal({
    X = Flipper.Spring.new(tweenFrame.Position.X.Scale, frameSpringProps),
    Y = Flipper.Spring.new(tweenFrame.Position.Y.Scale - 0.02, frameSpringProps),
  })
end


-- Tween UIScale

function TweenGuiFactory.ScaleIn(uiScale, duration, style, direction, isBlocking)
  style = style or Enum.EasingStyle.Quad
  direction = direction or Enum.EasingDirection.Out
  duration = duration or 0.5

  local propertyGoals = {}
  propertyGoals["Scale"] = 1.0

  local tweenInfo = TweenInfo.new(duration, style, direction)
  local tween = game:GetService("TweenService"):Create(uiScale,tweenInfo,propertyGoals)
  tween:Play()
  if isBlocking then
    tween.Completed:wait()
  end
  return tween
end

function TweenGuiFactory.ScaleOut(uiScale, duration, style, direction, isBlocking)
  style = style or Enum.EasingStyle.Quad
  direction = direction or Enum.EasingDirection.Out
  duration = duration or 0.5

  local propertyGoals = {}
  propertyGoals["Scale"] = 0.0

  local tweenInfo = TweenInfo.new(duration, style, direction)
  local tween = game:GetService("TweenService"):Create(uiScale,tweenInfo,propertyGoals)
  tween:Play()
  if isBlocking then
    tween.Completed:wait()
  end
  return tween
end

return TweenGuiFactory
