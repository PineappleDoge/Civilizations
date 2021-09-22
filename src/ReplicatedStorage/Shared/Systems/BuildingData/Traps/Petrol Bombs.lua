--------------------------------------------------------
-- PineappleDoge1 | Petrol Bombs
-- 6-12-2021 | Prototype
-- Petrol Bombs data
--------------------------------------------------------
-- Module Setup
local PetrolBombs = {
	Description = "Explodes and causes fire.";
	UnitTypeTargetted = "Ground";
	DamageType = "Multiple";
	AttackSpeed = 1;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerAtk = 175;
		BuildCost = 12500;
		BuildTime = 0;
		XPGain = 10;
		Range = 3;
	};
	
	Level_2 = {
		DmgPerAtk = 200;
		BuildCost = 75000;
		BuildTime = (1 * 3600);
		XPGain = 20;
		Range = 3;
	};
	
	Level_3 = {
		DmgPerAtk = 225;
		BuildCost = 500000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 30;
		Range = 3;
	};
	
	Level_4 = {
		DmgPerAtk = 250;
		BuildCost = 1000000;
		BuildTime = (2 * 3600);
		XPGain = 40;
		Range = 3;
	};
}


--------------------------------------------------------
-- Private Functions
local function IndexLevel(lvl)
	local Level = "Level_" .. lvl

	if Level == nil then
		warn("Can't upgrade")
		return
	end
	
	return PetrolBombs[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
PetrolBombs.Name = "Petrol Bombs"
PetrolBombs.UpgradeCost = UpgradeCost
PetrolBombs.UpgradeTime = UpgradeTime


--------------------------------------------------------
return PetrolBombs
