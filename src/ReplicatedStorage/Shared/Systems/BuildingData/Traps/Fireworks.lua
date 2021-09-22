--------------------------------------------------------
-- PineappleDoge1 | Fireworks
-- 6-12-2021 | Prototype
-- Fireworks data
--------------------------------------------------------
-- Module Setup
local Fireworks = {
	Description = "Shoots into air foes when nearby.";
	UnitTypeTargetted = "Air";
	DamageType = "Multiple";
	AttackSpeed = 1;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerAtk = 100;
		BuildCost = 4000;
		BuildTime = 0;
		XPGain = 10;
		Range = 3;
	};
	
	Level_2 = {
		DmgPerAtk = 120;
		BuildCost = 20000;
		BuildTime = (60 * 10);
		XPGain = 20;
		Range = 3;
	};
	
	Level_3 = {
		DmgPerAtk = 144;
		BuildCost = 200000;
		BuildTime = (60 * 30);
		XPGain = 30;
		Range = 3;
	};
	
	Level_4 = {
		DmgPerAtk = 173;
		BuildCost = 800000;
		BuildTime = (60 * 45);
		XPGain = 40;
		Range = 3;
	};
	
	Level_5 = {
		DmgPerAtk = 200;
		BuildCost = 1250000;
		BuildTime = (1 * 3600);
		XPGain = 50;
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
	
	return Fireworks[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Fireworks.Name = "Fireworks"
Fireworks.UpgradeCost = UpgradeCost
Fireworks.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Fireworks
