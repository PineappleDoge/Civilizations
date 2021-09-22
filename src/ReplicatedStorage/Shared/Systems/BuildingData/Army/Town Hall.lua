--------------------------------------------------------
-- PineappleDoge1 | TownHall
-- 6-12-2021 | Prototype
-- TownHall data
--------------------------------------------------------
-- Module Setup
local TownHall = {
	Description = "The hub of all the village.";
	CostType = "Currency";
	
	Level_1 = {
		Amount = 1, 
		BuildCost = 0, 
		BuildTime = 0;
		XPGain = 0;
	};
	
	Level_2 = {
		Amount = 1, 
		BuildCost = 1000, 
		BuildTime = (60 * 1);
		XPGain = 100;
	};
	
	Level_3 = {
		Amount = 1, 
		BuildCost = 4000, 
		BuildTime = (60 * 15);
		XPGain = 200;
	};
	
	Level_4 = {
		Amount = 1, 
		BuildCost = 25000, 
		BuildTime = (60 * 30);
		XPGain = 300;
	};
	
	Level_5 = {
		Amount = 1,
		BuildCost = 150000, 
		BuildTime = (60 * 45);
		XPGain = 400;
	};
	
	Level_6 = {
		Amount = 1, 
		BuildCost = 750000, 
		BuildTime = (1 * 3600);
		XPGain = 500;
	};
	
	Level_7 = {
		Amount = 1, 
		BuildCost = 1000000, 
		BuildTime = (2 * 3600);
		XPGain = 600;
	};
	
	Level_8 = {
		Amount = 1, 
		BuildCost = 2000000, 
		BuildTime = (3 * 3600);
		XPGain = 700;
	};
	
	Level_9 = {
		Amount = 1, 
		BuildCost = 3000000, 
		BuildTime = (4 * 3600);
		XPGain = 800;
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

	return TownHall[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
TownHall.Name = "Town Hall"
TownHall.UpgradeCost = UpgradeCost
TownHall.UpgradeTime = UpgradeTime


--------------------------------------------------------
return TownHall