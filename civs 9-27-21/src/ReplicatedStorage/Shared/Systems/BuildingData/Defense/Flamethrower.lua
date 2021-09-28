--------------------------------------------------------
-- PineappleDoge1 | Flamethrower
-- 6-12-2021 | Prototype
-- Flamethrower data
--------------------------------------------------------
-- Module Setup
local Flamethrower = {
	Description = "Shoots fire out of its nozzle.";
	UnitTypeTargetted = "Ground/Air";
	DamageType = "Multiple";
	AttackSpeed = 0.2;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 50;
		DmgPerAtk = 10;
		Health = 800;
		BuildCost = 15000;
		BuildTime = (60 * 15);
		XPGain = 10;
		Range = 7;
	};
	
	Level_2 = {
		DmgPerSec = 55;
		DmgPerAtk = 11;
		Health = 920;
		BuildCost = 150000;
		BuildTime = (60 * 45);
		XPGain = 20;
		Range = 7;
	};
	
	Level_3 = {
		DmgPerSec = 60;
		DmgPerAtk = 12;
		Health = 1058;
		BuildCost = 300000;
		BuildTime = (1 * 3600);
		XPGain = 30;
		Range = 7;
	};
	
	Level_4 = {
		DmgPerSec = 65;
		DmgPerAtk = 13;
		Health = 1217;
		BuildCost = 750000;
		BuildTime = (1 * 3600) + (60 * 15);
		XPGain = 40;
		Range = 7;
	};
	
	Level_5 = {
		DmgPerSec = 70;
		DmgPerAtk = 14;
		Health = 1400;
		BuildCost = 1500000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 50;
		Range = 7;
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
	
	return Flamethrower[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Flamethrower.Name = "Flamethrower"
Flamethrower.UpgradeCost = UpgradeCost
Flamethrower.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Flamethrower
