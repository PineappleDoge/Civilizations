--------------------------------------------------------
-- PineappleDoge1 | Townhall 2
-- 6-30-2021 | Prototype
-- Building Restrictions for Townhall 2
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {
	["Barracks"] = {Level = 3, Amount = 2};
	["Field Gun"] = {Level = 3, Amount = 2};
	["Hawacha"]  = {Level = 3, Amount = 2};
	["Gold Mine"] = {Level = 4, Amount = 2};
	["Soul Pump"] = {Level = 4, Amount = 2};
	["Gold Storage"] = {Level = 3, Amount = 1};
	["Soul Storage"] = {Level = 3, Amount = 1};
	["Landmine"] = {Level = 2, Amount = 2};
	["Camp Grounds"] = {Level = 2, Amount = 1};
	["Chapel"] = {Level = 2, Amount = 1};
	["Walls"] = {Level = 3, Amount = 50};
	["Slammer"] = {Level = 2, Amount = 1};
}


--------------------------------------------------------
-- Runtime Code


--------------------------------------------------------
return ReturnTable