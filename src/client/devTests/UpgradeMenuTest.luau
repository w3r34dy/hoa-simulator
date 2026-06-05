--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UpgradeDefinitions"))
local ViolationDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViolationDefinitions"))

local PLAYER = Players.LocalPlayer
local REMOTES = ReplicatedStorage:WaitForChild("Remotes")
local PURCHASE_UPGRADE = REMOTES:WaitForChild("PurchaseUpgrade") :: RemoteFunction
local GET_EAGLE_EYE_TARGETS = REMOTES:WaitForChild("GetEagleEyeTargets") :: RemoteFunction
local SET_EAGLE_EYE_FOCUS = REMOTES:WaitForChild("SetEagleEyeFocus") :: RemoteFunction

type ShopTab = "Gear" | "Skills"

local CATEGORY_ORDER_BY_TAB: { [ShopTab]: { UpgradeDefinitions.UpgradeCategory } } = {
	Gear = {
		"Camera",
		"MotorLegs",
		"BoardFavor",
		"CitationGoggles",
		"EagleEyes",
		"ReputationBadge",
	},
	Skills = {
		"PolicyHandbook",
		"Negotiator",
		"Economist",
		"Gambler",
		"GoldenFavor",
		"SightSeeing",
	},
}

local TAB_TITLES: { [ShopTab]: string } = {
	Gear = "Gear",
	Skills = "Skills",
}

local TAB_ORDER: { ShopTab } = {
	"Gear",
	"Skills",
}

local CATEGORY_ORDER: { UpgradeDefinitions.UpgradeCategory } = {
	"Camera",
	"MotorLegs",
	"BoardFavor",
	"CitationGoggles",
	"EagleEyes",
	"ReputationBadge",
	"PolicyHandbook",
	"Negotiator",
	"Economist",
	"Gambler",
	"GoldenFavor",
	"SightSeeing",
}

local CATEGORY_TITLES: { [UpgradeDefinitions.UpgradeCategory]: string } = {
	Camera = "Camera",
	MotorLegs = "Motor Legs",
	BoardFavor = "Board Favor",
	CitationGoggles = "Citation Goggles",
	EagleEyes = "Eagle Eyes",
	ReputationBadge = "Reputation Badge",
	PolicyHandbook = "Policy Handbook",
	Negotiator = "Negotiator",
	Economist = "Economist",
	Gambler = "Gambler",
	GoldenFavor = "Golden Favor",
	SightSeeing = "Sight Seeing",
}

local eagleEyeHighlights: { [Instance]: Highlight } = {}

local UpgradeMenuTest = {}

type FocusOption = {
	Id: string,
	DisplayName: string,
}

local function getMoneyStat(): IntValue?
	local leaderstats = PLAYER:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local money = leaderstats:FindFirstChild("Money")
	if money and money:IsA("IntValue") then
		return money
	end

	return nil
end

local function getXPStat(): IntValue?
	local leaderstats = PLAYER:FindFirstChild("leaderstats")
	if not leaderstats then
		return nil
	end

	local xp = leaderstats:FindFirstChild("XP")
	if xp and xp:IsA("IntValue") then
		return xp
	end

	return nil
end

local function getSortedDefinitions(category: UpgradeDefinitions.UpgradeCategory): { UpgradeDefinitions.UpgradeDefinition }
	local definitions = {}

	for _, definition in UpgradeDefinitions do
		if definition.Category == category then
			table.insert(definitions, definition)
		end
	end

	table.sort(definitions, function(left, right)
		return left.Tier < right.Tier
	end)

	return definitions
end

