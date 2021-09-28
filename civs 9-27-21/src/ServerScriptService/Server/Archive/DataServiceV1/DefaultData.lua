local Knit = require(game.ReplicatedStorage.Shared.Knit)
local RemoteProperty = require(game.ReplicatedStorage.Shared.Knit.Util.Remote.RemoteProperty)

return function()
	local DefaultPlayerData = {
		CurrentEXP = RemoteProperty.new(0);
		CurrentLevel = RemoteProperty.new(1);

		Currency = RemoteProperty.new(script:GetAttribute("Currency") or 150); 
		MaxCurrency = RemoteProperty.new(script:GetAttribute("MaxCurrency") or 150); 
		Souls = RemoteProperty.new(script:GetAttribute("Souls") or 150), 
		MaxSouls = RemoteProperty.new(script:GetAttribute("MaxSouls") or 150); -- exeliar
		Crystals = RemoteProperty.new(script:GetAttribute("Crystals") or 200); -- crystals
	}

	local DefaultBuildingData = {
		{Name = "Town Hall", Level = 1, Skin = "Default", Amount = 1};
		{Name = "Constructor Hut", Level = 1, Skin = "Default", Amount = 2};
		{Name = "Field Gun", Level = 1, Skin = "Default", Amount = 1}
	}

	local BaseData = {
		UpgradingBuildings = {};
		QueueTime = 200; -- QueueTime is in seconds
	}

	return DefaultPlayerData, DefaultBuildingData, BaseData
end