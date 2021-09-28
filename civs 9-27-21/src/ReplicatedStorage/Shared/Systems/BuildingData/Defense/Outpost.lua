
--------------------------------------------------------
-- PineappleDoge1 | Outpost
-- 6-12-2021 | Prototype
-- Outpost data
--------------------------------------------------------
-- Module Setup
local Outpost = {
	Description = "An outpost for troop guards.";
	UnitTypeTargetted = "Ground/Air";
	DamageType = "Single Target";
	CostType = "Currency";
	
	Level_1 = {
		Health = 300;
		BuildCost = 2500;
		BuildTime = (60 * 5);
		XPGain = 10;
	};
	
	Level_2 = {
		Health = 345;
		BuildCost = 5000;
		BuildTime = (60 * 10);
		XPGain = 20;
	};
	
	Level_3 = {
		Health = 397;
		BuildCost = 15000;
		BuildTime = (60 * 15);
		XPGain = 30;
	};
	
	Level_4 = {
		Health = 457;
		BuildCost = 30000;
		BuildTime = (60 * 30);
		XPGain = 40;
	};
	
	Level_5 = {
		Health = 526;
		BuildCost = 90000;
		BuildTime = (60 * 45);
		XPGain = 50;
	};
	
	Level_6 = {
		Health = 605;
		BuildCost = 120000;
		BuildTime = (1 * 3600);
		XPGain = 60;
	};
	
	Level_7 = {
		Health = 696;
		BuildCost = 400000;
		BuildTime = (1 * 3600) + (60 * 10);
		XPGain = 70;
	};
	
	Level_8 = {
		Health = 800;
		BuildCost = 750000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 80;
	};
	
	Level_9 = {
		Health = 840;
		BuildCost = 1000000;
		BuildTime = (1 * 3600) + (60 * 45);
		XPGain = 90;
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
	
	return Outpost[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Outpost.Name = "Outpost"
Outpost.UpgradeCost = UpgradeCost
Outpost.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Outpost
