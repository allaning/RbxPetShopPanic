local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Globals = require(ReplicatedStorage.Globals)
local Util = require(ReplicatedStorage.Util)

local ServerScriptService = game:GetService("ServerScriptService")
local MapVotingBeginBindableEvent = ServerScriptService.Bindable.MapVotingBeginBindable
local MapVotingTimeoutBindableEvent = ServerScriptService.Bindable.MapVotingTimeoutBindable
local MapVotingTimerCancelBindableEvent = ServerScriptService.Bindable.MapVotingTimerCancelBindable
local ShowNotificationEvent = ReplicatedStorage.Events.ShowNotification

local Players = game:GetService("Players")


local countdown = Globals.MAP_VOTING_TIMEOUT_SEC

-- True if currently voting
local isVoting = false


local function onMapVotingBeginBindableEvent()
  countdown = Globals.MAP_VOTING_TIMEOUT_SEC
  isVoting = true
end
MapVotingBeginBindableEvent.Event:Connect(onMapVotingBeginBindableEvent)

local function onMapVotingTimerCancelBindable()
  countdown = Globals.MAP_VOTING_TIMEOUT_SEC
  isVoting = false
end
MapVotingTimerCancelBindableEvent.Event:Connect(onMapVotingTimerCancelBindable)

Players.PlayerAdded:Connect(function(Player)
  countdown = Globals.MAP_VOTING_TIMEOUT_SEC
end)

Players.PlayerRemoving:Connect(function(Player)
  countdown = Globals.MAP_VOTING_TIMEOUT_SEC
end)


while true do
  Util:RealWait(1)
  if isVoting then
    countdown -= 1
    ShowNotificationEvent:FireAllClients("Voting Ends In\n".. tostring(countdown), 0.8)

    if countdown <= 0 then
      MapVotingTimeoutBindableEvent:Fire(nil, nil, true)

      countdown = Globals.MAP_VOTING_TIMEOUT_SEC
      isVoting = false
    end
  end
end

