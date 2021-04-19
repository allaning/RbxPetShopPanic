-- Creates gui tween effects
-- Using Flipper: https://github.com/Reselim/Flipper

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Flipper = require(ReplicatedStorage.Vendor.Flipper)


local TweenGuiFactory = {}

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

return TweenGuiFactory
