local Globals = {

  -- If true, then use real database (can use false for offline testing)
  ['USE_REAL_DATABASE'] = true,

  -- Datastore name
  ['DATA_STORE_NAME'] = "DATA00",  -- TODO Use real database

  -- Leaderboard stats names
  ['LEADERBOARD_POINTS_NAME'] = "Stars",

  -- Number of seconds to show random map level vote being selected
  ['RANDOM_LEVEL_SELECTION_DISPLAY_DELAY_SEC'] = 4,

  -- Number of seconds to show 'ready, set, go' countdown
  ['READY_SET_GO_COUNTDOWN_SEC'] = 4,

  -- Keep track of player status
  ['PLAYER_IS_IN_GAME_SESSION_ATTRIBUTE_NAME'] = "IsLocalPlayerInGameSession",

  -- Level name prefix (to go in front of number)
  ['LEVEL_NAME_PREFIX'] = "Level ",

  -- Uninitialized values
  ['UNINIT_STRING'] = "UNINITIALIZED",
  ['UNINIT_NUMBER'] = -1,

}

return Globals

