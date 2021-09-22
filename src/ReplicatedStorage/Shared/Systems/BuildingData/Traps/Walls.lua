--------------------------------------------------------
-- PineappleDoge1 | Walls
-- 6-12-2021 | Prototype
-- Walls data
--------------------------------------------------------
-- Module Setup
local Walls = {
	Description = "Extra protection around base.";
	UnitTypeTargetted = "Ground";
	CostType = "Currency";
	
	Level_1 = {
		Health = 300;
		BuildCost = 50;
	};
	
	Level_2 = {
		Health = 500;
		BuildCost = 1000;
	};
	
	Level_3 = {
		Health = 700;
		BuildCost = 5000;
	};
	
	Level_4 = {
		Health = 900;
		BuildCost = 10000;
	};
	
	Level_5 = {
		Health = 1400;
		BuildCost = 20000;
	};
	
	Level_6 = {
		Health = 2000;
		BuildCost = 40000;
	};
	
	Level_7 = {
		Health = 2500;
		BuildCost = 80000;
	};
	
	Level_8 = {
		Health = 3000;
		BuildCost = 150000;
	};
	
	Level_9 = {
		Health = 4000;
		BuildCost = 250000;
	};
	
	Level_10 = {
		Health = 5500;
		BuildCost = 500000;
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
	
	return Walls[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Walls.Name = "Walls"
Walls.UpgradeCost = UpgradeCost
Walls.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Walls
