--------------------------------------------------------
-- PineappleDoge1 | Catapult
-- 6-12-2021 | Prototype
-- Catapult data
--------------------------------------------------------
-- Module Setup
local Catapult = {
	Description = "Launches boulders at foes.";
	UnitTypeTargetted = "Ground/Air";
	DamageType = "Multiple";
	AttackSpeed = 3;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 133;
		DmgPerAtk = 400;
		Health = 750;
		BuildCost = 50000;
		BuildTime = (60 * 45);
		XPGain = 10;
		MinRange = 3;
		MaxRange = 10;
	};
	
	Level_2 = {
		DmgPerSec = 166;
		DmgPerAtk = 500;
		Health = 900;
		BuildCost = 150000;
		BuildTime = (1 * 3600);
		XPGain = 20;
		MinRange = 3;
		MaxRange = 10;
	};
	
	Level_3 = {
		DmgPerSec = 200;
		DmgPerAtk = 600;
		Health = 1150;
		BuildCost = 500000;
		BuildTime = (1 * 3600) + (60 * 15);
		XPGain = 30;
		MinRange = 3;
		MaxRange = 10;
	};
	
	Level_4 = {
		DmgPerSec = 233;
		DmgPerAtk = 700;
		Health = 1400;
		BuildCost = 1250000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 40;
		MinRange = 3;
		MaxRange = 10;
	};
	
	Level_5 = {
		DmgPerSec = 266;
		DmgPerAtk = 800;
		Health = 1750;
		BuildCost = 1750000;
		BuildTime = (2 * 3600);
		XPGain = 50;
		MinRange = 3;
		MaxRange = 10;
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
	
	return Catapult[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Catapult.Name = "Catapult"
Catapult.UpgradeCost = UpgradeCost
Catapult.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Catapult
