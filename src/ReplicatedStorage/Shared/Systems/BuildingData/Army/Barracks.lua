--------------------------------------------------------
-- PineappleDoge1 | Barracks
-- 6-30-2021 | Prototype
-- Barracks data
--------------------------------------------------------
-- Module Setup
local Barracks = {
	Description = "Used to train troops.";
	CostType = "Currency";

	Level_1 = {
		Health = 250;
		BuildCost = 100;
		BuildTime = (60 * 1);
		XPGain = 10;
	};

	Level_2 = {
		Health = 290;
		BuildCost = 500;
		BuildTime = (60 * 5);
		XPGain = 20;
	};

	Level_3 = {
		Health = 330;
		BuildCost = 2500;
		BuildTime = (60 * 10);
		XPGain = 30;
	};

	Level_4 = {
		Health = 270;
		BuildCost = 5000;
		BuildTime = (60 * 15);
		XPGain = 40;
	};

	Level_5 = {
		Health = 420;
		BuildCost = 10000;
		BuildTime = (60 * 30);
		XPGain = 50;
	};

	Level_6 = {
		Health = 470;
		BuildCost = 80000;
		BuildTime = (60 * 45);
		XPGain = 60;
	};

	Level_7 = {
		Health = 520;
		BuildCost = 240000;
		BuildTime = (1 * 3600);
		XPGain = 70;
	};
	
	Level_8 = {
		Health = 580;
		BuildCost = 700000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 80;
	};
	
	Level_9 = {
		Health = 650;
		BuildCost = 1000000;
		BuildTime = (2 * 3600);
		XPGain = 90;
	};
	
	Level_10 = {
		Health = 730;
		BuildCost = 1500000;
		BuildTime = (2 * 3600) + (60 * 30);
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

	return Barracks[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Barracks.Name = "Barracks"
Barracks.UpgradeCost = UpgradeCost
Barracks.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Barracks