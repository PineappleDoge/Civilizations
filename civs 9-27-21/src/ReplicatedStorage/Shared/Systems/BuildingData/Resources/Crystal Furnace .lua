--------------------------------------------------------
-- PineappleDoge1 | Crystal Furnace
-- 6-30-2021 | Prototype
-- Crystal Furnace data
--------------------------------------------------------
-- Module Setup
local CrystalFurnace = {
	Description = "Farms crystal resources.";
	CostType = "Crystal";

	Level_1 = {
		Production = 1;
		Capacity = 10;
		Health = 300;
		BuildCost = 120000;
		BuildTime = (1 * 3600);
		XPGain = 10;
	};

	Level_2 = {
		Production = 1.5;
		Capacity = 11;
		Health = 350;
		BuildCost = 180000;
		BuildTime = (60 * 30) + (1 * 3600);
		XPGain = 20;
	};

	Level_3 = {
		Production = 2;
		Capacity = 12;
		Health = 400;
		BuildCost = 240000;
		BuildTime = (2 * 3600);
		XPGain = 30;
	};

	Level_4 = {
		Production = 2.5;
		Capacity = 13;
		Health = 450;
		BuildCost = 450000;
		BuildTime = (60 * 30) + (2 * 3600);
		XPGain = 40;
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

	return CrystalFurnace[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
CrystalFurnace.Name = "Crystal Furnace"
CrystalFurnace.UpgradeCost = UpgradeCost
CrystalFurnace.UpgradeTime = UpgradeTime


--------------------------------------------------------
return CrystalFurnace
