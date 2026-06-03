--!strict

local Players = game:GetService("Players")

local serverScript = script:FindFirstAncestor("Server")
assert(serverScript, "UpgradeSystemSmokeTest must run under ServerScriptService.Server.")

local services = serverScript:WaitForChild("services")
local PlayerStatsService = require(services:WaitForChild("PlayerStatsService"))
local UpgradeService = require(services:WaitForChild("UpgradeService"))

local TEST_MONEY = 10000
local TEST_CITATION_REWARD = 100

local CAMERA_UPGRADES = {
	"SimpleCamera",
	"ModernCamera",
	"SuperiorCamera",
	"AdelphiCamera",
	"Ultra3DCamera",
}

local MOTOR_LEG_UPGRADES = {
	"AssistLegs",
	"PatrolLegs",
	"CodeEnforcerLegs",
	"BoardApprovedLegs",
	"TurboBylawLegs",
}

local UpgradeSystemSmokeTest = {}

local function getMoneyStat(player: Player): IntValue
	local leaderstats = player:WaitForChild("leaderstats")
	local money = leaderstats:WaitForChild("Money")

	assert(money:IsA("IntValue"), "leaderstats.Money must be an IntValue.")

	return money
end

local function getTargetPlayer(player: Player?): Player
	if player then
		return player
	end

	local firstPlayer = Players:GetPlayers()[1]
	assert(firstPlayer, "Start Play mode with at least one player before running this test.")

	return firstPlayer
end

local function purchaseAll(player: Player, upgradeIds: { string }, report: { string })
	for _, upgradeId in upgradeIds do
		local success, message = UpgradeService.PurchaseUpgrade(player, upgradeId)
		table.insert(report, ("%s: %s (%s)"):format(upgradeId, if success then "PASS" else "FAIL", message))
	end
end

function UpgradeSystemSmokeTest.Run(player: Player?): { string }
	local targetPlayer = getTargetPlayer(player)
	local money = getMoneyStat(targetPlayer)
	local report = {}

	money.Value = TEST_MONEY
	table.insert(report, ("Starting money set to %d."):format(TEST_MONEY))

	purchaseAll(targetPlayer, CAMERA_UPGRADES, report)
	table.insert(report, ("CameraTier = %s"):format(tostring(targetPlayer:GetAttribute("CameraTier"))))

	purchaseAll(targetPlayer, MOTOR_LEG_UPGRADES, report)
	table.insert(report, ("MotorLegsTier = %s"):format(tostring(targetPlayer:GetAttribute("MotorLegsTier"))))

	local moneyBeforeCitation = money.Value
	PlayerStatsService.AwardCitation(targetPlayer, TEST_CITATION_REWARD, 0)
	table.insert(
		report,
		("Citation payout test: %d -> %d from base reward %d."):format(
			moneyBeforeCitation,
			money.Value,
			TEST_CITATION_REWARD
		)
	)

	local character = targetPlayer.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	table.insert(report, ("WalkSpeed = %s"):format(if humanoid then tostring(humanoid.WalkSpeed) else "No character"))

	for _, line in report do
		print("[UpgradeSystemSmokeTest] " .. line)
	end

	return report
end

return UpgradeSystemSmokeTest
