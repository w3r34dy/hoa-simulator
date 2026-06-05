--!strict

local Players = game:GetService("Players")

local serverScript = script:FindFirstAncestor("Server")
assert(serverScript, "UpgradeSystemSmokeTest must run under ServerScriptService.Server.")

local services = serverScript:WaitForChild("services")
local PlayerStatsService = require(services:WaitForChild("PlayerStatsService"))
local UpgradeService = require(services:WaitForChild("UpgradeService"))

local TEST_MONEY = 50000
local TEST_XP = 50000
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

local BOARD_FAVOR_UPGRADES = {
	"LuckyPen",
	"CarbonCopyForms",
	"PriorityFiling",
	"BoardFavor",
	"GoldenClipboard",
}

local CITATION_GOGGLES_UPGRADES = {
	"BudgetGoggles",
	"PolarizedGoggles",
	"BylawGoggles",
	"InspectorGoggles",
	"CitationGoggles",
}

local EAGLE_EYES_UPGRADES = {
	"SharpEyes",
	"LongView",
	"MapScanner",
	"PatrolVision",
	"EagleEyes",
}

local REPUTATION_BADGE_UPGRADES = {
	"VisitorBadge",
	"ResidentBadge",
	"CommitteeBadge",
	"BoardMemberBadge",
	"ReputationBadge",
}

local POLICY_HANDBOOK_UPGRADES = {
	"PolicyHandbookI",
	"PolicyHandbookII",
	"PolicyHandbookIII",
	"PolicyHandbookIV",
	"PolicyHandbookV",
}

local NEGOTIATOR_UPGRADES = {
	"PersuasionNotes",
	"CounterofferScript",
	"HearingPrep",
	"SettlementTactics",
	"Negotiator",
}

local ECONOMIST_UPGRADES = {
	"CouponLedger",
	"ReserveFund",
	"BudgetReview",
	"CompoundDues",
	"Economist",
}

local GAMBLER_UPGRADES = {
	"LooseOdds",
	"SideBet",
	"RiskForm",
	"LongShotLedger",
	"Gambler",
}

local GOLDEN_FAVOR_UPGRADES = {
	"BronzeFavor",
	"SilverFavor",
	"PlatinumFavor",
	"DiamondFavor",
	"GoldenFavor",
}

local SIGHT_SEEING_UPGRADES = {
	"CurbCheck",
	"BinocularBasics",
	"StreetSurvey",
	"PorchView",
	"SightSeeing",
}

local UpgradeSystemSmokeTest = {}

local function getMoneyStat(player: Player): IntValue
	local leaderstats = player:WaitForChild("leaderstats")
	local money = leaderstats:WaitForChild("Money")

	assert(money:IsA("IntValue"), "leaderstats.Money must be an IntValue.")

	return money
end

local function getXPStat(player: Player): IntValue
	local leaderstats = player:WaitForChild("leaderstats")
	local xp = leaderstats:WaitForChild("XP")

	assert(xp:IsA("IntValue"), "leaderstats.XP must be an IntValue.")

	return xp
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
	local xp = getXPStat(targetPlayer)
	local report = {}

	money.Value = TEST_MONEY
	xp.Value = TEST_XP
	table.insert(report, ("Starting money set to %d."):format(TEST_MONEY))
	table.insert(report, ("Starting XP set to %d."):format(TEST_XP))

	purchaseAll(targetPlayer, CAMERA_UPGRADES, report)
	table.insert(report, ("CameraTier = %s"):format(tostring(targetPlayer:GetAttribute("CameraTier"))))

	purchaseAll(targetPlayer, MOTOR_LEG_UPGRADES, report)
	table.insert(report, ("MotorLegsTier = %s"):format(tostring(targetPlayer:GetAttribute("MotorLegsTier"))))

	purchaseAll(targetPlayer, BOARD_FAVOR_UPGRADES, report)
	table.insert(report, ("BoardFavorTier = %s"):format(tostring(targetPlayer:GetAttribute("BoardFavorTier"))))

	purchaseAll(targetPlayer, CITATION_GOGGLES_UPGRADES, report)
	table.insert(report, ("CitationGogglesTier = %s"):format(tostring(targetPlayer:GetAttribute("CitationGogglesTier"))))

	purchaseAll(targetPlayer, EAGLE_EYES_UPGRADES, report)
	table.insert(report, ("EagleEyesTier = %s"):format(tostring(targetPlayer:GetAttribute("EagleEyesTier"))))

	purchaseAll(targetPlayer, REPUTATION_BADGE_UPGRADES, report)
	table.insert(report, ("ReputationBadgeTier = %s"):format(tostring(targetPlayer:GetAttribute("ReputationBadgeTier"))))

	purchaseAll(targetPlayer, POLICY_HANDBOOK_UPGRADES, report)
	table.insert(report, ("PolicyHandbookTier = %s"):format(tostring(targetPlayer:GetAttribute("PolicyHandbookTier"))))

	purchaseAll(targetPlayer, NEGOTIATOR_UPGRADES, report)
	table.insert(report, ("NegotiatorTier = %s"):format(tostring(targetPlayer:GetAttribute("NegotiatorTier"))))

	purchaseAll(targetPlayer, ECONOMIST_UPGRADES, report)
	table.insert(report, ("EconomistTier = %s"):format(tostring(targetPlayer:GetAttribute("EconomistTier"))))

	purchaseAll(targetPlayer, GAMBLER_UPGRADES, report)
	table.insert(report, ("GamblerTier = %s"):format(tostring(targetPlayer:GetAttribute("GamblerTier"))))

	purchaseAll(targetPlayer, GOLDEN_FAVOR_UPGRADES, report)
	table.insert(report, ("GoldenFavorTier = %s"):format(tostring(targetPlayer:GetAttribute("GoldenFavorTier"))))

	purchaseAll(targetPlayer, SIGHT_SEEING_UPGRADES, report)
	table.insert(report, ("SightSeeingTier = %s"):format(tostring(targetPlayer:GetAttribute("SightSeeingTier"))))

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
