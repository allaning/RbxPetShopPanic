local Globals = {

  -- If true, then use real database (can use false for offline testing)
  ['USE_REAL_DATABASE'] = true,

  -- Place ID for real game
  ['MAIN_PLACE_ID'] = 5528357894,  -- TODO Update

  -- Datastore name
  ['DATA_STORE_NAME'] = "DATA00",  -- TODO Use real database

  -- Number of seconds to show loading screen
  ['LOADING_SCREEN_LENGTH'] = 6,

  -- Leaderboard DataStore name
  ['LEADERBOARD_DATASTORE_NAME'] = "LeaderboardStars",

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

  -- Map Attribute name for setting map level
  ['MAP_LEVEL_ATTRIBUTE_NAME'] = "Level",

  -- Map Attribute name for minimum points required for player to select map
  ['POINTS_REQUIRED_ATTRIBUTE_NAME'] = "PointsRequired",


  -- Uninitialized values
  ['UNINIT_STRING'] = "UNINITIALIZED",
  ['UNINIT_NUMBER'] = -1,

}

return Globals

