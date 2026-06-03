--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(shared:WaitForChild("GameConfig"))
local PlayerStatsService = require(script.services.PlayerStatsService)
local TimeService = require(script.services.TimeService)
local UpgradeService = require(script.services.UpgradeService)
local ViolationService = require(script.services.ViolationService)

print(("[Server] %s v%s initialized"):format(GameConfig.Name, GameConfig.Version))

PlayerStatsService.Start()
UpgradeService.Start()
TimeService.Start()
ViolationService.Start()
