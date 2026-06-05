--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UpgradeDefinitions"))
local ViolationDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViolationDefinitions"))

local DEFAULT_WALK_SPEED = 16
local PASSIVE_CITATION_SECONDS = 30
local INTEREST_SECONDS = 30
local REMOTES_FOLDER_NAME = "Remotes"
local PURCHASE_REMOTE_NAME = "PurchaseUpgrade"

local UpgradeService = {}

local playerUpgrades: { [Player]: { [UpgradeDefinitions.UpgradeCategory]: number } } = {}
local purchaseUpgradeRemote: RemoteFunction? = nil
local passiveCitationRng = Random.new()
local moneyRng = Random.new()

local function getLeaderstat(player: Player, statName: string): IntValue?
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local stat = leaderstats:FindFirstChild(statName)
	if stat and stat:IsA("IntValue") then
		return stat
	end

	return nil
end

local function getOrCreateRemoteFunction(parent: Instance, name: string): RemoteFunction
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = parent

	return remote
end

local function getOrCreateFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	return folder
end

local function getCategoryTier(player: Player, category: UpgradeDefinitions.UpgradeCategory): number
	local upgrades = playerUpgrades[player]
	if not upgrades then
		return 0
	end

	return upgrades[category] or 0
end

local function setCategoryTier(player: Player, category: UpgradeDefinitions.UpgradeCategory, tier: number)
	local upgrades = playerUpgrades[player]
	if not upgrades then
		upgrades = {}
		playerUpgrades[player] = upgrades
	end

	upgrades[category] = tier
	player:SetAttribute(category .. "Tier", tier)
end

local function getDefinitionForTier(category: UpgradeDefinitions.UpgradeCategory, tier: number): UpgradeDefinitions.UpgradeDefinition?
	for _, definition in UpgradeDefinitions do
		if definition.Category == category and definition.Tier == tier then
			return definition
		end
	end

	return nil
end

local function getAvailableCitationRewards(): { number }
	local rewards = {}

	for _, definition in ViolationDefinitions do
		if definition.Availability ~= "Unavailable" then
			table.insert(rewards, definition.BaseReward)
		end
	end

	return rewards
end

local function getBoardFavorBonus(player: Player): number
	local boardFavorTier = getCategoryTier(player, "BoardFavor")
	local boardFavorDefinition = getDefinitionForTier("BoardFavor", boardFavorTier)
	if boardFavorDefinition
		and boardFavorDefinition.BonusChance
		and boardFavorDefinition.BonusMoney
		and math.random() < boardFavorDefinition.BonusChance
	then
		return boardFavorDefinition.BonusMoney
	end

	return 0
end

local function getTierDefinition(player: Player, category: UpgradeDefinitions.UpgradeCategory): UpgradeDefinitions.UpgradeDefinition?
	return getDefinitionForTier(category, getCategoryTier(player, category))
end

local function getCitationCount(player: Player): number
	local leaderstats = player:FindFirstChild("leaderstats")
	local citations = leaderstats and leaderstats:FindFirstChild("Citations")
	if citations and citations:IsA("IntValue") then
		return citations.Value
	end

	return 0
end

local function awardEconomistInterest(player: Player)
	local definition = getTierDefinition(player, "Economist")
	if not definition or not definition.InterestPercent then
		return
	end

	local money = getLeaderstat(player, "Money")
	if not money or money.Value <= 0 then
		return
	end

	money.Value += math.max(1, math.floor((money.Value * definition.InterestPercent) + 0.5))
end

