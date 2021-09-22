--------------------------------------------------------
-- PineappleDoge1 | Shocker
-- 6-12-2021 | Prototype
-- Shocker data
--------------------------------------------------------
-- Module Setup
local Shocker = {
	Description = "Shocks foes using electricity.";
	UnitTypeTargetted = "Ground/Air";
	DamageType = "Multiple";
	AttackSpeed = 4;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 110;
		DmgPerAtk = 440;
		Health = 700;
		BuildCost = 750000;
		BuildTime = (1 * 3600);
		XPGain = 10;
		Range = 7;
	};
	
	Level_2 = {
		DmgPerSec = 125;
		DmgPerAtk = 500;
		Health = 805;
		BuildCost = 1000000;
		BuildTime = (2 * 3600);
		XPGain = 20;
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
	
	return Shocker[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Shocker.Name = "Shocker"
Shocker.UpgradeCost = UpgradeCost
Shocker.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Shocker
