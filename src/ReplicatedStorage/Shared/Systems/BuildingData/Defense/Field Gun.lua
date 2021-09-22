--------------------------------------------------------
-- PineappleDoge1 | FieldGun
-- 6-12-2021 | Prototype
-- FieldGun data
--------------------------------------------------------
-- Module Setup
local FieldGun = {
	Description = "Shoots cannons at foes.";
	UnitTypeTargetted = "Grounded";
	DamageType = "Single Target";
	AttackSpeed = 0.8;
	CostType = "Currency";
	
	Level_1 = {
		DmgPerSec = 9;
		DmgPerAtk = 7.2;
		Health = 420;
		BuildCost = 250;
		BuildTime = 10;
		XPGain = 10;
		Range = 9;
	};
	
	Level_2 = {
		DmgPerSec = 11;
		DmgPerAtk = 8.8;
		Health = 470;
		BuildCost = 1000;
		BuildTime = (60 * 1);
		XPGain = 20;
		Range = 9;
	};
	
	Level_3 = {
		DmgPerSec = 15;
		DmgPerAtk = 12;
		Health = 520;
		BuildCost = 4000;
		BuildTime = (60 * 2);
		XPGain = 30;
		Range = 9;
	};
	
	Level_4 = {
		DmgPerSec = 19;
		DmgPerAtk = 15.2;
		Health = 570;
		BuildCost = 16000;
		BuildTime = (60 * 5);
		XPGain = 40;
		Range = 9;
	};
	
	Level_5 = {
		DmgPerSec = 25;
		DmgPerAtk = 20;
		Health = 620;
		BuildCost = 50000;
		BuildTime = (60 * 7) + 30;
		XPGain = 50;
		Range = 9;
	};
	
	Level_6 = {
		DmgPerSec = 31;
		DmgPerAtk = 24.8;
		Health = 670;
		BuildCost = 100000;
		BuildTime = (60 * 10);
		XPGain = 60;
		Range = 9;
	};
	
	Level_7 = {
		DmgPerSec = 40;
		DmgPerAtk = 32;
		Health = 730;
		BuildCost = 200000;
		BuildTime = (60 * 15);
		XPGain = 70;
		Range = 9;
	};
	
	Level_8 = {
		DmgPerSec = 48;
		DmgPerAtk = 38.4;
		Health = 800;
		BuildCost = 400000;
		BuildTime = (60 * 25);
		XPGain = 80;
		Range = 9;
	};
	
	Level_9 = {
		DmgPerSec = 56;
		DmgPerAtk = 44.8;
		Health = 880;
		BuildCost = 600000;
		BuildTime = (60 * 35);
		XPGain = 90;
		Range = 9;
	};
	
	Level_10 = {
		DmgPerSec = 64;
		DmgPerAtk = 51.2;
		Health = 960;
		BuildCost = 800000;
		BuildTime = (60 * 45);
		XPGain = 100;
		Range = 9;
	};
	
	Level_11 = {
		DmgPerSec = 74;
		DmgPerAtk = 59.2;
		Health = 1060;
		BuildCost = 1000000;
		BuildTime = (1 * 3600);
		XPGain = 110;
		Range = 9;
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
	
	return FieldGun[Level]
end

local function UpgradeCost(lvl)
	return IndexLevel(lvl).BuildCost
end

local function UpgradeTime(lvl)
	return IndexLevel(lvl).BuildTime
end


--------------------------------------------------------
-- Private Functions
FieldGun.Name = "Field Gun"
FieldGun.UpgradeCost = UpgradeCost
FieldGun.UpgradeTime = UpgradeTime


--------------------------------------------------------
return FieldGun
