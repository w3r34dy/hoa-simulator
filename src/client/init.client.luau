--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(shared:WaitForChild("GameConfig"))
local timeState = shared:WaitForChild("TimeState")
local dayValue = timeState:WaitForChild("Day") :: StringValue
local player = Players.LocalPlayer

print(("[Client] %s v%s initialized"):format(GameConfig.Name, GameConfig.Version))

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = playerGui:WaitForChild("HOATimeHud")
local dayText = screenGui:FindFirstChild("DayLabel", true)

if not dayText then
	dayText = screenGui:FindFirstChild("DayText", true) or screenGui:FindFirstChild("DayTextBox", true)
end

if not dayText or not (dayText:IsA("TextLabel") or dayText:IsA("TextBox")) then
	error("[HOATimeHud] Add a TextLabel or TextBox named DayLabel under HOATimeHud.")
end

local function updateTimeHud()
	(dayText :: any).Text = dayValue.Value
end

dayValue.Changed:Connect(updateTimeHud)
updateTimeHud()
