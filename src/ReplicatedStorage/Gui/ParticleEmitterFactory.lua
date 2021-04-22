-- Creates particle emitters

local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ParticleEmitterFactory = {}

function ParticleEmitterFactory.AttachSparkleEmitter(parentPart, isEnabled)
  local emitter = Instance.new("ParticleEmitter")
  emitter.Texture = "http://www.roblox.com/asset/?id=241685484"  -- Confetti
  emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.05)})
  emitter.Rate = 99 -- Particles per second
  emitter.Lifetime = NumberRange.new(0.4, 0.4)
  emitter.EmissionDirection = Enum.NormalId.Top
  emitter.Speed = NumberRange.new(8, 8)
  emitter.Drag = 0 -- Apply no drag to particle motion
  emitter.Acceleration = Vector3.new(0, -7, 0)
  emitter.SpreadAngle = Vector2.new(90, 90)

  emitter.Rotation = NumberRange.new(0, 360) -- Start at random rotation
  emitter.RotSpeed = NumberRange.new(0) -- Do not rotate

  local numberKeypoints = {
    -- API: NumberSequenceKeypoint.new(time, size, envelop)
    NumberSequenceKeypoint.new( 0, 1);    -- At t=0, fully transparent
    NumberSequenceKeypoint.new(.1, 0);    -- At t=.1, fully opaque
    NumberSequenceKeypoint.new(.5, .25);  -- At t=.5, mostly opaque
    NumberSequenceKeypoint.new( 1, .7);    -- At t=1, fully transparent
  }
  emitter.Transparency = NumberSequence.new(numberKeypoints)

  emitter.LightEmission = 1 -- When particles overlap, multiply their color to be brighter
  emitter.LightInfluence = 0 -- Don't be affected by world lighting
  emitter.LockedToPart = true
  emitter.Enabled = isEnabled
  emitter.Parent = parentPart

  return emitter
end

function ParticleEmitterFactory.AttachFizzleEmitter(parentPart, isEnabled)
  local emitter = Instance.new("ParticleEmitter")
  emitter.Texture = "http://www.roblox.com/asset/?id=241685484"  -- Confetti
  emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 0.02)})
  emitter.Rate = 50 -- Particles per second
  emitter.Lifetime = NumberRange.new(0.8, 0.8)
  emitter.EmissionDirection = Enum.NormalId.Top
  emitter.Speed = NumberRange.new(8, 8)
  emitter.Drag = 20 -- Apply no drag to particle motion
  emitter.Acceleration = Vector3.new(10, 25, 10)
  emitter.SpreadAngle = Vector2.new(90, 90)

  emitter.Rotation = NumberRange.new(0, 360) -- Start at random rotation
  emitter.RotSpeed = NumberRange.new(60)

  -- For Color, build a ColorSequence using ColorSequenceKeypoint
  local colorKeypoints = {
    -- API: ColorSequenceKeypoint.new(time, color)
    ColorSequenceKeypoint.new( 0, Color3.new(0, 0, 0)),
    ColorSequenceKeypoint.new( 1, Color3.new(0, 0, 0))
  }
  emitter.Color = ColorSequence.new(colorKeypoints)

  local numberKeypoints = {
    -- API: NumberSequenceKeypoint.new(time, size, envelop)
    NumberSequenceKeypoint.new( 0, 1);    -- At t=0, fully transparent
    NumberSequenceKeypoint.new(.1, 0);    -- At t=.1, fully opaque
    NumberSequenceKeypoint.new(.5, .25);  -- At t=.5, mostly opaque
    NumberSequenceKeypoint.new( 1, .9);
  }
  emitter.Transparency = NumberSequence.new(numberKeypoints)

  emitter.LightEmission = 0 -- When particles overlap, multiply their color to be brighter
  emitter.LightInfluence = 0 -- Don't be affected by world lighting
  emitter.LockedToPart = true
  emitter.Enabled = isEnabled
  emitter.Parent = parentPart

  return emitter
end

return ParticleEmitterFactory
