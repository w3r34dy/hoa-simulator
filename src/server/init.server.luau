--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(shared:WaitForChild("GameConfig"))
local PlayerStatsService = require(script.services.PlayerStatsService)
local ViolationService = require(script.services.ViolationService)

print(("[Server] %s v%s initialized"):format(GameConfig.Name, GameConfig.Version))

PlayerStatsService.Start()
ViolationService.Start()
