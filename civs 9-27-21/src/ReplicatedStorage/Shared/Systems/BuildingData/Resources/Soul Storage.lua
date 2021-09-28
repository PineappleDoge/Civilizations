--------------------------------------------------------
-- PineappleDoge1 | Soul Storage
-- 6-30-2021 | Prototype
-- Soul Storage data
--------------------------------------------------------
-- Module Setup
local SoulStorage = {
	Description = "Holds all soul resources.";
	CostType = "Currency";

	Level_1 = {
		Capacity = 1500;
		Health = 400;
		BuildCost = 300;
		BuildTime = (60 * 1);
		XPGain = 10;
	};

	Level_2 = {
		Capacity = 3000;
		Health = 600;
		BuildCost = 750;
		BuildTime = (60 * 5);
		XPGain = 20;
	};

	Level_3 = {
		Capacity = 6000;
		Health = 800;
		BuildCost = 1500;
		BuildTime = (60 * 10);
		XPGain = 30;
	};

	Level_4 = {
		Capacity = 12000;
		Health = 1000;
		BuildCost = 3000;
		BuildTime = (60 * 15);
		XPGain = 40;
	};

	Level_5 = {
		Capacity = 25000;
		Health = 1200;
		BuildCost = 6000;
		BuildTime = (60 * 30);
		XPGain = 50;
	};

	Level_6 = {
		Capacity = 45000;
		Health = 1400;
		BuildCost = 12000;
		BuildTime = (60 * 45);
		XPGain = 60;
	};

	Level_7 = {
		Capacity = 100000;
		Health = 1600;
		BuildCost = 25000;
		BuildTime = (1 * 3600);
		XPGain = 70;
	};

	Level_8 = {
		Capacity = 225000;
		Health = 1700;
		BuildCost = 50000;
		BuildTime = (1 * 3600) + (60 * 15);
		XPGain = 80;
	};

	Level_9 = {
		Capacity = 450000;
		Health = 1800;
		BuildCost = 100000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 90;
	};

	Level_10 = {
		Capacity = 850000;
		Health = 1900;
		BuildCost = 250000;
		BuildTime = (1 * 3600) + (60 * 45);
		XPGain = 100;
	};

	Level_11 = {
		Capacity = 1750000;
		Health = 2100;
		BuildCost = 500000;
		BuildTime = (2 * 3600);
		XPGain = 110;
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

	return SoulStorage[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
SoulStorage.Name = "Soul Storage"
SoulStorage.UpgradeCost = UpgradeCost
SoulStorage.UpgradeTime = UpgradeTime


--------------------------------------------------------
return SoulStorage
