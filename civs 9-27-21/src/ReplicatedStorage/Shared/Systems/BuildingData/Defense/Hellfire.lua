--------------------------------------------------------
-- PineappleDoge1 | Hellfire
-- 6-12-2021 | Prototype
-- Hellfire data
--------------------------------------------------------
-- Module Setup
local Hellfire = {
	Description = "Launches fireworks at foes.";
	UnitTypeTargetted = "Air";
	DamageType = "Multiple";
	AttackSpeed = 1;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 160;
		DmgPerAtk = 160;
		Health = 950;
		BuildCost = 22000;
		BuildTime = (60 * 30);
		XPGain = 10;
		Range = 10;
	};
	
	Level_2 = {
		DmgPerSec = 190;
		DmgPerAtk = 190;
		Health = 1000;
		BuildCost = 270000;
		BuildTime = (60 * 45);
		XPGain = 20;
		Range = 10;
	};
	
	Level_3 = {
		DmgPerSec = 230;
		DmgPerAtk = 230;
		Health = 1050;
		BuildCost = 500000;
		BuildTime = (1 * 3600);
		XPGain = 30;
		Range = 10;
	};
	
	Level_4 = {
		DmgPerSec = 280;
		DmgPerAtk = 280;
		Health = 1100;
		BuildCost = 750000;
		BuildTime = (1 * 3600) + (60 * 15);
		XPGain = 40;
		Range = 10;
	};
	
	Level_5 = {
		DmgPerSec = 320;
		DmgPerAtk = 320;
		Health = 1210;
		BuildCost = 1000000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 50;
		Range = 10;
	};
	
	Level_6 = {
		DmgPerSec = 360;
		DmgPerAtk = 360;
		Health = 1300;
		BuildCost = 1500000;
		BuildTime = (2 * 3600);
		XPGain = 60;
		Range = 10;
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
	
	return Hellfire[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Hellfire.Name = "Hellfire"
Hellfire.UpgradeCost = UpgradeCost
Hellfire.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Hellfire
