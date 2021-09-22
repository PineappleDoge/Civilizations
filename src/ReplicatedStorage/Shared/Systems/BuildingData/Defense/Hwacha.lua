--------------------------------------------------------
-- PineappleDoge1 | Hwacha
-- 6-12-2021 | Prototype
-- Hwacha data
--------------------------------------------------------
-- Module Setup
local Hwacha = {
	Description = "Shoots arrows at foes.";
	UnitTypeTargetted = "Multiple";
	DamageType = "Single Target";
	AttackSpeed = 0.5;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 11;
		DmgPerAtk = 5.5;
		Health = 380;
		BuildCost = 1000;
		BuildTime = (60 * 1);
		XPGain = 10;
		Range = 10;
	};
	
	Level_2 = {
		DmgPerSec = 15;
		DmgPerAtk = 7.5;
		Health = 420;
		BuildCost = 2000;
		BuildTime = (60 * 2);
		XPGain = 20;
		Range = 10;
	};
	
	Level_3 = {
		DmgPerSec = 19;
		DmgPerAtk = 9.5;
		Health = 460;
		BuildCost = 5000;
		BuildTime = (60 * 5);
		XPGain = 30;
		Range = 10;
	};
	
	Level_4 = {
		DmgPerSec = 25;
		DmgPerAtk = 12.5;
		Health = 500;
		BuildCost = 20000;
		BuildTime = (60 * 7) + 30;
		XPGain = 40;
		Range = 10;
	};
	
	Level_5 = {
		DmgPerSec = 30;
		DmgPerAtk = 15;
		Health = 540;
		BuildCost = 80000;
		BuildTime = (60 * 10);
		XPGain = 50;
		Range = 10;
	};
	
	Level_6 = {
		DmgPerSec = 35;
		DmgPerAtk = 17.5;
		Health = 580;
		BuildCost = 180000;
		BuildTime = (60 * 15);
		XPGain = 60;
		Range = 10;
	};
	
	Level_7 = {
		DmgPerSec = 42;
		DmgPerAtk = 21;
		Health = 630;
		BuildCost = 360000;
		BuildTime = (60 * 25);
		XPGain = 70;
		Range = 10;
	};
	
	Level_8 = {
		DmgPerSec = 48;
		DmgPerAtk = 24;
		Health = 690;
		BuildCost = 600000;
		BuildTime = (60 * 35);
		XPGain = 80;
		Range = 10;
	};
	
	Level_9 = {
		DmgPerSec = 56;
		DmgPerAtk = 28;
		Health = 750;
		BuildCost = 800000;
		BuildTime = (60 * 45);
		XPGain = 90;
		Range = 10;
	};
	
	Level_10 = {
		DmgPerSec = 63;
		DmgPerAtk = 31.5;
		Health = 810;
		BuildCost = 1000000;
		BuildTime = (1 * 3600);
		XPGain = 100;
		Range = 10;
	};
	
	Level_11 = {
		DmgPerSec = 70;
		DmgPerAtk = 35;
		Health = 890;
		BuildCost = 1150000;
		BuildTime = (1 * 3600) * (60 * 15);
		XPGain = 110;
		Range = 10;
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
	
	return Hwacha[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
Hwacha.Name = "Hwacha"
Hwacha.UpgradeCost = UpgradeCost
Hwacha.UpgradeTime = UpgradeTime


--------------------------------------------------------
return Hwacha
