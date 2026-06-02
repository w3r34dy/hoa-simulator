--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStatsService = require(script.Parent.PlayerStatsService)
local TimeService = require(script.Parent.TimeService)
local ViolationDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViolationDefinitions"))

local GrassTooTall = require(script.Parent.Parent.violationHandlers.GrassTooTall)
local MailboxColor = require(script.Parent.Parent.violationHandlers.MailboxColor)
local TrashCansOut = require(script.Parent.Parent.violationHandlers.TrashCansOut)

local PROMPT_NAME = "HOAInspectionPrompt"
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
	TrashCansOut = TrashCansOut,
}

local activeViolations: { [Instance]: ActiveViolation } = {}
local rng = Random.new()

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
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptParent
	activeViolation.Prompt = prompt

	prompt.Triggered:Connect(function(player)
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
end

return ViolationService
