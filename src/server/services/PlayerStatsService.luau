--!strict

local Players = game:GetService("Players")

local UpgradeService = require(script.Parent.UpgradeService)

local PlayerStatsService = {}

local function createStat(parent: Instance, name: string, value: number): IntValue
	local stat = Instance.new("IntValue")
	stat.Name = name
	stat.Value = value
	stat.Parent = parent

	return stat
end

local function setupPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	createStat(leaderstats, "Money", 0)
	createStat(leaderstats, "XP", 0)
	createStat(leaderstats, "Citations", 0)
end

function PlayerStatsService.Start()
	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end

	Players.PlayerAdded:Connect(setupPlayer)
end

function PlayerStatsService.AwardCitation(player: Player, money: number, xp: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	local moneyStat = leaderstats:FindFirstChild("Money")
	local xpStat = leaderstats:FindFirstChild("XP")
	local citationsStat = leaderstats:FindFirstChild("Citations")

	if moneyStat and moneyStat:IsA("IntValue") then
		moneyStat.Value += UpgradeService.GetCitationMoney(player, money)
	end

	if xpStat and xpStat:IsA("IntValue") then
		xpStat.Value += xp
	end

	if citationsStat and citationsStat:IsA("IntValue") then
		citationsStat.Value += 1
	end
end

return PlayerStatsService
