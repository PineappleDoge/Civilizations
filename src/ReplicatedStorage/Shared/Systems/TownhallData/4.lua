--------------------------------------------------------
-- PineappleDoge1 | Townhall 4
-- 6-30-2021 | Prototype
-- Building Restrictions for Townhall 4
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {
	["Field Gun"] = {Level = 5, Amount = 2};
	["Hawacha"]  = {Level = 5, Amount = 2};
	["Gold Mine"] = {Level = 8, Amount = 4};
	["Soul Pump"] = {Level = 8, Amount = 4};
	["Gold Storage"] = {Level = 8, Amount = 2};
	["Soul Storage"] = {Level = 8, Amount = 2};
	["Landmine"] = {Level = 4, Amount = 4};
	["Barracks"] = {Level = 5, Amount = 3};
	["Camp Grounds"] = {Level = 4, Amount = 2};
	["Chapel"] = {Level = 4, Amount = 1};
	["Walls"] = {Level = 5, Amount = 100};
	["Slammer"] = {Level = 4, Amount = 1};
	["Fireworks"] = {Level = 2, Amount = 2};
	["Outpost"] = {Level = 4, Amount = 1};
	["Empire Tower"] = {Level = 1, Amount = 1};
	["Spell Launcher"] = {Level = 2, Amount = 1};
}


--------------------------------------------------------
-- Runtime Code


--------------------------------------------------------
return ReturnTable