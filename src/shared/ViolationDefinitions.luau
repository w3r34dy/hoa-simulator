--!strict

export type ViolationDefinition = {
	Id: string,
	DisplayName: string,
	PolicyText: string,
	BaseReward: number,
	XP: number,
	HandlerId: string,
}

local ViolationDefinitions: { [string]: ViolationDefinition } = {
	GrassTooTall = {
		Id = "GrassTooTall",
		DisplayName = "Grass Too Tall",
		PolicyText = "Lawns must be kept neatly trimmed and below the approved HOA height.",
		BaseReward = 25,
		XP = 10,
		HandlerId = "GrassTooTall",
	},

	TrashCansOut = {
		Id = "TrashCansOut",
		DisplayName = "Trash Cans Left Out",
		PolicyText = "Trash cans must be stored out of street view outside approved pickup hours.",
		BaseReward = 20,
		XP = 8,
		HandlerId = "TrashCansOut",
	},

	WrongMailboxColor = {
		Id = "WrongMailboxColor",
		DisplayName = "Wrong Mailbox Color",
		PolicyText = "Mailboxes must use one of the approved HOA colors. Blue mailboxes are currently banned.",
		BaseReward = 30,
		XP = 12,
		HandlerId = "MailboxColor",
	},

	UnauthorizedDecorations = {
		Id = "UnauthorizedDecorations",
		DisplayName = "Unauthorized Decorations",
		PolicyText = "Exterior decorations must follow approved seasonal and architectural guidelines.",
		BaseReward = 35,
		XP = 14,
		HandlerId = "UnauthorizedDecorations",
	},

	UnapprovedShed = {
		Id = "UnapprovedShed",
		DisplayName = "Unapproved Shed",
		PolicyText = "Detached structures require architectural review approval before installation.",
		BaseReward = 50,
		XP = 20,
		HandlerId = "UnapprovedShed",
	},

	ParkingViolation = {
		Id = "ParkingViolation",
		DisplayName = "Parking Violation",
		PolicyText = "Vehicles must be parked in approved locations and may not block sidewalks or lawns.",
		BaseReward = 40,
		XP = 16,
		HandlerId = "ParkingViolation",
	},

	PoliticalSign = {
		Id = "PoliticalSign",
		DisplayName = "Restricted Political Sign",
		PolicyText = "Political signs must follow HOA placement, size, and timing restrictions.",
		BaseReward = 30,
		XP = 12,
		HandlerId = "PoliticalSign",
	},

	HolidayDecorationsExpired = {
		Id = "HolidayDecorationsExpired",
		DisplayName = "Expired Holiday Decorations",
		PolicyText = "Holiday decorations must be removed after the approved display window.",
		BaseReward = 35,
		XP = 14,
		HandlerId = "HolidayDecorationsExpired",
	},
}

return ViolationDefinitions
