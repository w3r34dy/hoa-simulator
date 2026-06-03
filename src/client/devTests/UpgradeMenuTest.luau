--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UpgradeDefinitions"))

local PLAYER = Players.LocalPlayer
local REMOTES = ReplicatedStorage:WaitForChild("Remotes")
local PURCHASE_UPGRADE = REMOTES:WaitForChild("PurchaseUpgrade") :: RemoteFunction

local UpgradeMenuTest = {}

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

local function getTier(category: UpgradeDefinitions.UpgradeCategory): number
	local value = PLAYER:GetAttribute(category .. "Tier")
	if typeof(value) == "number" then
		return value
	end

	return 0
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
	panel.Size = UDim2.fromScale(0.9, 0.78)
	panel.Parent = overlay

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = panel

	local title = createTextLabel(panel, "Title", "Upgrade Store", UDim2.new(1, -180, 0, 34), UDim2.fromOffset(28, 22))
	title.TextSize = 26

	local closeButton = createButton(panel, "CloseButton", UDim2.fromOffset(92, 36), UDim2.new(1, -120, 0, 22))
	closeButton.Text = "Close"

	local moneyLabel = createTextLabel(panel, "Money", "Money: ...", UDim2.fromOffset(240, 24), UDim2.fromOffset(28, 62))
	moneyLabel.TextSize = 18

	local statusLabel = createTextLabel(panel, "Status", "", UDim2.new(1, -56, 0, 42), UDim2.new(0, 28, 1, -62))
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 15
	statusLabel.TextWrapped = true

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Position = UDim2.fromOffset(28, 104)
	content.Size = UDim2.new(1, -56, 1, -178)
	content.Parent = panel

	local cameraSection = Instance.new("Frame")
	cameraSection.Name = "CameraSection"
	cameraSection.BackgroundTransparency = 1
	cameraSection.Position = UDim2.fromScale(0, 0)
	cameraSection.Size = UDim2.new(0.5, -14, 1, 0)
	cameraSection.Parent = content

	local legsSection = Instance.new("Frame")
	legsSection.Name = "MotorLegsSection"
	legsSection.BackgroundTransparency = 1
	legsSection.Position = UDim2.new(0.333, 12, 0, 0)
	legsSection.Size = UDim2.new(0.333, -18, 1, 0)
	legsSection.Parent = content

	local boardFavorSection = Instance.new("Frame")
	boardFavorSection.Name = "BoardFavorSection"
	boardFavorSection.BackgroundTransparency = 1
	boardFavorSection.Position = UDim2.new(0.666, 12, 0, 0)
	boardFavorSection.Size = UDim2.new(0.334, -12, 1, 0)
	boardFavorSection.Parent = content

	cameraSection.Size = UDim2.new(0.333, -18, 1, 0)

	createTextLabel(cameraSection, "CameraTitle", "Camera", UDim2.new(1, 0, 0, 26), UDim2.fromOffset(0, 0)).TextSize = 20
	createTextLabel(legsSection, "LegsTitle", "Motor Legs", UDim2.new(1, 0, 0, 26), UDim2.fromOffset(0, 0)).TextSize = 20
	createTextLabel(boardFavorSection, "BoardFavorTitle", "Board Favor", UDim2.new(1, 0, 0, 26), UDim2.fromOffset(0, 0)).TextSize = 20

	local buttons: { [TextButton]: UpgradeDefinitions.UpgradeDefinition } = {}

	for index, definition in getSortedDefinitions("Camera") do
		local button = createUpgradeCard(cameraSection, definition, UDim2.fromOffset(0, 42 + ((index - 1) * 70)))
		buttons[button] = definition
	end

	for index, definition in getSortedDefinitions("MotorLegs") do
		local button = createUpgradeCard(legsSection, definition, UDim2.fromOffset(0, 42 + ((index - 1) * 70)))
		buttons[button] = definition
	end

	for index, definition in getSortedDefinitions("BoardFavor") do
		local button = createUpgradeCard(boardFavorSection, definition, UDim2.fromOffset(0, 42 + ((index - 1) * 70)))
		buttons[button] = definition
	end

	local function refresh()
		local money = getMoneyStat()
		moneyLabel.Text = ("Money: %s"):format(if money then tostring(money.Value) else "missing")

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
				effectText = ("%.0f%% chance +$%d"):format(definition.BonusChance * 100, definition.BonusMoney)
			end

			button.Text = ("%s\n$%d | %s"):format(definition.DisplayName, definition.Cost, effectText)
			button.BackgroundColor3 = if owned then Color3.fromRGB(42, 92, 62) else Color3.fromRGB(45, 61, 82)
			button.Active = not owned and nextTier
			button.AutoButtonColor = not owned and nextTier

			if owned then
				button.Text = ("%s\nOwned | %s"):format(definition.DisplayName, effectText)
			elseif not nextTier then
				button.Text = ("%s\nLocked | %s"):format(definition.DisplayName, effectText)
			end
		end
	end

	openButton.Activated:Connect(function()
		overlay.Visible = true
		refresh()
	end)

	closeButton.Activated:Connect(function()
		overlay.Visible = false
	end)

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

	local money = getMoneyStat()
	if money then
		money.Changed:Connect(refresh)
	end

	PLAYER:GetAttributeChangedSignal("CameraTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("MotorLegsTier"):Connect(refresh)
	PLAYER:GetAttributeChangedSignal("BoardFavorTier"):Connect(refresh)

	refresh()
end

return UpgradeMenuTest
