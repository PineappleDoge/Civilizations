--------------------------------------------------------
-- PineappleDoge1 | Townhall 3
-- 6-30-2021 | Prototype
-- Building Restrictions for Townhall 3
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {
	["Barracks"] = {Level = 4, Amount = 2};
	["Field Gun"] = {Level = 4, Amount = 2};
	["Hawacha"]  = {Level = 4, Amount = 2};
	["Gold Mine"] = {Level = 6, Amount = 3};
	["Soul Pump"] = {Level = 6, Amount = 3};
	["Gold Storage"] = {Level = 6, Amount = 2};
	["Soul Storage"] = {Level = 6, Amount = 2};
	["Landmine"] = {Level = 2, Amount = 2};
	["Camp Grounds"] = {Level = 3, Amount = 2};
	["Chapel"] = {Level = 3, Amount = 1};
	["Walls"] = {Level = 4, Amount = 75};
	["Slammer"] = {Level = 3, Amount = 1};
	["Fireworks"] = {Level = 2, Amount = 2};
	["Outpost"] = {Level = 3, Amount = 1};
}


--------------------------------------------------------
-- Runtime Code


--------------------------------------------------------
return ReturnTable