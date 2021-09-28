--------------------------------------------------------
-- PineappleDoge1 | Camp Grounds
-- 6-30-2021 | Prototype
-- Camp Grounds data
--------------------------------------------------------
-- Module Setup
local CampGrounds = {
	Description = "Used to store your armies.";
	CostType = "Currency";

	Level_1 = {
		Capacity = 20;
		Health = 250;
		BuildCost = 200;
		BuildTime = (60 * 5);
		XPGain = 10;
	};

	Level_2 = {
		Capacity = 30;
		Health = 270;
		BuildCost = 2000;
		BuildTime = (60 * 10);
		XPGain = 20;
	};

	Level_3 = {
		Capacity = 35;
		Health = 290;
		BuildCost = 10000;
		BuildTime = (60 * 15);
		XPGain = 30;
	};

	Level_4 = {
		Capacity = 40;
		Health = 310;
		BuildCost = 100000;
		BuildTime = (60 * 30);
		XPGain = 40;
	};

	Level_5 = {
		Capacity = 45;
		Health = 330;
		BuildCost = 250000;
		BuildTime = (60 * 45);
		XPGain = 50;
	};

	Level_6 = {
		Capacity = 50;
		Health = 350;
		BuildCost = 750000;
		BuildTime = (1 * 3600);
		XPGain = 60;
	};

	Level_7 = {
		Capacity = 55;
		Health = 400;
		BuildCost = 1000000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 70;
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

	return CampGrounds[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
CampGrounds.Name = "Camp Grounds"
CampGrounds.UpgradeCost = UpgradeCost
CampGrounds.UpgradeTime = UpgradeTime


--------------------------------------------------------
return CampGrounds