--------------------------------------------------------
-- PineappleDoge1 | Spire
-- 6-30-2021 | Prototype
-- Spire data
--------------------------------------------------------
-- Module Setup
local Spire = {
	Description = "Used to speed up time.";
	CostType = "Currency";
	
	Level_1 = {
		TimeBoost = 5;
		TimeLength = (60 * 14);
		Health = 650;
		BuildCost = 50000;
		BuildTime = (60 * 5);
		XPGain = 10;
	};
	
	Level_2 = {
		TimeBoost = 5.5;
		TimeLength = (60 * 16);
		Health = 800;
		BuildCost = 100000;
		BuildTime = (60 * 15);
		XPGain = 20;
	};
	
	Level_3 = {
		TimeBoost = 6;
		TimeLength = (60 * 18);
		Health = 960;
		BuildCost = 150000;
		BuildTime = (60 * 30);
		XPGain = 40;
	};
	
	Level_4 = {
		TimeBoost = 6.5;
		TimeLength = (60 * 20);
		Health = 1150;
		BuildCost = 250000;
		BuildTime = (60 * 45);
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

	return Spire[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Spire.Name = "Spire"
Spire.UpgradeCost = UpgradeCost
Spire.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Spire