--------------------------------------------------------
-- PineappleDoge1 | Empire Tower
-- 6-30-2021 | Prototype
-- Empire Tower data
--------------------------------------------------------
-- Module Setup
local EmpireTower = {
	Description = "For joining/creating an empire.";
	CostType = "Currency";

	Level_1 = {
		Capacity = 10;
		Health = 1000;
		BuildCost = 10000;
		BuildTime = (60 * 5);
		XPGain = 10;
	};

	Level_2 = {
		Capacity = 15;
		Health = 1400;
		BuildCost = 100000;
		BuildTime = (60 * 15);
		XPGain = 20;
	};

	Level_3 = {
		Capacity = 20;
		Health = 2000;
		BuildCost = 500000;
		BuildTime = (60 * 30);
		XPGain = 30;
	};

	Level_4 = {
		Capacity = 25;
		Health = 2600;
		BuildCost = 750000;
		BuildTime = (60 * 45);
		XPGain = 40;
	};
	
	Level_5 = {
		Capacity = 30;
		Health = 3000;
		BuildCost = 1000000;
		BuildTime = (1 * 3600);
		XPGain = 50;
	};
	
	Level_6 = {
		Capacity = 35;
		Health = 3400;
		BuildCost = 1250000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 60;
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

	return EmpireTower[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
EmpireTower.Name = "Spire"
EmpireTower.UpgradeCost = UpgradeCost
EmpireTower.UpgradeTime = UpgradeTime


--------------------------------------------------------
return EmpireTower