--!strict

local Workspace = game:GetService("Workspace")

local ACTIVE_ATTRIBUTE = "HOAActiveViolation"
local VIOLATION_ID = "ParkingOnLawn"
local VIOLATION_CAR_NAME = "2021 Koenigsegg Jesko // Rosh"
local NORMAL_CAR_NAME = "2021 Koenigsegg Jesko // Rosh1"
local originalTransparency: { [BasePart]: number } = {}

export type ActiveViolation = {
	Id: string,
	Target: Instance,
	PromptParent: BasePart?,
	Cleanup: () -> (),
}

local ParkingOnLawn = {}

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
		if originalTransparency[part] == nil then
			originalTransparency[part] = part.Transparency
		end

		part.Transparency = if visible then originalTransparency[part] else 1
	end
end

local function getNormalCar(): Instance?
	return Workspace:FindFirstChild(NORMAL_CAR_NAME, true)
end

local function getViolationCar(): Instance?
	return Workspace:FindFirstChild(VIOLATION_CAR_NAME, true)
end

local function isAvailable(target: Instance): boolean
	local normalCar = getNormalCar()

	return target == getViolationCar()
		and normalCar ~= nil
		and target:GetAttribute(ACTIVE_ATTRIBUTE) == nil
		and normalCar:GetAttribute(ACTIVE_ATTRIBUTE) == nil
		and #getParts(target) > 0
end

function ParkingOnLawn.Initialize()
	local normalCar = getNormalCar()
	local violationCar = getViolationCar()

	if normalCar then
		setVisible(normalCar, true)
		normalCar:SetAttribute(ACTIVE_ATTRIBUTE, nil)
	end

	if violationCar then
		setVisible(violationCar, false)
		violationCar:SetAttribute(ACTIVE_ATTRIBUTE, nil)
	end
end

function ParkingOnLawn.GetAvailableTargets(): { Instance }
	local violationCar = getViolationCar()

	if violationCar and isAvailable(violationCar) then
		return { violationCar }
	end

	return {}
end

function ParkingOnLawn.Create(target: Instance): ActiveViolation?
	if not isAvailable(target) then
		return nil
	end

	local normalCar = getNormalCar()
	if not normalCar then
		return nil
	end

	setVisible(normalCar, false)
	setVisible(target, true)
	normalCar:SetAttribute(ACTIVE_ATTRIBUTE, VIOLATION_ID)
	target:SetAttribute(ACTIVE_ATTRIBUTE, VIOLATION_ID)

	return {
		Id = VIOLATION_ID,
		Target = target,
		PromptParent = getPromptParent(target),
		Cleanup = function()
			if normalCar.Parent then
				setVisible(normalCar, true)
				normalCar:SetAttribute(ACTIVE_ATTRIBUTE, nil)
			end

			if target.Parent then
				setVisible(target, false)
				target:SetAttribute(ACTIVE_ATTRIBUTE, nil)
			end
		end,
	}
end

return ParkingOnLawn
