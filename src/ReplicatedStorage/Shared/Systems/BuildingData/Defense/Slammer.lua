--------------------------------------------------------
-- PineappleDoge1 | Slammer
-- 6-12-2021 | Prototype
-- Slammer data
--------------------------------------------------------
-- Module Setup
local Slammer = {
	Description = "Crushes foes close to its rock.";
	UnitTypeTargetted = "Ground";
	DamageType = "Multiple";
	AttackSpeed = 3.5;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 142;
		DmgPerAtk = 500;
		Health = 1000;
		BuildCost = 5000;
		BuildTime = (60 * 5);
		XPGain = 10;
		Range = 3;
	};
	
	Level_2 = {
		DmgPerSec = 157;
		DmgPerAtk = 550;
		Health = 1150;
		BuildCost = 15000;
		BuildTime = (60 * 15);
		XPGain = 20;
		Range = 3;
	};
	
	Level_3 = {
		DmgPerSec = 172;
		DmgPerAtk = 605;
		Health = 1323;
		BuildCost = 50000;
		BuildTime = (60 * 30);
		XPGain = 30;
		Range = 3;
	};
	
	Level_4 = {
		DmgPerSec = 190;
		DmgPerAtk = 666;
		Health = 1521;
		BuildCost = 100000;
		BuildTime = (60 * 45);
		XPGain = 40;
		Range = 3;
	};
	
	Level_5 = {
		DmgPerSec = 209;
		DmgPerAtk = 733;
		Health = 1749;
		BuildCost = 150000;
		BuildTime = (1 * 3600);
		XPGain = 50;
		Range = 3;
	};
	
	Level_6 = {
		DmgPerSec = 230;
		DmgPerAtk = 806;
		Health = 2011;
		BuildCost = 300000;
		BuildTime = (1 * 3600) + (60 * 15);
		XPGain = 60;
		Range = 3;
	};
	
	Level_7 = {
		DmgPerSec = 253;
		DmgPerAtk = 887;
		Health = 2313;
		BuildCost = 600000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 60;
		Range = 3;
	};
	
	Level_8 = {
		DmgPerSec = 278;
		DmgPerAtk = 976;
		Health = 2660;
		BuildCost = 1200000;
		BuildTime = (1 * 3600) + (60 * 45);
		XPGain = 60;
		Range = 3;
	};
	
	Level_9 = {
		DmgPerSec = 306;
		DmgPerAtk = 1074;
		Health = 2793;
		BuildCost = 1500000;
		BuildTime = (2 * 3600);
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
	
	return Slammer[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Slammer.Name = "Slammer"
Slammer.UpgradeCost = UpgradeCost
Slammer.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Slammer
