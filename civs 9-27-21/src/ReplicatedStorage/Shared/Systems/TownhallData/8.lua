--------------------------------------------------------
-- PineappleDoge1 | Townhall 8
-- 6-30-2021 | Prototype
-- Building Restrictions for Townhall 8
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {
	["Field Gun"] = {Level = 10, Amount = 5};
	["Hawacha"]  = {Level = 10, Amount = 5};
	["Gold Mine"] = {Level = 12, Amount = 6};
	["Soul Pump"] = {Level = 12, Amount = 6};
	["Gold Storage"] = {Level = 11, Amount = 3};
	["Soul Storage"] = {Level = 11, Amount = 3};
	["Landmine"] = {Level = 6, Amount = 6};
	["Barracks"] = {Level = 9, Amount = 4};
	["Camp Grounds"] = {Level = 6, Amount = 4};
	["Chapel"] = {Level = 8, Amount = 1};
	["Walls"] = {Level = 9, Amount = 225};
	["Slammer"] = {Level = 8, Amount = 2};
	["Fireworks"] = {Level = 4, Amount = 5};
	["Outpost"] = {Level = 8, Amount = 1};
	["Empire Tower"] = {Level = 5, Amount = 1};
	["Spell Launcher"] = {Level = 6, Amount = 3};
	["Flamethrower"] = {Level = 4, Amount = 1};
	["Petrol Bombs"] = {Level = 3, Amount = 4};
	["Spell Stirrer"] = {Level = 5, Amount = 1};
	["Catapult"] = {Level = 4, Amount = 2};
	["Crystal Furnace"] = {Level = 3, Amount = 1};
	["Hellfire"] = {Level = 4, Amount = 2};
	["Spire"] = {Level = 3, Amount = 1};
	["Poison Spikes"] = {Level = 3, Amount = 3};
	["Starbow"] = {Level = 2, Amount = 1};
}


--------------------------------------------------------
-- Runtime Code


--------------------------------------------------------
return ReturnTable