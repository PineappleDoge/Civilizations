--------------------------------------------------------
-- PineappleDoge1 | Townhall 6
-- 6-30-2021 | Prototype
-- Building Restrictions for Townhall 6
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {
	["Field Gun"] = {Level = 7, Amount = 3};
	["Hawacha"]  = {Level = 7, Amount = 3};
	["Gold Mine"] = {Level = 10, Amount = 6};
	["Soul Pump"] = {Level = 10, Amount = 6};
	["Gold Storage"] = {Level = 10, Amount = 2};
	["Soul Storage"] = {Level = 10, Amount = 2};
	["Landmine"] = {Level = 4, Amount = 4};
	["Barracks"] = {Level = 7, Amount = 3};
	["Camp Grounds"] = {Level = 6, Amount = 3};
	["Chapel"] = {Level = 6, Amount = 1};
	["Walls"] = {Level = 7, Amount = 175};
	["Slammer"] = {Level = 6, Amount = 2};
	["Fireworks"] = {Level = 3, Amount = 4};
	["Outpost"] = {Level = 6, Amount = 1};
	["Empire Tower"] = {Level = 3, Amount = 1};
	["Spell Launcher"] = {Level = 4, Amount = 1};
	["Flamethrower"] = {Level = 2, Amount = 1};
	["Petrol Bombs"] = {Level = 2, Amount = 2};
	["Spell Stirrer"] = {Level = 3, Amount = 1};
	["Catapult"] = {Level = 2, Amount = 1};
	["Crystal Furnace"] = {Level = 1, Amount = 1};
}


--------------------------------------------------------
-- Runtime Code


--------------------------------------------------------
return ReturnTable