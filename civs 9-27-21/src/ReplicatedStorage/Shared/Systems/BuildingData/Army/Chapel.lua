--------------------------------------------------------
-- PineappleDoge1 | Chapel
-- 6-30-2021 | Prototype
-- Chapel data
--------------------------------------------------------
-- Module Setup
local Chapel = {
	Description = "Used to upgrade troops and spells";
	CostType = "Currency";

	Level_1 = {
		Health = 500;
		BuildCost = 5000;
		BuildTime = (60 * 1);
		XPGain = 10;
	};

	Level_2 = {
		Health = 550;
		BuildCost = 25000;
		BuildTime = (60 * 5);
		XPGain = 20;
	};

	Level_3 = {
		Health = 600;
		BuildCost = 75000;
		BuildTime = (60 * 10);
		XPGain = 30;
	};

	Level_4 = {
		Health = 650;
		BuildCost = 150000;
		BuildTime = (60 * 15);
		XPGain = 40;
	};
	
	Level_5 = {
		Health = 700;
		BuildCost = 300000;
		BuildTime = (60 * 30);
		XPGain = 50;
	};
	
	Level_6 = {
		Health = 750;
		BuildCost = 600000;
		BuildTime = (60 * 45);
		XPGain = 60;
	};
	
	Level_7 = {
		Health = 830;
		BuildCost = 1200000;
		BuildTime = (1 * 3600);
		XPGain = 70;
	};
	
	Level_8 = {
		Health = 950;
		BuildCost = 2000000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 80;
	};
	
	Level_9 = {
		Health = 1070;
		BuildCost = 2500000;
		BuildTime = (2 * 3600);
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

	return Chapel[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Chapel.Name = "Chapel"
Chapel.UpgradeCost = UpgradeCost
Chapel.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Chapel