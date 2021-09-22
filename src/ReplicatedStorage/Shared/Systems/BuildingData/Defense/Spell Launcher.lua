--------------------------------------------------------
-- PineappleDoge1 | Spell Launcher
-- 6-12-2021 | Prototype
-- Spell Launcher data
--------------------------------------------------------
-- Module Setup
local SpellLauncher = {
	Description = "Launches spell balls at foes.";
	UnitTypeTargetted = "Ground";
	DamageType = "Multiple";
	AttackSpeed = 5;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 4;
		DmgPerAtk = 20;
		Health = 400;
		BuildCost = 5000;
		BuildTime = (60 * 5);
		XPGain = 10;
		MinRange = 4;
		MaxRange = 11;
	};
	
	Level_2 = {
		DmgPerSec = 5;
		DmgPerAtk = 25;
		Health = 450;
		BuildCost = 25000;
		BuildTime = (60 * 10);
		XPGain = 20;
		MinRange = 4;
		MaxRange = 11;
	};
	
	Level_3 = {
		DmgPerSec = 6;
		DmgPerAtk = 30;
		Health = 500;
		BuildCost = 100000;
		BuildTime = (60 * 15);
		XPGain = 30;
		MinRange = 4;
		MaxRange = 11;
	};
	
	Level_4 = {
		DmgPerSec = 7;
		DmgPerAtk = 35;
		Health = 550;
		BuildCost = 250000;
		BuildTime = (60 * 30);
		XPGain = 40;
		MinRange = 4;
		MaxRange = 11;
	};
	
	Level_5 = {
		DmgPerSec = 9;
		DmgPerAtk = 45;
		Health = 600;
		BuildCost = 500000;
		BuildTime = (60 * 45);
		XPGain = 50;
		MinRange = 4;
		MaxRange = 11;
	};
	
	Level_6 = {
		DmgPerSec = 11;
		DmgPerAtk = 55;
		Health = 650;
		BuildCost = 1000000;
		BuildTime = (1 * 3600);
		XPGain = 60;
		MinRange = 4;
		MaxRange = 11;
	};
	
	Level_7 = {
		DmgPerSec = 15;
		DmgPerAtk = 75;
		Health = 700;
		BuildCost = 2000000;
		BuildTime = (1 * 3600) + (60 * 30);
		XPGain = 70;
		MinRange = 4;
		MaxRange = 11;
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
	
	return SpellLauncher[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
SpellLauncher.Name = "Spell Launcher"
SpellLauncher.UpgradeCost = UpgradeCost
SpellLauncher.UpgradeTime = UpgradeTime


--------------------------------------------------------
return SpellLauncher
