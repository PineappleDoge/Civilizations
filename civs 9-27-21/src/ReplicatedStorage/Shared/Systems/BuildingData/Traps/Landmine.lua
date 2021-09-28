--------------------------------------------------------
-- PineappleDoge1 | Landmine
-- 6-12-2021 | Prototype
-- Landmine data
--------------------------------------------------------
-- Module Setup
local Landmine = {
	Description = "Explodes on touch.";
	UnitTypeTargetted = "Ground";
	DamageType = "Multiple";
	AttackSpeed = 1;
	CostType = "Currency";

	Level_1 = {
		DmgPerSec = 20;
		DmgPerAtk = 20;
		Health = nil;
		BuildCost = 400;
		BuildTime = 0;
		XPGain = 10;
		Range = 3;
	};

	Level_2 = {
		DmgPerSec = 24;
		DmgPerAtk = 24;
		Health = nil;
		BuildCost = 1000;
		BuildTime = (60 * 5);
		XPGain = 20;
		Range = 3;
	};

	Level_3 = {
		DmgPerSec = 29;
		DmgPerAtk = 29;
		Health = nil;
		BuildCost = 10000;
		BuildTime = (60 * 15);
		XPGain = 30;
		Range = 3;
	};

	Level_4 = {
		DmgPerSec = 35;
		DmgPerAtk = 35;
		Health = nil;
		BuildCost = 100000;
		BuildTime = (60 * 30);
		XPGain = 40;
		Range = 3;
	};

	Level_5 = {
		DmgPerSec = 42;
		DmgPerAtk = 42;
		Health = nil;
		BuildCost = 300000;
		BuildTime = (60 * 45);
		XPGain = 50;
		Range = 3;
	};

	Level_6 = {
		DmgPerSec = 54;
		DmgPerAtk = 54;
		Health = nil;
		BuildCost = 600000;
		BuildTime = (1 * 3600);
		XPGain = 60;
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

	return Landmine[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Landmine.Name = "Landmine"
Landmine.UpgradeCost = UpgradeCost
Landmine.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Landmine
