--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(shared:WaitForChild("GameConfig"))

print(("[Client] %s v%s initialized"):format(GameConfig.Name, GameConfig.Version))
