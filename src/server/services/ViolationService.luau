--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStatsService = require(script.Parent.PlayerStatsService)
local TimeService = require(script.Parent.TimeService)
local UpgradeService = require(script.Parent.UpgradeService)
local ViolationDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViolationDefinitions"))

local GrassTooTall = require(script.Parent.Parent.violationHandlers.GrassTooTall)
local MailboxColor = require(script.Parent.Parent.violationHandlers.MailboxColor)
local ParkingOnLawn = require(script.Parent.Parent.violationHandlers.ParkingOnLawn)
local TrashCansOut = require(script.Parent.Parent.violationHandlers.TrashCansOut)

local PROMPT_NAME = "HOAInspectionPrompt"
local BASE_PROMPT_ACTIVATION_DISTANCE = 12
local MAX_SIGHT_SEEING_EXTRA_DISTANCE = 16
local REMOTES_FOLDER_NAME = "Remotes"
local GET_EAGLE_EYE_TARGETS_REMOTE_NAME = "GetEagleEyeTargets"
local SET_EAGLE_EYE_FOCUS_REMOTE_NAME = "SetEagleEyeFocus"
local RESPAWN_SECONDS = 12
local MAX_ACTIVE_VIOLATIONS = 24

type ActiveViolation = {
	Id: string,
	Target: Instance,
	PromptParent: BasePart?,
	Cleanup: () -> (),
	Prompt: ProximityPrompt?,
}

type ViolationHandler = {
	Initialize: (() -> ())?,
	GetAvailableTargets: () -> { Instance },
	Create: (target: Instance) -> ActiveViolation?,
	ShowAllCans: (() -> ())?,
	StoreInactiveCans: (() -> ())?,
}

local ViolationService = {}

local handlers: { [string]: ViolationHandler } = {
	GrassTooTall = GrassTooTall,
	MailboxColor = MailboxColor,
	ParkingOnLawn = ParkingOnLawn,
	TrashCansOut = TrashCansOut,
}

local activeViolations: { [Instance]: ActiveViolation } = {}
local eagleEyeTargetsByPlayer: { [Player]: { Instance } } = {}
local rng = Random.new()

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

local function countActiveViolations(): number
	local count = 0

	for target in activeViolations do
		if target.Parent then
			count += 1
		else
			activeViolations[target] = nil
		end
	end

	return count
end

local function countActiveViolationsById(id: string): number
	local count = 0

	for target, activeViolation in activeViolations do
		if not target.Parent then
			activeViolations[target] = nil
		elseif activeViolation.Id == id then
			count += 1
		end
	end

	return count
end

local function getPlayerPosition(player: Player): Vector3?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root.Position
	end

	return nil
end

local function getPolicyOrderedViolationIds(): { string }
	local ids = {}

	for id in ViolationDefinitions do
		table.insert(ids, id)
	end

	table.sort(ids, function(left, right)
		return ViolationDefinitions[left].DisplayName < ViolationDefinitions[right].DisplayName
	end)

	return ids
end

local function isPolicyUnlocked(player: Player, id: string): boolean
	local unlockCount = UpgradeService.GetPolicyUnlockCount(player)
	if unlockCount <= 0 then
		return false
	end

	for index, unlockedId in getPolicyOrderedViolationIds() do
		if index > unlockCount then
			return false
		end

		if unlockedId == id then
			return true
		end
	end

	return false
end

local function canPlayerReachPrompt(player: Player, promptParent: BasePart): boolean
	local playerPosition = getPlayerPosition(player)
	if not playerPosition then
		return false
	end

	local activationDistance = UpgradeService.GetPromptActivationDistance(player, BASE_PROMPT_ACTIVATION_DISTANCE)
	return (promptParent.Position - playerPosition).Magnitude <= activationDistance
end

local function isValidViolationId(player: Player, id: string): boolean
	local definition = ViolationDefinitions[id]
	return definition ~= nil and isPolicyUnlocked(player, id)
end

