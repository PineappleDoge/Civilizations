--------------------------------------------------------
-- PineappleDoge1 | Townhall 5
-- 6-30-2021 | Prototype
-- Building Restrictions for Townhall 5
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {
	["Field Gun"] = {Level = 6, Amount = 3};
	["Hawacha"]  = {Level = 6, Amount = 3};
	["Gold Mine"] = {Level = 10, Amount = 5};
	["Soul Pump"] = {Level = 10, Amount = 5};
	["Gold Storage"] = {Level = 9, Amount = 2};
	["Soul Storage"] = {Level = 9, Amount = 2};
	["Landmine"] = {Level = 4, Amount = 4};
	["Barracks"] = {Level = 6, Amount = 3};
	["Camp Grounds"] = {Level = 5, Amount = 3};
	["Chapel"] = {Level = 5, Amount = 1};
	["Walls"] = {Level = 6, Amount = 125};
	["Slammer"] = {Level = 5, Amount = 2};
	["Fireworks"] = {Level = 3, Amount = 2};
	["Outpost"] = {Level = 5, Amount = 1};
	["Empire Tower"] = {Level = 2, Amount = 1};
	["Spell Launcher"] = {Level = 3, Amount = 1};
	["Flamethrower"] = {Level = 1, Amount = 1};
	["Petrol Bombs"] = {Level = 2, Amount = 2};
	["Spell Stirrer"] = {Level = 2, Amount = 1};
}


--------------------------------------------------------
-- Runtime Code


--------------------------------------------------------
return ReturnTable