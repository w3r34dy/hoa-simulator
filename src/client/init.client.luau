--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(shared:WaitForChild("GameConfig"))
local timeState = shared:WaitForChild("TimeState")
local dayValue = timeState:WaitForChild("Day") :: StringValue
local player = Players.LocalPlayer

print(("[Client] %s v%s initialized"):format(GameConfig.Name, GameConfig.Version))

require(script.devTests.UpgradeMenuTest).Start()

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = playerGui:WaitForChild("TimeofDay")
local dayBox = screenGui:WaitForChild("DayBox")
local dayText = dayBox:WaitForChild("TextLabel")

if not dayText:IsA("TextLabel") then
	error("[TimeofDay] Add a TextLabel named TextLabel under TimeofDay.DayBox.")
end

local function updateTimeHud()
	dayText.Text = dayValue.Value
end

dayValue.Changed:Connect(updateTimeHud)
updateTimeHud()
