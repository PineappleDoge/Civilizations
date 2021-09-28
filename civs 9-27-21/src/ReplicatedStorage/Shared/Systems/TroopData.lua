local troopDataModule = {}

local troopData = {
	Warrior = {
		Description = "A trained villager ready for war!",
		PreferredTarget = "Any",
		AttackType = "Melee",
		AttackSpeed = 1,
		MovementSpeed = 15,
		Houseing_Space = 1,
		Barracks_Level_Required = 1,
		CostType = "Currency",
		Levels = {
			_1 = {DMG = 8, HP = 45, Range = 0, Training_Cost = 15},
			_2 = {DMG = 11, HP = 54, Range = 0, Training_Cost = 30},
			_3 = {DMG = 14, HP = 65, Range = 0, Training_Cost = 60},
			_4 = {DMG = 18, HP = 78, Range = 0, Training_Cost = 100},
			_5 = {DMG = 23, HP = 95, Range = 0, Training_Cost = 150},
			_6 = {DMG = 26, HP = 110, Range = 0, Training_Cost = 200},
			_7 = {DMG = 30, HP = 145, Range = 0, Training_Cost = 250},
			_8 = {DMG = 34, HP = 205, Range = 0, Training_Cost = 300},
		}
	},
	
	Archeress = {
		Description = "Hooded villager with serious archery skills!",
		PreferredTarget = "Any",
		AttackType = "Ranged",
		AttackSpeed = 1,
		MovementSpeed = 15,
		Houseing_Space = 1,
		Barracks_Level_Required = 2,
		CostType = "Currency",
		Levels = {
			_1 = {DMG = 7, HP = 20, Range = 4, Training_Cost = 30},
			_2 = {DMG = 9, HP = 23, Range = 4, Training_Cost = 60},
			_3 = {DMG = 12, HP = 28, Range = 4, Training_Cost = 120},
			_4 = {DMG = 16, HP = 33, Range = 4, Training_Cost = 200},
			_5 = {DMG = 20, HP = 40, Range = 4, Training_Cost = 300},
			_6 = {DMG = 22, HP = 44, Range = 4, Training_Cost = 400},
			_7 = {DMG = 25, HP = 48, Range = 4, Training_Cost = 500},
			_8 = {DMG = 28, HP = 52, Range = 4, Training_Cost = 600},
		}
	},
	
	Troll = {
		Description = "A greedy animal that aspires to be rich!",
		PreferredTarget = "Resources",
		AttackType = "Melee",
		AttackSpeed = 1,
		MovementSpeed = 30,
		Houseing_Space = 1,
		Barracks_Level_Required = 3,
		CostType = "Currency",
		Levels = {
			_1 = {DMG = 11, HP = 25, Range = 0, Training_Cost = 25},
			_2 = {DMG = 14, HP = 30, Range = 0, Training_Cost = 40},
			_3 = {DMG = 19, HP = 36, Range = 0, Training_Cost = 60},
			_4 = {DMG = 24, HP = 46, Range = 0, Training_Cost = 80},
			_5 = {DMG = 32, HP = 56, Range = 0, Training_Cost = 100},
			_6 = {DMG = 42, HP = 76, Range = 0, Training_Cost = 150},
			_7 = {DMG = 52, HP = 101, Range = 0, Training_Cost = 200},
		}
	},
	
	Behemoth = {
		Description = "Mutant villager with great strength!",
		PreferredTarget = "Defense",
		AttackType = "Melee",
		AttackSpeed = 2,
		MovementSpeed = 10,
		Houseing_Space = 5,
		Barracks_Level_Required = 4,
		CostType = "Currency",
		Levels = {
			_1 = {DMG = 22, HP = 300, Range = 0, Training_Cost = 150},
			_2 = {DMG = 28, HP = 360, Range = 0, Training_Cost = 300},
			_3 = {DMG = 38, HP = 430, Range = 0, Training_Cost = 750},
			_4 = {DMG = 48, HP = 520, Range = 0, Training_Cost = 1500},
			_5 = {DMG = 62, HP = 720, Range = 0, Training_Cost = 2250},
			_6 = {DMG = 86, HP = 940, Range = 0, Training_Cost = 3000},
			_7 = {DMG = 52, HP = 1280, Range = 0, Training_Cost = 3500},
		}
	},

	Bombardier = {
		Description = "Bomb expert that loves to cause havoc!",
		PreferredTarget = "Walls",
		AttackType = "Bombs",
		AttackSpeed = 2,
		MovementSpeed = 15,
		Houseing_Space = 3,
		Barracks_Level_Required = 5,
		CostType = "Currency",
		Levels = {
			_1 = {DMG = 6, HP = 20, Range = 2, Training_Cost = 600},
			_2 = {DMG = 10, HP = 24, Range = 2, Training_Cost = 800},
			_3 = {DMG = 15, HP = 29, Range = 2, Training_Cost = 1000},
			_4 = {DMG = 20, HP = 35, Range = 2, Training_Cost = 1200},
			_5 = {DMG = 43, HP = 53, Range = 2, Training_Cost = 1400},
			_6 = {DMG = 55, HP = 72, Range = 2, Training_Cost = 1600},
			_7 = {DMG = 66, HP = 82, Range = 2, Training_Cost = 1800},
		}
	},
	
	Knight = {
		Description = "Raised with royalty, a very skilled charging warrior on his horse!",
		PreferredTarget = "Any",
		AttackType = "Melee and Horse",
		AttackSpeed = 2.5,
		MovementSpeed = 20,
		Houseing_Space = 10,
		Barracks_Level_Required = 6,
		CostType = "Currency",
		Levels = {
			_1 = {DMG = 6, HP = 20, Range = 2, Training_Cost = 600},
			_2 = {DMG = 10, HP = 24, Range = 2, Training_Cost = 800},
			_3 = {DMG = 15, HP = 29, Range = 2, Training_Cost = 1000},
			_4 = {DMG = 20, HP = 35, Range = 2, Training_Cost = 1200},
			_5 = {DMG = 43, HP = 53, Range = 2, Training_Cost = 1400},
			_6 = {DMG = 55, HP = 72, Range = 2, Training_Cost = 1600},
			_7 = {DMG = 66, HP = 82, Range = 2, Training_Cost = 1800},
		}
	},
}

function troopDataModule:GetTroopData(TroopInfo)
	return {Overall = troopData[TroopInfo.TroopType], Level = troopData[TroopInfo.TroopType].Levels["_"..TroopInfo.Level]}
end

return troopDataModule
