--------------------------------------------------------
-- PineappleDoge1 | Traps Subtable
-- 6-30-2021 | Prototype
-- Caches building related to traps
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {array = {}}


--------------------------------------------------------
-- Runtime Code
for index, child in ipairs(Children) do
	local Module = require(child)
	Module.Category = "Traps"
	ReturnTable[Module.Name] = Module
	table.insert(ReturnTable.array, Module)
end


--------------------------------------------------------
return ReturnTable