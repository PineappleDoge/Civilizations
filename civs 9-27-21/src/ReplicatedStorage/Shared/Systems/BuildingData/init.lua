--------------------------------------------------------
-- PineappleDoge1 | BuildingData
-- 6-12-2021 | Prototype
-- Caches BuildingData and creates a nice API
--------------------------------------------------------
-- Services
local RUN_SERVICE = game:GetService("RunService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")


--------------------------------------------------------
-- Module Setup
local BuildingData = {}
BuildingData.Global = {}
BuildingData.Cached = false


--------------------------------------------------------
-- Knit
local Knit = require(game:GetService("ReplicatedStorage").Shared.Knit)
local Assets = Knit.Shared.Assets


--------------------------------------------------------
-- Private Functions
local function ClearSpaces(str)
	return str:gsub(" ", "")
end

local function DeepCopy(t)
	local copy = {}
	
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = DeepCopy(value)
		else
			copy[key] = value
		end
	end
	
	return copy
end

local function CalculateStructureSize(structureName: string)
	local structureAsset = Assets:FindFirstChild(string.format("%s Level 1", structureName))
	
	if not structureAsset then
		-- warn(string.format("Structure missing level 1 asset: %q", tostring(structureName)))
		return Vector2.new(1, 1)
	end
	
	local base = structureAsset.PrimaryPart or structureAsset:FindFirstChild("BuildingBase")
	if base.Name == "BuildingBase" then
		return Vector2.new(
			math.ceil(base.Size.X / 4 + 1),
			math.ceil(base.Size.Z / 4 + 1)
		)
	else
		--warn(("could not find size for %s"):format(structureName))
	end
end


--------------------------------------------------------
-- Class Functions
function BuildingData:Initialize()
	for index, child in ipairs(script:GetChildren()) do
		if child:IsA("ModuleScript") then
			local Results = require(child)
			local Name = string.lower(ClearSpaces(Results.Name or child.Name))
			
			-- Getting the internals
			for i, v in pairs(Results) do
				if i ~= "array" then
					local resultName =  string.lower(ClearSpaces(i))
					local buildingData = DeepCopy(v)
					if not buildingData.Size then
						buildingData.Size = CalculateStructureSize(i)
					end
					BuildingData[resultName] = buildingData
				end
			end
			
			BuildingData[Name] = Results
		end
	end
end

function BuildingData:FindBuildingData(name: string)
	local cleanName = string.lower(ClearSpaces(name))
	
	if BuildingData[cleanName] ~= nil then
		return BuildingData[cleanName]
	else
		warn("[BuildingData]: Could not find building name:", name)
	end
end

function BuildingData:GetAllBuildings()
	local returnTbl = {}
end

BuildingData.CalculateStructureSize = CalculateStructureSize
BuildingData:Initialize()


--------------------------------------------------------
return BuildingData