local function createTextLabel(parent: Instance, name: string, text: string, size: UDim2, position: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Position = position
	label.Size = size
	label.Text = text
	label.TextColor3 = Color3.fromRGB(245, 247, 250)
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	return label
end

local function createButton(parent: Instance, name: string, size: UDim2, position: UDim2): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.AutoButtonColor = true
	button.BackgroundColor3 = Color3.fromRGB(45, 61, 82)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.Gotham
	button.Position = position
	button.Size = size
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 16
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	return button
end

local function createOptionButton(parent: Instance, name: string, size: UDim2, position: UDim2): TextButton
	local button = createButton(parent, name, size, position)
	button.BackgroundColor3 = Color3.fromRGB(35, 47, 64)
	button.TextSize = 12
	button.TextXAlignment = Enum.TextXAlignment.Left

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = button

	return button
end

local function getTier(category: UpgradeDefinitions.UpgradeCategory): number
	local value = PLAYER:GetAttribute(category .. "Tier")
	if typeof(value) == "number" then
		return value
	end

	return 0
end

local function getPolicyUnlockCount(): number
	local policyTier = getTier("PolicyHandbook")
	local unlockCount = 0

	for _, definition in UpgradeDefinitions do
		if definition.Category == "PolicyHandbook" and definition.Tier == policyTier and definition.PolicyUnlockCount then
			unlockCount = definition.PolicyUnlockCount
			break
		end
	end

	return unlockCount
end

local function createUpgradeCard(parent: Instance, definition: UpgradeDefinitions.UpgradeDefinition, position: UDim2): TextButton
	local card = createButton(parent, definition.Id, UDim2.new(1, 0, 0, 62), position)
	card.TextWrapped = true
	card.TextXAlignment = Enum.TextXAlignment.Left
	card.TextYAlignment = Enum.TextYAlignment.Center
	card.TextSize = 14

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	padding.Parent = card

	return card
end

local function createSection(parent: Instance, category: UpgradeDefinitions.UpgradeCategory): Frame
	local section = Instance.new("Frame")
	section.Name = category .. "Section"
	section.BackgroundTransparency = 1
	section.Parent = parent

	createTextLabel(section, category .. "Title", CATEGORY_TITLES[category], UDim2.new(1, 0, 0, 26), UDim2.fromOffset(0, 0)).TextSize = 20

	return section
end

local function getAvailableFocusOptions(): { FocusOption }
	local options = {
		{
			Id = "",
			DisplayName = "Focus Off",
		},
	}

	local ids = {}
	for id in ViolationDefinitions do
		table.insert(ids, id)
	end

	table.sort(ids, function(left, right)
		return ViolationDefinitions[left].DisplayName < ViolationDefinitions[right].DisplayName
	end)

	for index = 1, #ids do
		local id = ids[index]
		local definition = ViolationDefinitions[id]
		table.insert(options, {
			Id = id,
			DisplayName = definition.DisplayName,
		})
	end

	return options
end

local function isFocusOptionUnlocked(violationId: string): boolean
	if violationId == "" then
		return true
	end

	local ids = {}
	for id in ViolationDefinitions do
		table.insert(ids, id)
	end

	table.sort(ids, function(left, right)
		return ViolationDefinitions[left].DisplayName < ViolationDefinitions[right].DisplayName
	end)

	local unlockCount = getPolicyUnlockCount()
	for index = 1, math.min(unlockCount, #ids) do
		if ids[index] == violationId then
			return true
		end
	end

	return false
end

local function getFocusDisplayName(focusId: string): string
	if focusId == "" then
		return "Off"
	end

	local definition = ViolationDefinitions[focusId]
	return if definition then definition.DisplayName else "Auto"
end

local function clearEagleEyeHighlights()
	for _, highlight in eagleEyeHighlights do
		highlight:Destroy()
	end

	table.clear(eagleEyeHighlights)
end

local function syncEagleEyeHighlights()
	local success, targets = pcall(function()
		return GET_EAGLE_EYE_TARGETS:InvokeServer()
	end)

	if not success or typeof(targets) ~= "table" then
		clearEagleEyeHighlights()
		return
	end

	local targetSet: { [Instance]: boolean } = {}
	for _, target in targets do
		if typeof(target) == "Instance" and target.Parent then
			targetSet[target] = true

			if eagleEyeHighlights[target] then
				continue
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "EagleEyeHighlight"
			highlight.Adornee = target
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillColor = Color3.fromRGB(255, 221, 92)
			highlight.FillTransparency = 0.55
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineTransparency = 0
			highlight.Parent = target
			eagleEyeHighlights[target] = highlight
		end
	end

	for target, highlight in eagleEyeHighlights do
		if not targetSet[target] then
			highlight:Destroy()
			eagleEyeHighlights[target] = nil
		end
	end
end

function UpgradeMenuTest.Start()
	local playerGui = PLAYER:WaitForChild("PlayerGui")
	local existing = playerGui:FindFirstChild("UpgradeMenuTest")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UpgradeMenuTest"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local openButton = createButton(screenGui, "OpenButton", UDim2.fromOffset(132, 42), UDim2.new(1, -152, 0, 74))
	openButton.Text = "Upgrades"

	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.BackgroundColor3 = Color3.fromRGB(7, 10, 14)
	overlay.BackgroundTransparency = 0.18
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Visible = false
	overlay.Parent = screenGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Color3.fromRGB(24, 29, 36)
	panel.BorderSizePixel = 0
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.88, 0.82)
	panel.Parent = overlay
	panel.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = panel

	local title = createTextLabel(panel, "Title", "Upgrade Store", UDim2.new(1, -180, 0, 34), UDim2.fromOffset(28, 22))
	title.TextSize = 26

	local closeButton = createButton(panel, "CloseButton", UDim2.fromOffset(92, 36), UDim2.new(1, -120, 0, 22))
	closeButton.Text = "Close"

	local moneyLabel = createTextLabel(panel, "Money", "Money: ...", UDim2.fromOffset(240, 24), UDim2.fromOffset(28, 62))
	moneyLabel.TextSize = 18

	local tabButtons: { [ShopTab]: TextButton } = {}
	local activeTab: ShopTab = "Gear"
	for tabIndex, tab in TAB_ORDER do
		local tabButton = createButton(panel, tab .. "Tab", UDim2.fromOffset(96, 30), UDim2.fromOffset(28 + ((tabIndex - 1) * 104), 94))
		tabButton.Text = TAB_TITLES[tab]
		tabButton.TextSize = 14
		tabButtons[tab] = tabButton
	end

	local statusLabel = createTextLabel(panel, "Status", "", UDim2.new(1, -56, 0, 36), UDim2.new(0, 28, 1, -46))
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 15
	statusLabel.TextWrapped = true

	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.CanvasSize = UDim2.fromOffset(0, 0)
	content.ScrollBarThickness = 8
	content.Position = UDim2.fromOffset(28, 136)
	content.Size = UDim2.new(1, -56, 1, -186)
	content.Parent = panel

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingRight = UDim.new(0, 8)
	contentPadding.Parent = content

	local grid = Instance.new("UIGridLayout")
	grid.CellPadding = UDim2.fromOffset(24, 28)
	grid.CellSize = UDim2.new(0.333, -18, 0, 454)
	grid.FillDirectionMaxCells = 3
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = content

	local buttons: { [TextButton]: UpgradeDefinitions.UpgradeDefinition } = {}
	local focusDropdownButton: TextButton? = nil
	local focusOptionsFrame: Frame? = nil
	local focusOptionButtons: { [TextButton]: string } = {}
	local sectionsByCategory: { [UpgradeDefinitions.UpgradeCategory]: Frame } = {}
	local skillsEmptyLabel = createTextLabel(content, "SkillsEmpty", "No skill upgrades yet", UDim2.new(1, 0, 0, 28), UDim2.fromOffset(0, 0))
	skillsEmptyLabel.TextSize = 18
	skillsEmptyLabel.Visible = false

	local function updateContentCanvas()
		local extraDropdownSpace = if focusOptionsFrame and focusOptionsFrame.Visible then focusOptionsFrame.AbsoluteSize.Y + 12 else 8
		content.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + extraDropdownSpace)
	end

	for layoutOrder, category in CATEGORY_ORDER do
		local section = createSection(content, category)
		section.LayoutOrder = layoutOrder
		sectionsByCategory[category] = section

		for index, definition in getSortedDefinitions(category) do
			local button = createUpgradeCard(section, definition, UDim2.fromOffset(0, 42 + ((index - 1) * 70)))
			button.Size = UDim2.new(1, 0, 0, 62)
			buttons[button] = definition
		end

		if category == "EagleEyes" then
			local focusLabel = createTextLabel(section, "FocusTitle", "Focus", UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, 394))
			focusLabel.TextSize = 14

			local dropdownButton = createButton(section, "FocusDropdown", UDim2.new(1, 0, 0, 32), UDim2.fromOffset(0, 416))
			dropdownButton.Text = "Focus: Off   v"
			dropdownButton.TextXAlignment = Enum.TextXAlignment.Left

			local dropdownPadding = Instance.new("UIPadding")
			dropdownPadding.PaddingLeft = UDim.new(0, 12)
			dropdownPadding.PaddingRight = UDim.new(0, 12)
			dropdownPadding.Parent = dropdownButton

			local optionsFrame = Instance.new("Frame")
			optionsFrame.Name = "FocusOptions"
			optionsFrame.BackgroundColor3 = Color3.fromRGB(28, 36, 48)
			optionsFrame.BorderSizePixel = 0
			optionsFrame.Position = UDim2.fromOffset(0, 452)
			optionsFrame.Size = UDim2.new(1, 0, 0, 0)
			optionsFrame.Visible = false
			optionsFrame.ClipsDescendants = true
			optionsFrame.Parent = section

			local optionsCorner = Instance.new("UICorner")
			optionsCorner.CornerRadius = UDim.new(0, 6)
			optionsCorner.Parent = optionsFrame

			local focusOptions = getAvailableFocusOptions()
			optionsFrame.Size = UDim2.new(1, 0, 0, #focusOptions * 30)

			for optionIndex, option in focusOptions do
				local optionButton = createOptionButton(
					optionsFrame,
					"FocusOption" .. option.Id,
					UDim2.new(1, -8, 0, 26),
					UDim2.fromOffset(4, 2 + ((optionIndex - 1) * 30))
				)
				optionButton.Text = option.DisplayName
				focusOptionButtons[optionButton] = option.Id
			end

			focusDropdownButton = dropdownButton
			focusOptionsFrame = optionsFrame
		end
	end

	local function showTab(tab: ShopTab)
		activeTab = tab

		for category, section in sectionsByCategory do
			section.Parent = nil
		end

		for layoutOrder, category in CATEGORY_ORDER_BY_TAB[tab] do
			local section = sectionsByCategory[category]
			if section then
				section.LayoutOrder = layoutOrder
				section.Parent = content
			end
		end

		if focusOptionsFrame then
			focusOptionsFrame.Visible = false
		end
		skillsEmptyLabel.Visible = #CATEGORY_ORDER_BY_TAB[tab] == 0
		skillsEmptyLabel.Parent = if skillsEmptyLabel.Visible then content else nil

		for tabName, tabButton in tabButtons do
			tabButton.BackgroundColor3 = if tabName == activeTab then Color3.fromRGB(42, 92, 62) else Color3.fromRGB(45, 61, 82)
		end

		updateContentCanvas()
	end

	grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		updateContentCanvas()
	end)

	local function refresh()
		local money = getMoneyStat()
		local xp = getXPStat()
		moneyLabel.Text = ("Money: %s    XP: %s"):format(
			if money then tostring(money.Value) else "missing",
			if xp then tostring(xp.Value) else "missing"
		)

		for button, definition in buttons do
			local currentTier = getTier(definition.Category)
			local owned = currentTier >= definition.Tier
			local nextTier = definition.Tier == currentTier + 1

			local effectText = ""
			if definition.MoneyMultiplier then
				effectText = ("%.0f%% citation payout"):format(definition.MoneyMultiplier * 100)
			elseif definition.WalkSpeed then
				effectText = ("WalkSpeed %d"):format(definition.WalkSpeed)
			elseif definition.BonusChance and definition.BonusMoney then
				effectText = ("%.0f%% chance to add $%d per citation"):format(
					definition.BonusChance * 100,
					definition.BonusMoney
				)
			elseif definition.PassiveCitationAwards then
				effectText = ("%d random citation payout%s every 30s%s"):format(
					definition.PassiveCitationAwards,
					if definition.PassiveCitationAwards == 1 then "" else "s",
					if definition.PassiveUsesBoardFavor then " + Board Favor" else ""
				)
			elseif definition.HighlightCount and definition.HighlightDistance then
				effectText = ("Highlights %d nearby citation%s%s"):format(
					definition.HighlightCount,
					if definition.HighlightCount == 1 then "" else "s",
					if definition.CanFocusCitation then " + focus choice" else ""
				)
			elseif definition.XPMultiplier then
				effectText = ("%.0f%% XP per citation"):format(definition.XPMultiplier * 100)
			elseif definition.PolicyUnlockCount then
				effectText = ("Unlocks %d policy focus options"):format(definition.PolicyUnlockCount)
			elseif definition.NegotiatorChance then
				effectText = ("%.1f%% chance to boost camera or favor"):format(definition.NegotiatorChance * 100)
			elseif definition.InterestPercent then
				effectText = ("Earn %.1f%% interest every 30s"):format(definition.InterestPercent * 100)
			elseif definition.GamblerDoubleChance then
				effectText = ("%.0f%% citation payout gamble option"):format(definition.GamblerDoubleChance * 100)
			elseif definition.GoldenFavorChance then
				effectText = ("%.1f%% chance for 10%% citation-count cashback"):format(definition.GoldenFavorChance * 100)
			elseif definition.SightSeeingExtraDistance then
				effectText = ("Write citations from farther away (+%d range)"):format(definition.SightSeeingExtraDistance)
			end

			local costText = if definition.CostCurrency == "XP" then ("%d XP"):format(definition.Cost) else ("$%d"):format(definition.Cost)
			button.Text = ("%s\n%s | %s"):format(definition.DisplayName, costText, effectText)
			button.BackgroundColor3 = if owned then Color3.fromRGB(42, 92, 62) else Color3.fromRGB(45, 61, 82)
			button.Active = not owned and nextTier
			button.AutoButtonColor = not owned and nextTier

			if owned then
				button.Text = ("%s\nOwned | %s"):format(definition.DisplayName, effectText)
			elseif not nextTier then
				button.Text = ("%s\nLocked | %s"):format(definition.DisplayName, effectText)
			end
		end

		local eagleEyesTier = getTier("EagleEyes")
		local focusIdValue = PLAYER:GetAttribute("EagleEyeFocusId")
		local focusId = if typeof(focusIdValue) == "string" then focusIdValue else ""
		if focusDropdownButton then
			local unlocked = eagleEyesTier >= 5
			focusDropdownButton.Text = ("Focus: %s   v"):format(getFocusDisplayName(focusId))
			focusDropdownButton.Active = unlocked
			focusDropdownButton.AutoButtonColor = unlocked
			focusDropdownButton.BackgroundColor3 = if unlocked then Color3.fromRGB(45, 61, 82) else Color3.fromRGB(35, 41, 50)
		end
		for button, violationId in focusOptionButtons do
			local unlocked = eagleEyesTier >= 5
			local optionUnlocked = isFocusOptionUnlocked(violationId)
			button.Visible = optionUnlocked
			button.Active = unlocked and optionUnlocked
			button.AutoButtonColor = unlocked and optionUnlocked
			button.BackgroundColor3 = if violationId == focusId then Color3.fromRGB(42, 92, 62) else Color3.fromRGB(35, 47, 64)
		end

		if focusOptionsFrame then
			local visibleOptionIndex = 0
			for button, violationId in focusOptionButtons do
				if isFocusOptionUnlocked(violationId) then
					button.Position = UDim2.fromOffset(4, 2 + (visibleOptionIndex * 30))
					visibleOptionIndex += 1
				end
			end

			focusOptionsFrame.Size = UDim2.new(1, 0, 0, math.max(1, visibleOptionIndex) * 30)
		end

		for tabName, tabButton in tabButtons do
			tabButton.BackgroundColor3 = if tabName == activeTab then Color3.fromRGB(42, 92, 62) else Color3.fromRGB(45, 61, 82)
		end
	end

	openButton.Activated:Connect(function()
		overlay.Visible = true
		refresh()
	end)

	closeButton.Activated:Connect(function()
		overlay.Visible = false
	end)

	for tab, tabButton in tabButtons do
		tabButton.Activated:Connect(function()
			showTab(tab)
			refresh()
		end)
	end

	for button, definition in buttons do
		button.Activated:Connect(function()
			if not button.Active then
				return
			end

			local success, message = PURCHASE_UPGRADE:InvokeServer(definition.Id)
			statusLabel.Text = ("%s: %s"):format(definition.DisplayName, tostring(message))
			refresh()
		end)
	end

	if focusDropdownButton and focusOptionsFrame then
		focusDropdownButton.Activated:Connect(function()
			if not focusDropdownButton or not focusDropdownButton.Active or not focusOptionsFrame then
				return
			end

			focusOptionsFrame.Visible = not focusOptionsFrame.Visible
			updateContentCanvas()
		end)
	end

	for button, violationId in focusOptionButtons do
		button.Activated:Connect(function()
			if not button.Active then
				return
			end

			local success, message = SET_EAGLE_EYE_FOCUS:InvokeServer(violationId)
			statusLabel.Text = ("Eagle Eyes: %s"):format(tostring(message))
			if focusOptionsFrame then
				focusOptionsFrame.Visible = false
				updateContentCanvas()
			end
			if success then
				syncEagleEyeHighlights()
			end
			refresh()
		end)
	end

	local money = getMoneyStat()
	if money then
		money.Changed:Connect(refresh)
	end
	local xp = getXPStat()
	if xp then
		xp.Changed:Connect(refresh)
	end

	PLAYER:GetAttributeChangedSignal("CameraTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("MotorLegsTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("BoardFavorTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("CitationGogglesTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("EagleEyesTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("ReputationBadgeTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("PolicyHandbookTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("NegotiatorTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("EconomistTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("GamblerTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("GoldenFavorTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("SightSeeingTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("EagleEyeFocusId"):Connect(refresh)

	task.spawn(function()
		while screenGui.Parent do
			syncEagleEyeHighlights()
			task.wait(4)
		end
	end)

	showTab(activeTab)
	refresh()
end

return UpgradeMenuTest
