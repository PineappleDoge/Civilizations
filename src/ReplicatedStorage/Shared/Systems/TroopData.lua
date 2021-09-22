local troopDataModule = {}

local troopData = {
	Warrior = {
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
	
	Archeress = {},
}

function troopDataModule:GetTroopData(TroopInfo)
	return {Overall = troopData[TroopInfo.TroopType], Level = troopData[TroopInfo.TroopType].Levels["_"..TroopInfo.Level]}
end

return troopDataModule
