-------------------------------------------------------------------------
-- PineappleDoge / IdentifyController
-- Add a description here
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local BuildingData = require(Knit.SharedSystems.BuildingData)
local TownhallData = require(Knit.SharedSystems.TownhallData)
local IdentifyController = Knit.CreateController{
	Name = "IdentifyController"
}

local PossibleIdentities = {
	'Boost', 'Train', 'Speed Up', 'Collect', 'Brew', 'Empire', 'Research', 'Upgrade'
}


-------------------------------------------------------------------------
-- Private Functions
function GetModelData(Model)
	local Str = Model.Name
	local StrTbl = string.split(Str, " Level")

	return {
		Name = StrTbl[1];
		Level = StrTbl[2]
	}
end


local IdentifyFunctions = {
	['Boost'] = function(data, model)
		local SmallOptions = {
			["Gold Mine"] = true, 
			["Soul Pump"] = true, 
			["Crystal Furnace"] = true, 
			["Spire"] = true, 
			["Chapel"] = true, 
			["Spell Stirrer"] = true
		}
		if SmallOptions[data.Name] ~= nil then
			return true
		end
		
		return false
	end,
	
	['Upgrade'] = function(data, model)
		local ModelData = GetModelData(model)
		local Townhall = TownhallData[game.Players.LocalPlayer:GetAttribute("CurrentLevel")]
		
		if Townhall ~= nil then
			if Townhall[ModelData.Name] ~= nil then
				local MaxLevel = TownhallData[9][ModelData.Name].Level
				if tostring(ModelData.Level) < tostring(MaxLevel) then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end,
	
	['Train'] = function(data, model)
		local ModelData = GetModelData(model)
		local IDS = {['Barracks'] = true, ['Camp Grounds'] = true}
		
		if IDS[ModelData.Name]  then
			return true
		else
			return false
		end
	end,
	
	
	['Collect'] = function(data, model)
		local ModelData = GetModelData(model)
		local IDS = {['Soul Pump'] = true, ['Gold Mine'] = true, ['Crystal Furnace'] = true}
		
		if IDS[ModelData.Name]  then
			return true
		else
			return false
		end
	end,
}

function FindOptions(model)
	local Options = {'army', 'defense', 'resources', 'traps'}
	local TBL = {Info = true, Cancel = true}
	local ModelData = GetModelData(model)
	local data = BuildingData:FindBuildingData(ModelData.Name)
	
	for _, v in pairs(PossibleIdentities) do
		if IdentifyFunctions[v] ~= nil then
			TBL[v] = IdentifyFunctions[v](data, model)
		end
	end
	
	return TBL
end


-------------------------------------------------------------------------
-- IdentifyController Properties
IdentifyController.Buildings = {}
IdentifyController.Prefix = "[IdentifyController]:"
IdentifyController.Connections = {}


-------------------------------------------------------------------------
-- IdentifyController Functions
function IdentifyController:FindOptions(Model)
	return FindOptions(Model)
end


-------------------------------------------------------------------------
-- IdentifyController Functions [Knit Start/Init]
function IdentifyController:KnitInit()

end

function IdentifyController:KnitStart()

end


-------------------------------------------------------------------------
-- IdentifyController Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return IdentifyController

--[[
Town Hall - Info, Upgrade, Sceneries (need to make it xd)
Armoury - info, boost, upgrade, train
army camp- info, upgrade, train
generators - collect, upgrade, info, boost
storage - info, upgrade
defenses- info, upgrade 
traps - info, upgrade
spire - speed up, boost, upgrade, info
spell stirrer - info, boost, brew
empire tower - empire, upgrade, info
walls - upgrade, info
chapel - research, upgrade, info, boost

]]