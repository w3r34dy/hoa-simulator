--!strict

export type UpgradeCategory =
	"Camera"
	| "MotorLegs"
	| "BoardFavor"
	| "CitationGoggles"
	| "EagleEyes"
	| "ReputationBadge"
	| "PolicyHandbook"
	| "Negotiator"
	| "Economist"
	| "Gambler"
	| "GoldenFavor"
	| "SightSeeing"

export type CostCurrency = "Money" | "XP"

export type UpgradeDefinition = {
	Id: string,
	Category: UpgradeCategory,
	Tier: number,
	DisplayName: string,
	Cost: number,
	CostCurrency: CostCurrency?,
	MoneyMultiplier: number?,
	WalkSpeed: number?,
	BonusChance: number?,
	BonusMoney: number?,
	PassiveCitationAwards: number?,
	PassiveUsesBoardFavor: boolean?,
	HighlightCount: number?,
	HighlightDistance: number?,
	CanFocusCitation: boolean?,
	XPMultiplier: number?,
	PolicyUnlockCount: number?,
	NegotiatorChance: number?,
	InterestPercent: number?,
	GamblerDoubleChance: number?,
	GoldenFavorChance: number?,
	SightSeeingExtraDistance: number?,
}

local UpgradeDefinitions: { [string]: UpgradeDefinition } = {
	SimpleCamera = {
		Id = "SimpleCamera",
		Category = "Camera",
		Tier = 1,
		DisplayName = "Simple Camera",
		Cost = 125,
		MoneyMultiplier = 1.15,
	},

	ModernCamera = {
		Id = "ModernCamera",
		Category = "Camera",
		Tier = 2,
		DisplayName = "Modern Camera",
		Cost = 325,
		MoneyMultiplier = 1.35,
	},

	SuperiorCamera = {
		Id = "SuperiorCamera",
		Category = "Camera",
		Tier = 3,
		DisplayName = "Superior Camera",
		Cost = 700,
		MoneyMultiplier = 1.6,
	},

	AdelphiCamera = {
		Id = "AdelphiCamera",
		Category = "Camera",
		Tier = 4,
		DisplayName = "Adelphi Camera",
		Cost = 1250,
		MoneyMultiplier = 2,
	},

	Ultra3DCamera = {
		Id = "Ultra3DCamera",
		Category = "Camera",
		Tier = 5,
		DisplayName = "Ultra 3D Camera",
		Cost = 2200,
		MoneyMultiplier = 2.5,
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
		Cost = 180,
		BonusChance = 0.08,
		BonusMoney = 15,
	},

	CarbonCopyForms = {
		Id = "CarbonCopyForms",
		Category = "BoardFavor",
		Tier = 2,
		DisplayName = "Carbon Copy Forms",
		Cost = 450,
		BonusChance = 0.12,
		BonusMoney = 30,
	},

	PriorityFiling = {
		Id = "PriorityFiling",
		Category = "BoardFavor",
		Tier = 3,
		DisplayName = "Priority Filing",
		Cost = 900,
		BonusChance = 0.16,
		BonusMoney = 55,
	},

	BoardFavor = {
		Id = "BoardFavor",
		Category = "BoardFavor",
		Tier = 4,
		DisplayName = "Board Favor",
		Cost = 1600,
		BonusChance = 0.22,
		BonusMoney = 90,
	},

	GoldenClipboard = {
		Id = "GoldenClipboard",
		Category = "BoardFavor",
		Tier = 5,
		DisplayName = "Golden Clipboard",
		Cost = 2800,
		BonusChance = 0.3,
		BonusMoney = 140,
	},

	BudgetGoggles = {
		Id = "BudgetGoggles",
		Category = "CitationGoggles",
		Tier = 1,
		DisplayName = "Budget Goggles",
		Cost = 300,
		PassiveCitationAwards = 1,
	},

	PolarizedGoggles = {
		Id = "PolarizedGoggles",
		Category = "CitationGoggles",
		Tier = 2,
		DisplayName = "Polarized Goggles",
		Cost = 700,
		PassiveCitationAwards = 2,
	},

	BylawGoggles = {
		Id = "BylawGoggles",
		Category = "CitationGoggles",
		Tier = 3,
		DisplayName = "Bylaw Goggles",
		Cost = 1400,
		PassiveCitationAwards = 3,
	},

	InspectorGoggles = {
		Id = "InspectorGoggles",
		Category = "CitationGoggles",
		Tier = 4,
		DisplayName = "Inspector Goggles",
		Cost = 2400,
		PassiveCitationAwards = 4,
	},

	CitationGoggles = {
		Id = "CitationGoggles",
		Category = "CitationGoggles",
		Tier = 5,
		DisplayName = "Citation Goggles",
		Cost = 3900,
		PassiveCitationAwards = 5,
		PassiveUsesBoardFavor = true,
	},

	SharpEyes = {
		Id = "SharpEyes",
		Category = "EagleEyes",
		Tier = 1,
		DisplayName = "Sharp Eyes",
		Cost = 400,
		HighlightCount = 1,
		HighlightDistance = 120,
	},

	LongView = {
		Id = "LongView",
		Category = "EagleEyes",
		Tier = 2,
		DisplayName = "Long View",
		Cost = 900,
		HighlightCount = 2,
		HighlightDistance = 160,
	},

	MapScanner = {
		Id = "MapScanner",
		Category = "EagleEyes",
		Tier = 3,
		DisplayName = "Map Scanner",
		Cost = 1800,
		HighlightCount = 3,
		HighlightDistance = 220,
	},

	PatrolVision = {
		Id = "PatrolVision",
		Category = "EagleEyes",
		Tier = 4,
		DisplayName = "Patrol Vision",
		Cost = 3000,
		HighlightCount = 4,
		HighlightDistance = 300,
	},

	EagleEyes = {
		Id = "EagleEyes",
		Category = "EagleEyes",
		Tier = 5,
		DisplayName = "Eagle Eyes",
		Cost = 4800,
		HighlightCount = 4,
		HighlightDistance = 360,
		CanFocusCitation = true,
	},

	VisitorBadge = {
		Id = "VisitorBadge",
		Category = "ReputationBadge",
		Tier = 1,
		DisplayName = "Visitor Badge",
		Cost = 250,
		XPMultiplier = 1.2,
	},

	ResidentBadge = {
		Id = "ResidentBadge",
		Category = "ReputationBadge",
		Tier = 2,
		DisplayName = "Resident Badge",
		Cost = 650,
		XPMultiplier = 1.45,
	},

	CommitteeBadge = {
		Id = "CommitteeBadge",
		Category = "ReputationBadge",
		Tier = 3,
		DisplayName = "Committee Badge",
		Cost = 1300,
		XPMultiplier = 1.75,
	},

	BoardMemberBadge = {
		Id = "BoardMemberBadge",
		Category = "ReputationBadge",
		Tier = 4,
		DisplayName = "Board Member Badge",
		Cost = 2400,
		XPMultiplier = 2.1,
	},

	ReputationBadge = {
		Id = "ReputationBadge",
		Category = "ReputationBadge",
		Tier = 5,
		DisplayName = "Reputation Badge",
		Cost = 4000,
		XPMultiplier = 2.5,
	},

	PolicyHandbookI = {
		Id = "PolicyHandbookI",
		Category = "PolicyHandbook",
		Tier = 1,
		DisplayName = "Policy Handbook I",
		Cost = 80,
		CostCurrency = "XP",
		PolicyUnlockCount = 3,
	},

	PolicyHandbookII = {
		Id = "PolicyHandbookII",
		Category = "PolicyHandbook",
		Tier = 2,
		DisplayName = "Policy Handbook II",
		Cost = 190,
		CostCurrency = "XP",
		PolicyUnlockCount = 6,
	},

	PolicyHandbookIII = {
		Id = "PolicyHandbookIII",
		Category = "PolicyHandbook",
		Tier = 3,
		DisplayName = "Policy Handbook III",
		Cost = 360,
		CostCurrency = "XP",
		PolicyUnlockCount = 9,
	},

	PolicyHandbookIV = {
		Id = "PolicyHandbookIV",
		Category = "PolicyHandbook",
		Tier = 4,
		DisplayName = "Policy Handbook IV",
		Cost = 620,
		CostCurrency = "XP",
		PolicyUnlockCount = 12,
	},

	PolicyHandbookV = {
		Id = "PolicyHandbookV",
		Category = "PolicyHandbook",
		Tier = 5,
		DisplayName = "Policy Handbook V",
		Cost = 950,
		CostCurrency = "XP",
		PolicyUnlockCount = 15,
	},

	PersuasionNotes = {
		Id = "PersuasionNotes",
		Category = "Negotiator",
		Tier = 1,
		DisplayName = "Persuasion Notes",
		Cost = 120,
		CostCurrency = "XP",
		NegotiatorChance = 0.02,
	},

	CounterofferScript = {
		Id = "CounterofferScript",
		Category = "Negotiator",
		Tier = 2,
		DisplayName = "Counteroffer Script",
		Cost = 260,
		CostCurrency = "XP",
		NegotiatorChance = 0.035,
	},

	HearingPrep = {
		Id = "HearingPrep",
		Category = "Negotiator",
		Tier = 3,
		DisplayName = "Hearing Prep",
		Cost = 480,
		CostCurrency = "XP",
		NegotiatorChance = 0.05,
	},

	SettlementTactics = {
		Id = "SettlementTactics",
		Category = "Negotiator",
		Tier = 4,
		DisplayName = "Settlement Tactics",
		Cost = 780,
		CostCurrency = "XP",
		NegotiatorChance = 0.07,
	},

	Negotiator = {
		Id = "Negotiator",
		Category = "Negotiator",
		Tier = 5,
		DisplayName = "Negotiator",
		Cost = 1200,
		CostCurrency = "XP",
		NegotiatorChance = 0.1,
	},

	CouponLedger = {
		Id = "CouponLedger",
		Category = "Economist",
		Tier = 1,
		DisplayName = "Coupon Ledger",
		Cost = 100,
		CostCurrency = "XP",
		InterestPercent = 0.005,
	},

	ReserveFund = {
		Id = "ReserveFund",
		Category = "Economist",
		Tier = 2,
		DisplayName = "Reserve Fund",
		Cost = 230,
		CostCurrency = "XP",
		InterestPercent = 0.008,
	},

	BudgetReview = {
		Id = "BudgetReview",
		Category = "Economist",
		Tier = 3,
		DisplayName = "Budget Review",
		Cost = 430,
		CostCurrency = "XP",
		InterestPercent = 0.012,
	},

	CompoundDues = {
		Id = "CompoundDues",
		Category = "Economist",
		Tier = 4,
		DisplayName = "Compound Dues",
		Cost = 700,
		CostCurrency = "XP",
		InterestPercent = 0.017,
	},

	Economist = {
		Id = "Economist",
		Category = "Economist",
		Tier = 5,
		DisplayName = "Economist",
		Cost = 1050,
		CostCurrency = "XP",
		InterestPercent = 0.025,
	},

	LooseOdds = {
		Id = "LooseOdds",
		Category = "Gambler",
		Tier = 1,
		DisplayName = "Loose Odds",
		Cost = 90,
		CostCurrency = "XP",
		GamblerDoubleChance = 0.08,
	},

	SideBet = {
		Id = "SideBet",
		Category = "Gambler",
		Tier = 2,
		DisplayName = "Side Bet",
		Cost = 220,
		CostCurrency = "XP",
		GamblerDoubleChance = 0.11,
	},

	RiskForm = {
		Id = "RiskForm",
		Category = "Gambler",
		Tier = 3,
		DisplayName = "Risk Form",
		Cost = 420,
		CostCurrency = "XP",
		GamblerDoubleChance = 0.14,
	},

	LongShotLedger = {
		Id = "LongShotLedger",
		Category = "Gambler",
		Tier = 4,
		DisplayName = "Long Shot Ledger",
		Cost = 680,
		CostCurrency = "XP",
		GamblerDoubleChance = 0.17,
	},

	Gambler = {
		Id = "Gambler",
		Category = "Gambler",
		Tier = 5,
		DisplayName = "Gambler",
		Cost = 1000,
		CostCurrency = "XP",
		GamblerDoubleChance = 0.2,
	},

	BronzeFavor = {
		Id = "BronzeFavor",
		Category = "GoldenFavor",
		Tier = 1,
		DisplayName = "Bronze Favor",
		Cost = 130,
		CostCurrency = "XP",
		GoldenFavorChance = 0.01,
	},

	SilverFavor = {
		Id = "SilverFavor",
		Category = "GoldenFavor",
		Tier = 2,
		DisplayName = "Silver Favor",
		Cost = 300,
		CostCurrency = "XP",
		GoldenFavorChance = 0.018,
	},

	PlatinumFavor = {
		Id = "PlatinumFavor",
		Category = "GoldenFavor",
		Tier = 3,
		DisplayName = "Platinum Favor",
		Cost = 560,
		CostCurrency = "XP",
		GoldenFavorChance = 0.026,
	},

	DiamondFavor = {
		Id = "DiamondFavor",
		Category = "GoldenFavor",
		Tier = 4,
		DisplayName = "Diamond Favor",
		Cost = 880,
		CostCurrency = "XP",
		GoldenFavorChance = 0.036,
	},

	GoldenFavor = {
		Id = "GoldenFavor",
		Category = "GoldenFavor",
		Tier = 5,
		DisplayName = "Golden Favor",
		Cost = 1300,
		CostCurrency = "XP",
		GoldenFavorChance = 0.05,
	},

	CurbCheck = {
		Id = "CurbCheck",
		Category = "SightSeeing",
		Tier = 1,
		DisplayName = "Curb Check",
		Cost = 70,
		CostCurrency = "XP",
		SightSeeingExtraDistance = 3,
	},

	BinocularBasics = {
		Id = "BinocularBasics",
		Category = "SightSeeing",
		Tier = 2,
		DisplayName = "Binocular Basics",
		Cost = 170,
		CostCurrency = "XP",
		SightSeeingExtraDistance = 6,
	},

	StreetSurvey = {
		Id = "StreetSurvey",
		Category = "SightSeeing",
		Tier = 3,
		DisplayName = "Street Survey",
		Cost = 340,
		CostCurrency = "XP",
		SightSeeingExtraDistance = 9,
	},

	PorchView = {
		Id = "PorchView",
		Category = "SightSeeing",
		Tier = 4,
		DisplayName = "Porch View",
		Cost = 580,
		CostCurrency = "XP",
		SightSeeingExtraDistance = 12,
	},

	SightSeeing = {
		Id = "SightSeeing",
		Category = "SightSeeing",
		Tier = 5,
		DisplayName = "Sight Seeing",
		Cost = 900,
		CostCurrency = "XP",
		SightSeeingExtraDistance = 16,
	},
}

return UpgradeDefinitions
