--------------------------------------------------------
-- PineappleDoge1 | Townhall 9
-- 6-30-2021 | Prototype
-- Building Restrictions for Townhall 9
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {
	["Field Gun"] = {Level = 11, Amount = 5};
	["Hawacha"]  = {Level = 11, Amount = 5};
	["Gold Mine"] = {Level = 12, Amount = 7};
	["Soul Pump"] = {Level = 12, Amount = 7};
	["Gold Storage"] = {Level = 11, Amount = 4};
	["Soul Storage"] = {Level = 11, Amount = 4};
	["Landmine"] = {Level = 6, Amount = 6};
	["Barracks"] = {Level = 10, Amount = 4};
	["Camp Grounds"] = {Level = 7, Amount = 4};
	["Chapel"] = {Level = 9, Amount = 1};
	["Walls"] = {Level = 10, Amount = 250};
	["Slammer"] = {Level = 9, Amount = 2};
	["Fireworks"] = {Level = 5, Amount = 5};
	["Outpost"] = {Level = 9, Amount = 1};
	["Empire Tower"] = {Level = 6, Amount = 1};
	["Spell Launcher"] = {Level = 7, Amount = 4};
	["Flamethrower"] = {Level = 5, Amount = 1};
	["Petrol Bombs"] = {Level = 4, Amount = 4};
	["Spell Stirrer"] = {Level = 5, Amount = 1};
	["Catapult"] = {Level = 5, Amount = 2};
	["Crystal Furnace"] = {Level = 4, Amount = 1};
	["Hellfire"] = {Level = 6, Amount = 2};
	["Spire"] = {Level = 4, Amount = 1};
	["Poison Spikes"] = {Level = 4, Amount = 4};
	["Starbow"] = {Level = 3, Amount = 2};
	["Shocker"] = {Level = 2, Amount = 2};
	["Ventilator"] = {Level = 3, Amount = 2};
}


--------------------------------------------------------
-- Runtime Code


--------------------------------------------------------
return ReturnTable