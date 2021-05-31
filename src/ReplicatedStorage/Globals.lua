local Globals = {

  -- If true, then use real database (can use false for offline testing)
  ['USE_REAL_DATABASE'] = true,

  -- Datastore name
  ['DATA_STORE_NAME'] = "DATA00",  -- TODO Use real database

  -- Leaderboard stats names
  ['LEADERBOARD_POINTS_NAME'] = "Stars",

  -- Cost for avatar in points (see StarterGui/AvatarGui.lua)
  ['AVATAR_COST_POINTS_ATTR_NAME'] = "CostPoints",

  -- Cost for avatar in Robux (see StarterGui/AvatarGui.lua)
  ['AVATAR_COST_ROBUX_ATTR_NAME'] = "CostRobux",

  -- Number of seconds to show random map level vote being selected
  ['RANDOM_LEVEL_SELECTION_DISPLAY_DELAY_SEC'] = 4,

  -- Number of seconds to show 'ready, set, go' countdown
  ['READY_SET_GO_COUNTDOWN_SEC'] = 4,

  -- Keep track of player status
  ['PLAYER_IS_IN_GAME_SESSION_ATTRIBUTE_NAME'] = "IsLocalPlayerInGameSession",

  ['UNINIT_STRING'] = "UNINITIALIZED",
  ['UNINIT_NUMBER'] = -1,
}

return Globals

