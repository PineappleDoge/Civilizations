type StructureData = {Level: number, Skin: string}

local Knit = require(game.ReplicatedStorage.Shared.Knit)
local BaseData = require(game.ReplicatedStorage.Shared.Modules.BaseData)
local StructureData = require(game.ReplicatedStorage.Shared.Modules.StructureData)

return function()
	local DefaultPlayerData = {
		['CurrentEXP'] = 0;
		['CurrentLevel'] = 1;
		
		['Trophies'] = 0;
		['Currency'] = math.floor(script:GetAttribute("Currency") or 150, script:GetAttribute("MaxCurrency")); 
		['MaxCurrency'] = script:GetAttribute("MaxCurrency") or 150; 
		['Souls'] = script:GetAttribute("Souls") or 150, 
		['MaxSouls'] = script:GetAttribute("MaxSouls") or 150; -- exeliar
		['Crystals'] = script:GetAttribute("Crystals") or 200; -- crystals
		
		Settings = {
			['MutedSFX'] = false;
			['MutedMusic'] = false;
			['FancyGraphics'] = true;
			['FancyLighting'] = true;
			['Volume'] = 50;
			['ParticlesEnabled'] = false;
		}
	}
	
	local DefaultBuildingData = {
		StructureData.new("Town Hall", {Level = 1, Skin = "Default"}):Serialize();
		StructureData.new("Constructor Hut", {Level = 1, Skin = "Default"}):Serialize();
		StructureData.new("Constructor Hut", {Level = 1, Skin = "Default"}):Serialize();
	}
	
	local DefaultBaseData = BaseData.new():Serialize()
	
	return {
		['PlayerData'] = DefaultPlayerData,
		['BuildingData'] = DefaultBuildingData, 
		['BaseData'] = DefaultBaseData,
	}
end