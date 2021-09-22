--------------------------------------------------------
-- PineappleDoge1 | Spell Stirrer
-- 6-30-2021 | Prototype
-- Spell Stirrer data
--------------------------------------------------------
-- Module Setup
local SpellStirrer = {
	Description = "Used for creating spells.";
	CostType = "Currency";

	['Level_1'] = {
		Capacity = 2;
		Health = 425;
		BuildCost = 200000;
		BuildTime = (60 * 15);
		XPGain = 10;
	};

	['Level_2'] = {
		Capacity = 4;
		Health = 470;
		BuildCost = 400000;
		BuildTime = (60 * 30);
		XPGain = 20;
	};

	['Level_3'] = {
		Capacity = 6;
		Health = 520;
		BuildCost = 800000;
		BuildTime = (60 * 45);
		XPGain = 30;
	};

	['Level_4'] = {
		Capacity = 8;
		Health = 600;
		BuildCost = 1200000;
		BuildTime = (1 * 3600);
		XPGain = 40;
	};
	
	['Level_5'] = {
		Capacity = 10;
		Health = 720;
		BuildCost = 1600000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 50;
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

	return SpellStirrer[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
SpellStirrer.Name = "Spell Stirrer"
SpellStirrer.UpgradeCost = UpgradeCost
SpellStirrer.UpgradeTime = UpgradeTime


--------------------------------------------------------
return SpellStirrer