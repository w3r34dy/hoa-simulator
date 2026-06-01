--!strict

local Workspace = game:GetService("Workspace")

local TARGET_ATTRIBUTE = "HOAGrassTarget"
local ACTIVE_ATTRIBUTE = "HOAActiveViolation"
local HEIGHT_MULTIPLIER = 2
local VIOLATION_COLOR = Color3.fromRGB(65, 145, 58)

export type ActiveViolation = {
	Id: string,
	Target: Instance,
	PromptParent: BasePart?,
	Cleanup: () -> (),
}

local GrassTooTall = {}

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

local function isAvailable(target: Instance): boolean
	return target.Parent ~= nil
		and target:GetAttribute(TARGET_ATTRIBUTE) == true
		and target:GetAttribute(ACTIVE_ATTRIBUTE) == nil
		and #getParts(target) > 0
end

function GrassTooTall.GetAvailableTargets(): { Instance }
	local targets = {}

	for _, descendant in Workspace:GetDescendants() do
		if (descendant:IsA("BasePart") or descendant:IsA("Model")) and isAvailable(descendant) then
			table.insert(targets, descendant)
		end
	end

	return targets
end

function GrassTooTall.Create(target: Instance): ActiveViolation?
	if not isAvailable(target) then
		return nil
	end

	local originalStates = {}
	local parts = getParts(target)

	for _, part in parts do
		originalStates[part] = {
			Size = part.Size,
			CFrame = part.CFrame,
			Color = part.Color,
		}

		local addedHeight = part.Size.Y * (HEIGHT_MULTIPLIER - 1)
		part.Size = Vector3.new(part.Size.X, part.Size.Y * HEIGHT_MULTIPLIER, part.Size.Z)
		part.CFrame += Vector3.new(0, addedHeight / 2, 0)
		part.Color = VIOLATION_COLOR
	end

	target:SetAttribute(ACTIVE_ATTRIBUTE, "GrassTooTall")

	return {
		Id = "GrassTooTall",
		Target = target,
		PromptParent = getPromptParent(target),
		Cleanup = function()
			for part, state in originalStates do
				if part.Parent then
					part.Size = state.Size
					part.CFrame = state.CFrame
					part.Color = state.Color
				end
			end

			if target.Parent then
				target:SetAttribute(ACTIVE_ATTRIBUTE, nil)
			end
		end,
	}
end

return GrassTooTall
