--------------------------------------------------------
-- PineappleDoge1 | Outpost
-- 6-12-2021 | Ventilator
-- Ventilator data
--------------------------------------------------------
-- Module Setup
local Ventilator = {
	Description = "Blows air towards air troops.";
	UnitTypeTargetted = "Air";
	DamageType = "Single Target";
	AttackSpeed = 5;
	CostType = "Currency";
	
	Level_1 = {
		PushStrength = 2;
		Health = 750;
		BuildCost = 500000;
		BuildTime = (1 * 3600);
		XPGain = 10;
		Range = 15;
	};
	
	Level_2 = {
		PushStrength = 2.5;
		Health = 800;
		BuildCost = 750000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 20;
		Range = 15;
	};
	
	Level_3 = {
		PushStrength = 3;
		Health = 850;
		BuildCost = 1000000;
		BuildTime = (2 * 3600);
		XPGain = 30;
		Range = 15;
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
	
	return Ventilator[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Ventilator.Name = "Ventilator"
Ventilator.UpgradeCost = UpgradeCost
Ventilator.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Ventilator
