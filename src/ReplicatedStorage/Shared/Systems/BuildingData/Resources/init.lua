--------------------------------------------------------
-- PineappleDoge1 | Resources Subtable
-- 6-30-2021 | Prototype
-- Caches building related to resources
--------------------------------------------------------
-- Table Setup
local Children = script:GetChildren()
local ReturnTable = {array = {}}


--------------------------------------------------------
-- Runtime Code
for index, child in ipairs(Children) do
	local Module = require(child)
	Module.Category = "Resources"
	ReturnTable[Module.Name] = Module
	table.insert(ReturnTable.array, Module)
end


--------------------------------------------------------
return ReturnTable