local function canHighlightViolation(
	playerPosition: Vector3,
	target: Instance,
	highlightDistance: number,
	focusId: any
): boolean
	local activeViolation = activeViolations[target]
	if not activeViolation then
		return false
	end

	local promptParent = activeViolation.PromptParent
	if not target.Parent or not promptParent or not promptParent.Parent then
		return false
	end

	if typeof(focusId) == "string" and focusId ~= "" and activeViolation.Id ~= focusId then
		return false
	end

	return (promptParent.Position - playerPosition).Magnitude <= highlightDistance
end

local function getActiveViolationTargets(player: Player): { Instance }
	local highlightCount, highlightDistance, canFocusCitation = UpgradeService.GetEagleEyeSettings(player)
	local currentTargets = eagleEyeTargetsByPlayer[player]
	if not currentTargets then
		currentTargets = {}
		eagleEyeTargetsByPlayer[player] = currentTargets
	end

	if highlightCount <= 0 or highlightDistance <= 0 then
		table.clear(currentTargets)
		return {}
	end

	local playerPosition = getPlayerPosition(player)
	if not playerPosition then
		table.clear(currentTargets)
		return {}
	end

	local focusId = if canFocusCitation then player:GetAttribute("EagleEyeFocusId") else nil
	local keptTargets = {}
	local usedTargets: { [Instance]: boolean } = {}

	for _, target in currentTargets do
		if #keptTargets >= highlightCount then
			break
		end

		if not usedTargets[target] and canHighlightViolation(playerPosition, target, highlightDistance, focusId) then
			table.insert(keptTargets, target)
			usedTargets[target] = true
		end
	end

	local candidates = {}
	for target in activeViolations do
		if not usedTargets[target] and canHighlightViolation(playerPosition, target, highlightDistance, focusId) then
			table.insert(candidates, target)
		end
	end

	while #keptTargets < highlightCount and #candidates > 0 do
		local candidateIndex = rng:NextInteger(1, #candidates)
		local target = candidates[candidateIndex]
		table.insert(keptTargets, target)
		usedTargets[target] = true
		table.remove(candidates, candidateIndex)
	end

	eagleEyeTargetsByPlayer[player] = keptTargets
	return keptTargets
end

local function isDefinitionAvailable(definition: ViolationDefinitions.ViolationDefinition, context: TimeService.TimeContext): boolean
	if definition.Availability == "Unavailable" then
		return false
	end

	if definition.Availability == "OutsideTrashWindow" then
		return not context.IsTrashWindow
	end

	return true
end

local function removePrompt(activeViolation: ActiveViolation)
	local prompt = activeViolation.Prompt
	if prompt then
		prompt:Destroy()
		activeViolation.Prompt = nil
	end
end

local function clearViolationsById(id: string)
	local toClear = {}

	for target, activeViolation in activeViolations do
		if activeViolation.Id == id then
			table.insert(toClear, activeViolation)
			activeViolations[target] = nil
		end
	end

	for _, activeViolation in toClear do
		removePrompt(activeViolation)
		activeViolation.Cleanup()
	end
end

local function resolveViolation(player: Player, activeViolation: ActiveViolation)
	if not activeViolations[activeViolation.Target] then
		return
	end

	local definition = ViolationDefinitions[activeViolation.Id]
	if not definition then
		return
	end

	activeViolations[activeViolation.Target] = nil
	removePrompt(activeViolation)
	activeViolation.Cleanup()
	PlayerStatsService.AwardCitation(player, definition.BaseReward, definition.XP)
end

local function attachDiscoveryPrompt(activeViolation: ActiveViolation)
	local definition = ViolationDefinitions[activeViolation.Id]
	local promptParent = activeViolation.PromptParent
	if not definition or not promptParent then
		return
	end

	local existingPrompt = promptParent:FindFirstChild(PROMPT_NAME)
	if existingPrompt then
		existingPrompt:Destroy()
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = PROMPT_NAME
	prompt.ActionText = "Write Citation"
	prompt.ObjectText = definition.DisplayName
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = BASE_PROMPT_ACTIVATION_DISTANCE + MAX_SIGHT_SEEING_EXTRA_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptParent
	activeViolation.Prompt = prompt

	prompt.Triggered:Connect(function(player)
		if not canPlayerReachPrompt(player, promptParent) then
			return
		end

		resolveViolation(player, activeViolation)
	end)
end

local function spawnViolation(id: string): boolean
	local definition = ViolationDefinitions[id]
	if not definition then
		return false
	end

	local handler = handlers[definition.HandlerId]
	if not handler then
		return false
	end

	local targets = handler.GetAvailableTargets()
	if #targets == 0 then
		return false
	end

	local target = targets[rng:NextInteger(1, #targets)]
	local activeViolation = handler.Create(target)
	if not activeViolation then
		return false
	end

	activeViolations[target] = activeViolation
	attachDiscoveryPrompt(activeViolation)

	print(("[ViolationService] Spawned %s on %s"):format(definition.DisplayName, target:GetFullName()))

	return true
end

local function maintainViolationQuotas()
	local context = TimeService.GetContext()

	for id, definition in ViolationDefinitions do
		if countActiveViolations() >= MAX_ACTIVE_VIOLATIONS then
			return
		end

		if definition.TargetActive > 0 and isDefinitionAvailable(definition, context) then
			local handler = handlers[definition.HandlerId]
			while handler
				and countActiveViolations() < MAX_ACTIVE_VIOLATIONS
				and countActiveViolationsById(id) < definition.TargetActive
			do
				if #handler.GetAvailableTargets() == 0 or not spawnViolation(id) then
					break
				end
			end
		end
	end
end

local function syncTrashCansForTime(context: TimeService.TimeContext, previousContext: TimeService.TimeContext?)
	local trashHandler = handlers.TrashCansOut
	if not trashHandler then
		return
	end

	local wasTrashWindow = previousContext and previousContext.IsTrashWindow or false

	if context.IsTrashWindow and not wasTrashWindow then
		clearViolationsById("TrashCansOut")

		if trashHandler.ShowAllCans then
			trashHandler.ShowAllCans()
		end
	elseif not context.IsTrashWindow and wasTrashWindow then
		if trashHandler.StoreInactiveCans then
			trashHandler.StoreInactiveCans()
		end
	end
end

function ViolationService.Start()
	local remotes = getOrCreateFolder(ReplicatedStorage, REMOTES_FOLDER_NAME)
	local getEagleEyeTargetsRemote = getOrCreateRemoteFunction(remotes, GET_EAGLE_EYE_TARGETS_REMOTE_NAME)
	local setEagleEyeFocusRemote = getOrCreateRemoteFunction(remotes, SET_EAGLE_EYE_FOCUS_REMOTE_NAME)

	getEagleEyeTargetsRemote.OnServerInvoke = function(player)
		return getActiveViolationTargets(player)
	end

	setEagleEyeFocusRemote.OnServerInvoke = function(player, violationId)
		local _, _, canFocusCitation = UpgradeService.GetEagleEyeSettings(player)
		if not canFocusCitation then
			return false, "Locked"
		end

		if typeof(violationId) ~= "string" then
			return false, "InvalidViolationId"
		end

		if violationId ~= "" and not isValidViolationId(player, violationId) then
			return false, "UnknownViolation"
		end

		player:SetAttribute("EagleEyeFocusId", violationId)
		eagleEyeTargetsByPlayer[player] = {}
		return true, "Focused"
	end

	for _, handler in handlers do
		if handler.Initialize then
			handler.Initialize()
		end
	end

	syncTrashCansForTime(TimeService.GetContext(), nil)

	TimeService.PhaseChanged:Connect(function(context: TimeService.TimeContext, previousContext: TimeService.TimeContext?)
		syncTrashCansForTime(context, previousContext)
	end)

	task.spawn(function()
		while true do
			maintainViolationQuotas()

			task.wait(RESPAWN_SECONDS)
		end
	end)

	game:GetService("Players").PlayerRemoving:Connect(function(player)
		eagleEyeTargetsByPlayer[player] = nil
	end)
end

return ViolationService
