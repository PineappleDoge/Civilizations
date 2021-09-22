--------------------------------------------------------
-- PineappleDoge1 | Starbow
-- 6-12-2021 | Prototype
-- Starbow data
--------------------------------------------------------
-- Module Setup
local Starbow = {
	Description = "Automatic bow/arrow launcher.";
	UnitTypeTargetted = "Ground/Air";
	DamageType = "Single Target";
	AttackSpeed = 0.125;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 64;
		DmgPerAtk = 8;
		Health = 1500;
		BuildCost = 1000000;
		BuildTime = (1 * 3600);
		XPGain = 10;
		Range = 14;
	};
	
	Level_2 = {
		DmgPerSec = 72;
		DmgPerAtk = 9;
		Health = 1900;
		BuildCost = 1500000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 20;
		Range = 14;
	};
	
	Level_3 = {
		DmgPerSec = 80;
		DmgPerAtk = 10;
		Health = 2300;
		BuildCost = 2000000;
		BuildTime = (2 * 3600);
		XPGain = 30;
		Range = 14;
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
	
	return Starbow[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Starbow.Name = "Starbow"
Starbow.UpgradeCost = UpgradeCost
Starbow.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Starbow
