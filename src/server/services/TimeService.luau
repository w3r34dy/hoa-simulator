--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type DayName = "Sunday" | "Monday" | "Tuesday" | "Wednesday" | "Thursday" | "Friday" | "Saturday"
export type DayPhase = "Morning" | "Afternoon" | "Evening" | "Night"

export type TimeContext = {
	Day: DayName,
	DayIndex: number,
	Phase: DayPhase,
	PhaseIndex: number,
	IsTrashWindow: boolean,
}

local SECONDS_PER_DAY = 5 * 60
local PHASES_PER_DAY = 4
local SECONDS_PER_PHASE = SECONDS_PER_DAY / PHASES_PER_DAY

local DAYS: { DayName } = {
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
}

local PHASES: { DayPhase } = {
	"Morning",
	"Afternoon",
	"Evening",
	"Night",
}

local PHASE_CLOCK_TIMES = {
	Morning = 8,
	Afternoon = 14,
	Evening = 18,
	Night = 22,
}

local TRASH_WINDOW_START_DAY_INDEX = 3 -- Tuesday
local TRASH_WINDOW_START_PHASE_INDEX = 3 -- Evening
local TRASH_WINDOW_END_DAY_INDEX = 5 -- Thursday
local TRASH_WINDOW_END_PHASE_INDEX = 2 -- Afternoon

local TimeService = {}

local phaseChangedEvent = Instance.new("BindableEvent")
local startedAt = os.clock()
local lastContext: TimeContext? = nil
local timeStateFolder: Folder? = nil
local dayValue: StringValue? = nil
local phaseValue: StringValue? = nil
local trashWindowValue: BoolValue? = nil

TimeService.PhaseChanged = phaseChangedEvent.Event

local function getOrCreateValue<T>(parent: Instance, className: string, name: string): T
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing :: any
	end

	if existing then
		existing:Destroy()
	end

	local value = Instance.new(className)
	value.Name = name
	value.Parent = parent

	return value :: any
end

local function setupReplicatedState()
	local shared = ReplicatedStorage:WaitForChild("Shared")
	local folder = shared:FindFirstChild("TimeState")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "TimeState"
		folder.Parent = shared
	end

	timeStateFolder = folder :: Folder
	dayValue = getOrCreateValue(timeStateFolder, "StringValue", "Day")
	phaseValue = getOrCreateValue(timeStateFolder, "StringValue", "Phase")
	trashWindowValue = getOrCreateValue(timeStateFolder, "BoolValue", "IsTrashWindow")
end

local function updateReplicatedState(context: TimeContext)
	if not dayValue or not phaseValue or not trashWindowValue then
		return
	end

	dayValue.Value = context.Day
	phaseValue.Value = context.Phase
	trashWindowValue.Value = context.IsTrashWindow
end

local function getWeekPhaseIndex(dayIndex: number, phaseIndex: number): number
	return ((dayIndex - 1) * PHASES_PER_DAY) + phaseIndex
end

local function isWithinTrashWindow(dayIndex: number, phaseIndex: number): boolean
	local current = getWeekPhaseIndex(dayIndex, phaseIndex)
	local start = getWeekPhaseIndex(TRASH_WINDOW_START_DAY_INDEX, TRASH_WINDOW_START_PHASE_INDEX)
	local finish = getWeekPhaseIndex(TRASH_WINDOW_END_DAY_INDEX, TRASH_WINDOW_END_PHASE_INDEX)

	return current >= start and current < finish
end

function TimeService.GetContext(): TimeContext
	local elapsed = os.clock() - startedAt
	local dayOffset = math.floor(elapsed / SECONDS_PER_DAY) % #DAYS
	local secondsIntoDay = elapsed % SECONDS_PER_DAY
	local phaseIndex = math.floor(secondsIntoDay / SECONDS_PER_PHASE) + 1
	local dayIndex = dayOffset + 1

	return {
		Day = DAYS[dayIndex],
		DayIndex = dayIndex,
		Phase = PHASES[phaseIndex],
		PhaseIndex = phaseIndex,
		IsTrashWindow = isWithinTrashWindow(dayIndex, phaseIndex),
	}
end

function TimeService.Start()
	setupReplicatedState()

	lastContext = TimeService.GetContext()
	updateReplicatedState(lastContext)
	Lighting.ClockTime = PHASE_CLOCK_TIMES[lastContext.Phase]

	task.spawn(function()
		while true do
			local context = TimeService.GetContext()
			local previous = lastContext

			if not previous or previous.Day ~= context.Day or previous.Phase ~= context.Phase then
				lastContext = context
				updateReplicatedState(context)
				Lighting.ClockTime = PHASE_CLOCK_TIMES[context.Phase]
				phaseChangedEvent:Fire(context, previous)
				print(("[TimeService] %s %s"):format(context.Day, context.Phase))
			end

			task.wait(1)
		end
	end)
end

return TimeService
