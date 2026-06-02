--!strict

local Workspace = game:GetService("Workspace")

local TRASH_CAN_ATTRIBUTE = "HOATrashCan"
local ACTIVE_ATTRIBUTE = "HOAActiveViolation"
local VIOLATION_ID = "TrashCansOut"

export type ActiveViolation = {
	Id: string,
	Target: Instance,
	PromptParent: BasePart?,
	Cleanup: () -> (),
}

local TrashCansOut = {}

local function isTrashCan(instance: Instance): boolean
	return (instance:IsA("Model") or instance:IsA("BasePart")) and instance:GetAttribute(TRASH_CAN_ATTRIBUTE) == true
end

local function getParts(target: Instance): { BasePart }
	if target:IsA("BasePart") then
		return { target }
	end

	local parts = {}
	for _, descendant in target:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end

	return parts
end

local function getPromptParent(target: Instance): BasePart?
	if target:IsA("BasePart") then
		return target
	end

	for _, descendant in target:GetDescendants() do
		if descendant:IsA("BasePart") then
			return descendant
		end
	end

	return nil
end

local function setVisible(target: Instance, visible: boolean)
	for _, part in getParts(target) do
		part.Transparency = if visible then 0 else 1
		part.CanCollide = visible
		part.CanTouch = visible
		part.CanQuery = visible
	end

	target:SetAttribute("HOATrashCanVisible", visible)
end

local function isAvailable(target: Instance): boolean
	return target.Parent ~= nil
		and isTrashCan(target)
		and target:GetAttribute(ACTIVE_ATTRIBUTE) == nil
		and #getParts(target) > 0
end

function TrashCansOut.ShowAllCans()
	for _, descendant in Workspace:GetDescendants() do
		if isTrashCan(descendant) then
			setVisible(descendant, true)
		end
	end
end

function TrashCansOut.StoreInactiveCans()
	for _, descendant in Workspace:GetDescendants() do
		if isTrashCan(descendant) and descendant:GetAttribute(ACTIVE_ATTRIBUTE) == nil then
			setVisible(descendant, false)
		end
	end
end

function TrashCansOut.Initialize()
	TrashCansOut.StoreInactiveCans()
end

function TrashCansOut.GetAvailableTargets(): { Instance }
	local targets = {}

	for _, descendant in Workspace:GetDescendants() do
		if isAvailable(descendant) then
			table.insert(targets, descendant)
		end
	end

	return targets
end

function TrashCansOut.Create(target: Instance): ActiveViolation?
	if not isAvailable(target) then
		return nil
	end

	setVisible(target, true)
	target:SetAttribute(ACTIVE_ATTRIBUTE, VIOLATION_ID)

	return {
		Id = VIOLATION_ID,
		Target = target,
		PromptParent = getPromptParent(target),
		Cleanup = function()
			if target.Parent then
				target:SetAttribute(ACTIVE_ATTRIBUTE, nil)
				setVisible(target, false)
			end
		end,
	}
end

return TrashCansOut
