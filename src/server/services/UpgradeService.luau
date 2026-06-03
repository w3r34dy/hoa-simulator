--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UpgradeDefinitions"))

local DEFAULT_WALK_SPEED = 16
local REMOTES_FOLDER_NAME = "Remotes"
local PURCHASE_REMOTE_NAME = "PurchaseUpgrade"

local UpgradeService = {}

local playerUpgrades: { [Player]: { [UpgradeDefinitions.UpgradeCategory]: number } } = {}
local purchaseUpgradeRemote: RemoteFunction? = nil

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
	}

	player:SetAttribute("CameraTier", 0)
	player:SetAttribute("MotorLegsTier", 0)
	player:SetAttribute("BoardFavorTier", 0)

	player.CharacterAdded:Connect(function()
		applyMotorLegs(player)
	end)
end

function UpgradeService.GetCitationMoney(player: Player, baseMoney: number): number
	local cameraTier = getCategoryTier(player, "Camera")
	local cameraDefinition = getDefinitionForTier("Camera", cameraTier)
	local multiplier = if cameraDefinition and cameraDefinition.MoneyMultiplier then cameraDefinition.MoneyMultiplier else 1
	local totalMoney = math.floor((baseMoney * multiplier) + 0.5)

	local boardFavorTier = getCategoryTier(player, "BoardFavor")
	local boardFavorDefinition = getDefinitionForTier("BoardFavor", boardFavorTier)
	if boardFavorDefinition
		and boardFavorDefinition.BonusChance
		and boardFavorDefinition.BonusMoney
		and math.random() < boardFavorDefinition.BonusChance
	then
		totalMoney += boardFavorDefinition.BonusMoney
	end

	return totalMoney
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

	local money = getLeaderstat(player, "Money")
	if not money then
		return false, "MissingMoneyStat"
	end

	if money.Value < definition.Cost then
		return false, "NotEnoughMoney"
	end

	money.Value -= definition.Cost
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
end

return UpgradeService
