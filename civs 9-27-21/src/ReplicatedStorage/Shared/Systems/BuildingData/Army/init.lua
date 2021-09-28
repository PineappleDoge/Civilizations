--------------------------------------------------------
-- PineappleDoge1 | Army Subtable
-- 6-30-2021 | Prototype
-- Caches building related to army
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {array = {}}


--------------------------------------------------------
-- Runtime Code
for index, child in ipairs(Children) do
	local Module = require(child)
	Module.Category = "Army"
	ReturnTable[Module.Name] = Module
	table.insert(ReturnTable.array, Module)
end


--------------------------------------------------------
return ReturnTable