-- Allow players to scroll leaderboard when not at max zoom

local Workspace = game:GetService("Workspace")
local leaderboardWorkspaceFolder = Workspace:WaitForChild("Lobby"):WaitForChild("Leaderboard")
local board = leaderboardWorkspaceFolder:WaitForChild("LeaderboardStars"):WaitForChild("Board")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local sg = board:WaitForChild("SurfaceGui")
sg.Name = "LeaderboardSurfaceGui"
sg.Adornee = board
sg.Parent = PlayerGui
sg.AlwaysOnTop = true

