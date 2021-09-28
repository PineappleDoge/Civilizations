--------------------------------------------------------
-- PineappleDoge1 | Poison Spikes
-- 6-12-2021 | Prototype
-- Poison Spikes data
--------------------------------------------------------
-- Module Setup
local PoisonSpikes = {
	Description = "Poisons foes who step on it.";
	UnitTypeTargetted = "Ground";
	DamageType = "Multiple";
	AttackSpeed = 1;
	CostType = "Currency";

	Level_1 = {
		DmgPerSec = 100;
		DmgPerAtk = 100;
		Health = nil;
		BuildCost = 50000;
		BuildTime = 0;
		XPGain = 10;
		Range = 2;
	};

	Level_2 = {
		DmgPerSec = 150;
		DmgPerAtk = 150;
		Health = nil;
		BuildCost = 250000;
		BuildTime = (1 * 3600);
		XPGain = 20;
		Range = 2;
	};

	Level_3 = {
		DmgPerSec = 200;
		DmgPerAtk = 200;
		Health = nil;
		BuildCost = 500000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 30;
		Range = 2;
	};

	Level_4 = {
		DmgPerSec = 250;
		DmgPerAtk = 250;
		Health = nil;
		BuildCost = 1250000;
		BuildTime = (2 * 3600);
		XPGain = 40;
		Range = 2;
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

	return PoisonSpikes[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
PoisonSpikes.Name = "Poison Spikes"
PoisonSpikes.UpgradeCost = UpgradeCost
PoisonSpikes.UpgradeTime = UpgradeTime


--------------------------------------------------------
return PoisonSpikes
