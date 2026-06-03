--!strict

export type UpgradeCategory = "Camera" | "MotorLegs" | "BoardFavor"

export type UpgradeDefinition = {
	Id: string,
	Category: UpgradeCategory,
	Tier: number,
	DisplayName: string,
	Cost: number,
	MoneyMultiplier: number?,
	WalkSpeed: number?,
	BonusChance: number?,
	BonusMoney: number?,
}

local UpgradeDefinitions: { [string]: UpgradeDefinition } = {
	SimpleCamera = {
		Id = "SimpleCamera",
		Category = "Camera",
		Tier = 1,
		DisplayName = "Simple Camera",
		Cost = 100,
		MoneyMultiplier = 1.1,
	},

	ModernCamera = {
		Id = "ModernCamera",
		Category = "Camera",
		Tier = 2,
		DisplayName = "Modern Camera",
		Cost = 250,
		MoneyMultiplier = 1.2,
	},

	SuperiorCamera = {
		Id = "SuperiorCamera",
		Category = "Camera",
		Tier = 3,
		DisplayName = "Superior Camera",
		Cost = 500,
		MoneyMultiplier = 1.35,
	},

	AdelphiCamera = {
		Id = "AdelphiCamera",
		Category = "Camera",
		Tier = 4,
		DisplayName = "Adelphi Camera",
		Cost = 900,
		MoneyMultiplier = 1.55,
	},

	Ultra3DCamera = {
		Id = "Ultra3DCamera",
		Category = "Camera",
		Tier = 5,
		DisplayName = "Ultra 3D Camera",
		Cost = 1500,
		MoneyMultiplier = 1.8,
	},

	AssistLegs = {
		Id = "AssistLegs",
		Category = "MotorLegs",
		Tier = 1,
		DisplayName = "Assist Legs",
		Cost = 120,
		WalkSpeed = 18,
	},

	PatrolLegs = {
		Id = "PatrolLegs",
		Category = "MotorLegs",
		Tier = 2,
		DisplayName = "Patrol Legs",
		Cost = 300,
		WalkSpeed = 20,
	},

	CodeEnforcerLegs = {
		Id = "CodeEnforcerLegs",
		Category = "MotorLegs",
		Tier = 3,
		DisplayName = "Code Enforcer Legs",
		Cost = 650,
		WalkSpeed = 23,
	},

	BoardApprovedLegs = {
		Id = "BoardApprovedLegs",
		Category = "MotorLegs",
		Tier = 4,
		DisplayName = "Board Approved Legs",
		Cost = 1100,
		WalkSpeed = 26,
	},

	TurboBylawLegs = {
		Id = "TurboBylawLegs",
		Category = "MotorLegs",
		Tier = 5,
		DisplayName = "Turbo Bylaw Legs",
		Cost = 1800,
		WalkSpeed = 30,
	},

	LuckyPen = {
		Id = "LuckyPen",
		Category = "BoardFavor",
		Tier = 1,
		DisplayName = "Lucky Pen",
		Cost = 150,
		BonusChance = 0.08,
		BonusMoney = 10,
	},

	CarbonCopyForms = {
		Id = "CarbonCopyForms",
		Category = "BoardFavor",
		Tier = 2,
		DisplayName = "Carbon Copy Forms",
		Cost = 350,
		BonusChance = 0.12,
		BonusMoney = 18,
	},

	PriorityFiling = {
		Id = "PriorityFiling",
		Category = "BoardFavor",
		Tier = 3,
		DisplayName = "Priority Filing",
		Cost = 750,
		BonusChance = 0.16,
		BonusMoney = 30,
	},

	BoardFavor = {
		Id = "BoardFavor",
		Category = "BoardFavor",
		Tier = 4,
		DisplayName = "Board Favor",
		Cost = 1250,
		BonusChance = 0.22,
		BonusMoney = 45,
	},

	GoldenClipboard = {
		Id = "GoldenClipboard",
		Category = "BoardFavor",
		Tier = 5,
		DisplayName = "Golden Clipboard",
		Cost = 2000,
		BonusChance = 0.3,
		BonusMoney = 70,
	},
}

return UpgradeDefinitions
