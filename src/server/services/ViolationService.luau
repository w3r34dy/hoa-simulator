--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStatsService = require(script.Parent.PlayerStatsService)
local ViolationDefinitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViolationDefinitions"))

local MailboxColor = require(script.Parent.Parent.violationHandlers.MailboxColor)

local PROMPT_NAME = "HOAInspectionPrompt"
local RESPAWN_SECONDS = 12
local MAX_ACTIVE_VIOLATIONS = 4

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
}

local ViolationService = {}

local handlers: { [string]: ViolationHandler } = {
	MailboxColor = MailboxColor,
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

local function getSpawnableViolationIds(): { string }
	local ids = {}

	for id, definition in ViolationDefinitions do
		local handler = handlers[definition.HandlerId]
		if handler and #handler.GetAvailableTargets() > 0 then
			table.insert(ids, id)
		end
	end

	return ids
end

local function shouldSpawnViolation(): boolean
	return countActiveViolations() < MAX_ACTIVE_VIOLATIONS and #getSpawnableViolationIds() > 0
end

local function removePrompt(activeViolation: ActiveViolation)
	local prompt = activeViolation.Prompt
	if prompt then
		prompt:Destroy()
		activeViolation.Prompt = nil
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

local function spawnRandomViolation()
	local ids = getSpawnableViolationIds()
	if #ids == 0 then
		return
	end

	local id = ids[rng:NextInteger(1, #ids)]
	spawnViolation(id)
end

function ViolationService.Start()
	for _, handler in handlers do
		if handler.Initialize then
			handler.Initialize()
		end
	end

	task.spawn(function()
		while true do
			if shouldSpawnViolation() then
				spawnRandomViolation()
			end

			task.wait(RESPAWN_SECONDS)
		end
	end)
end

return ViolationService
