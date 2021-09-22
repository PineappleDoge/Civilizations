--------------------------------------------------------
-- PineappleDoge1 | Soul Pump
-- 6-30-2021 | Prototype
-- Soul Pump data
--------------------------------------------------------
-- Module Setup
local SoulPump = {
	Description = "Farms soul resources.";
	CostType = "Currency";

	Level_1 = {
		Production = 200;
		Capacity = 1000;
		Health = 400;
		BuildCost = 150;
		BuildTime = (60 * 1);
		XPGain = 10;
	};

	Level_2 = {
		Production = 400;
		Capacity = 2000;
		Health = 440;
		BuildCost = 300;
		BuildTime = (60 * 2);
		XPGain = 20;
	};

	Level_3 = {
		Production = 600;
		Capacity = 3000;
		Health = 480;
		BuildCost = 700;
		BuildTime = (60 * 5);
		XPGain = 30;
	};

	Level_4 = {
		Production = 800;
		Capacity = 5000;
		Health = 520;
		BuildCost = 1400;
		BuildTime = (60 * 10);
		XPGain = 40;
	};

	Level_5 = {
		Production = 1000;
		Capacity = 10000;
		Health = 560;
		BuildCost = 3000;
		BuildTime = (60 * 15);
		XPGain = 50;
	};

	Level_6 = {
		Production = 1300;
		Capacity = 20000;
		Health = 600;
		BuildCost = 7000;
		BuildTime = (60 * 20);
		XPGain = 60;
	};

	Level_7 = {
		Production = 1600;
		Capacity = 30000;
		Health = 640;
		BuildCost = 14000;
		BuildTime = (60 * 25);
		XPGain = 70;
	};

	Level_8 = {
		Production = 1900;
		Capacity = 50000;
		Health = 680;
		BuildCost = 28000;
		BuildTime = (60 * 30);
		XPGain = 80;
	};

	Level_9 = {
		Production = 2200;
		Capacity = 75000;
		Health = 720;
		BuildCost = 56000;
		BuildTime = (60 * 45);
		XPGain = 90;
	};

	Level_10 = {
		Production = 2800;
		Capacity = 100000;
		Health = 780;
		BuildCost = 75000;
		BuildTime = (1 * 3600);
		XPGain = 100;
	};

	Level_11 = {
		Production = 3500;
		Capacity = 150000;
		Health = 860;
		BuildCost = 100000;
		BuildTime = (60 * 15) + (1 * 3600);
		XPGain = 110;
	};

	Level_12 = {
		Production = 4200;
		Capacity = 200000;
		Health = 960;
		BuildCost = 200000;
		BuildTime = (60 * 30) + (1 * 3600);
		XPGain = 120;
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

	return SoulPump[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
SoulPump.Name = "Soul Pump"
SoulPump.UpgradeCost = UpgradeCost
SoulPump.UpgradeTime = UpgradeTime


--------------------------------------------------------
return SoulPump