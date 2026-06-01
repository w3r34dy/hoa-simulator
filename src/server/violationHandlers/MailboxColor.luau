--!strict

local Workspace = game:GetService("Workspace")

local MAILBOX_ATTRIBUTE = "HOAMailbox"
local COLOR_PART_ATTRIBUTE = "HOAMailboxColorPart"
local ACTIVE_ATTRIBUTE = "HOAActiveViolation"
local CURRENT_COLOR_ATTRIBUTE = "HOAMailboxColor"

local VIOLATION_ID = "WrongMailboxColor"

type MailboxColor = {
	Name: string,
	Color: Color3,
	IsAllowed: boolean,
}

export type ActiveViolation = {
	Id: string,
	Target: Instance,
	PromptParent: BasePart?,
	Cleanup: () -> (),
}

local MailboxColor = {}

local rng = Random.new()

local palette: { MailboxColor } = {
	{
		Name = "Black",
		Color = Color3.fromRGB(20, 20, 20),
		IsAllowed = true,
	},
	{
		Name = "White",
		Color = Color3.fromRGB(235, 235, 235),
		IsAllowed = true,
	},
	{
		Name = "Gray",
		Color = Color3.fromRGB(130, 130, 130),
		IsAllowed = true,
	},
	{
		Name = "Green",
		Color = Color3.fromRGB(44, 110, 73),
		IsAllowed = true,
	},
	{
		Name = "Blue",
		Color = Color3.fromRGB(0, 85, 255),
		IsAllowed = false,
	},
}

local function getRandomColor(allowed: boolean): MailboxColor
	local matches = {}

	for _, mailboxColor in palette do
		if mailboxColor.IsAllowed == allowed then
			table.insert(matches, mailboxColor)
		end
	end

	return matches[rng:NextInteger(1, #matches)]
end

local function getMailboxColorParts(mailbox: Instance): { BasePart }
	local parts = {}

	for _, descendant in mailbox:GetDescendants() do
		if descendant:IsA("BasePart") and descendant:GetAttribute(COLOR_PART_ATTRIBUTE) == true then
			table.insert(parts, descendant)
		end
	end

	return parts
end

local function getPromptParent(mailbox: Instance): BasePart?
	local colorParts = getMailboxColorParts(mailbox)
	if colorParts[1] then
		return colorParts[1]
	end

	for _, descendant in mailbox:GetDescendants() do
		if descendant:IsA("BasePart") then
			return descendant
		end
	end

	return nil
end

local function isMailbox(instance: Instance): boolean
	return instance:IsA("Model") and instance:GetAttribute(MAILBOX_ATTRIBUTE) == true
end

local function isAvailable(mailbox: Instance): boolean
	if not isMailbox(mailbox) then
		return false
	end

	if mailbox:GetAttribute(ACTIVE_ATTRIBUTE) ~= nil then
		return false
	end

	return #getMailboxColorParts(mailbox) > 0
end

local function applyMailboxColor(mailbox: Instance, mailboxColor: MailboxColor)
	for _, part in getMailboxColorParts(mailbox) do
		part.Color = mailboxColor.Color
	end

	mailbox:SetAttribute(CURRENT_COLOR_ATTRIBUTE, mailboxColor.Name)
end

function MailboxColor.Initialize()
	for _, descendant in Workspace:GetDescendants() do
		if isAvailable(descendant) and descendant:GetAttribute(CURRENT_COLOR_ATTRIBUTE) == nil then
			applyMailboxColor(descendant, getRandomColor(true))
		end
	end
end

function MailboxColor.GetAvailableTargets(): { Instance }
	local targets = {}

	for _, descendant in Workspace:GetDescendants() do
		if isAvailable(descendant) then
			table.insert(targets, descendant)
		end
	end

	return targets
end

function MailboxColor.Create(mailbox: Instance): ActiveViolation?
	if not isAvailable(mailbox) then
		return nil
	end

	local violationColor = getRandomColor(false)
	local repaintColor = getRandomColor(true)

	applyMailboxColor(mailbox, violationColor)
	mailbox:SetAttribute(ACTIVE_ATTRIBUTE, VIOLATION_ID)

	return {
		Id = VIOLATION_ID,
		Target = mailbox,
		PromptParent = getPromptParent(mailbox),
		Cleanup = function()
			if mailbox.Parent then
				applyMailboxColor(mailbox, repaintColor)
				mailbox:SetAttribute(ACTIVE_ATTRIBUTE, nil)
			end
		end,
	}
end

return MailboxColor