local function awardPassiveCitationMoney(player: Player)
	local gogglesTier = getCategoryTier(player, "CitationGoggles")
	local gogglesDefinition = getDefinitionForTier("CitationGoggles", gogglesTier)
	if not gogglesDefinition or not gogglesDefinition.PassiveCitationAwards then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local money = leaderstats and leaderstats:FindFirstChild("Money")
	if not money or not money:IsA("IntValue") then
		return
	end

	local rewards = getAvailableCitationRewards()
	if #rewards == 0 then
		return
	end

	local totalMoney = 0
	for _ = 1, gogglesDefinition.PassiveCitationAwards do
		local reward = rewards[passiveCitationRng:NextInteger(1, #rewards)]
		totalMoney += reward

		if gogglesDefinition.PassiveUsesBoardFavor then
			totalMoney += getBoardFavorBonus(player)
		end
	end

	money.Value += totalMoney
end

local function applyMotorLegs(player: Player)
	local tier = getCategoryTier(player, "MotorLegs")
	local definition = getDefinitionForTier("MotorLegs", tier)
	local walkSpeed = if definition and definition.WalkSpeed then definition.WalkSpeed else DEFAULT_WALK_SPEED

	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = walkSpeed
	end
end

local function setupPlayer(player: Player)
	playerUpgrades[player] = {
		Camera = 0,
		MotorLegs = 0,
		BoardFavor = 0,
		CitationGoggles = 0,
		EagleEyes = 0,
		ReputationBadge = 0,
		PolicyHandbook = 0,
		Negotiator = 0,
		Economist = 0,
		Gambler = 0,
		GoldenFavor = 0,
		SightSeeing = 0,
	}

	player:SetAttribute("CameraTier", 0)
	player:SetAttribute("MotorLegsTier", 0)
	player:SetAttribute("BoardFavorTier", 0)
	player:SetAttribute("CitationGogglesTier", 0)
	player:SetAttribute("EagleEyesTier", 0)
	player:SetAttribute("ReputationBadgeTier", 0)
	player:SetAttribute("PolicyHandbookTier", 0)
	player:SetAttribute("NegotiatorTier", 0)
	player:SetAttribute("EconomistTier", 0)
	player:SetAttribute("GamblerTier", 0)
	player:SetAttribute("GoldenFavorTier", 0)
	player:SetAttribute("SightSeeingTier", 0)

	player.CharacterAdded:Connect(function()
		applyMotorLegs(player)
	end)
end

function UpgradeService.GetCitationMoney(player: Player, baseMoney: number): number
	local cameraTier = getCategoryTier(player, "Camera")
	local cameraDefinition = getDefinitionForTier("Camera", cameraTier)
	local multiplier = if cameraDefinition and cameraDefinition.MoneyMultiplier then cameraDefinition.MoneyMultiplier else 1
	local cameraMoney = math.floor((baseMoney * multiplier) + 0.5)
	local boardFavorBonus = getBoardFavorBonus(player)

	local negotiatorDefinition = getTierDefinition(player, "Negotiator")
	if negotiatorDefinition and negotiatorDefinition.NegotiatorChance and moneyRng:NextNumber() < negotiatorDefinition.NegotiatorChance then
		if moneyRng:NextInteger(1, 2) == 1 then
			cameraMoney *= 2
		elseif boardFavorBonus > 0 then
			boardFavorBonus *= 5
		end
	end

	local totalMoney = cameraMoney + boardFavorBonus

	local goldenFavorDefinition = getTierDefinition(player, "GoldenFavor")
	if goldenFavorDefinition
		and goldenFavorDefinition.GoldenFavorChance
		and moneyRng:NextNumber() < goldenFavorDefinition.GoldenFavorChance
	then
		totalMoney += math.floor((getCitationCount(player) * 0.1) + 0.5)
	end

	return totalMoney
end

function UpgradeService.GetCitationXP(player: Player, baseXP: number): number
	local badgeTier = getCategoryTier(player, "ReputationBadge")
	local badgeDefinition = getDefinitionForTier("ReputationBadge", badgeTier)
	local multiplier = if badgeDefinition and badgeDefinition.XPMultiplier then badgeDefinition.XPMultiplier else 1

	return math.floor((baseXP * multiplier) + 0.5)
end

function UpgradeService.GetEagleEyeSettings(player: Player): (number, number, boolean)
	local eagleEyesTier = getCategoryTier(player, "EagleEyes")
	local eagleEyesDefinition = getDefinitionForTier("EagleEyes", eagleEyesTier)
	if not eagleEyesDefinition then
		return 0, 0, false
	end

	return eagleEyesDefinition.HighlightCount or 0,
		eagleEyesDefinition.HighlightDistance or 0,
		eagleEyesDefinition.CanFocusCitation == true
end

function UpgradeService.GetPolicyUnlockCount(player: Player): number
	local definition = getTierDefinition(player, "PolicyHandbook")
	return if definition and definition.PolicyUnlockCount then definition.PolicyUnlockCount else 0
end

function UpgradeService.GetPromptActivationDistance(player: Player, baseDistance: number): number
	local definition = getTierDefinition(player, "SightSeeing")
	local extraDistance = if definition and definition.SightSeeingExtraDistance then definition.SightSeeingExtraDistance else 0

	return baseDistance + extraDistance
end

function UpgradeService.PurchaseUpgrade(player: Player, upgradeId: string): (boolean, string)
	local definition = UpgradeDefinitions[upgradeId]
	if not definition then
		return false, "UnknownUpgrade"
	end

	local currentTier = getCategoryTier(player, definition.Category)
	if definition.Tier ~= currentTier + 1 then
		return false, "WrongTier"
	end

	local currency = definition.CostCurrency or "Money"
	local stat = getLeaderstat(player, currency)
	if not stat then
		return false, "Missing" .. currency .. "Stat"
	end

	if stat.Value < definition.Cost then
		return false, "NotEnough" .. currency
	end

	stat.Value -= definition.Cost
	setCategoryTier(player, definition.Category, definition.Tier)

	if definition.Category == "MotorLegs" then
		applyMotorLegs(player)
	end

	return true, "Purchased"
end

function UpgradeService.Start()
	local remotes = getOrCreateFolder(ReplicatedStorage, REMOTES_FOLDER_NAME)
	purchaseUpgradeRemote = getOrCreateRemoteFunction(remotes, PURCHASE_REMOTE_NAME)

	purchaseUpgradeRemote.OnServerInvoke = function(player, upgradeId)
		if typeof(upgradeId) ~= "string" then
			return false, "InvalidUpgradeId"
		end

		return UpgradeService.PurchaseUpgrade(player, upgradeId)
	end

	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end

	Players.PlayerAdded:Connect(setupPlayer)
	Players.PlayerRemoving:Connect(function(player)
		playerUpgrades[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(PASSIVE_CITATION_SECONDS)

			for _, player in Players:GetPlayers() do
				awardPassiveCitationMoney(player)
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(INTEREST_SECONDS)

			for _, player in Players:GetPlayers() do
				awardEconomistInterest(player)
			end
		end
	end)
end

return UpgradeService
