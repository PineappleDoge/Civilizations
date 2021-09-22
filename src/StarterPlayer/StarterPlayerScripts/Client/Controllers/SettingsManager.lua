-------------------------------------------------------------------------
-- PineappleDoge / SettingsController
-- Add a description here
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local Signal = require(Knit.Util.Signal)
local SettingsController = Knit.CreateController{
	Name = "SettingsController"
}

local DataController = nil


-------------------------------------------------------------------------
-- Private Functions


-------------------------------------------------------------------------
-- SettingsController Properties
SettingsController.Prefix = "[SettingsController]:"
SettingsController.Settings = nil
SettingsController.SettingsInitialized = Signal.new()
SettingsController.Connections = {}
SettingsController.SettingsEvents = {}


-------------------------------------------------------------------------
-- SettingsController Functions
function SettingsController:Initialize()
	self.Settings = DataController:GetPlayerData().PlayerData.Settings
	
	for setting, value in pairs(self.Settings) do
		self.SettingsEvents[setting] = Signal.new()
		self.SettingsEvents[setting]:Fire(value)
	end
	
	self.SettingsInitialized:Fire()
end

function SettingsController:GetSetting(setting: string)
	if self.Settings == nil then
		self.SettingsInitialized:Wait()
	end
	
	return self.Settings[setting]
end

function SettingsController:ChangeSetting(setting: string, value: any?)
	if self.Settings[setting] == nil then
		warn(("No previous setting for %s, registering %s to %s..."):format(setting, setting, tostring(value)))
		self.Settings[setting] = value
		self.SettingsEvents[setting] = Signal.new()
		self.SettingsEvents[setting]:Fire(value)
	end
	
	self.Settings[setting] = value
	self.SettingsEvents[setting]:Fire(value)
end


-------------------------------------------------------------------------
-- SettingsController Functions [Knit Start/Init]
function SettingsController:KnitInit()

end

function SettingsController:KnitStart()
	DataController = Knit.Controllers["DataController"]
	self:Initialize()
end


-------------------------------------------------------------------------
-- SettingsController Runtime Code [Pre-Knit Start/Init]
-- print(SettingsController.Prefix, "has been initialized")


-------------------------------------------------------------------------
return SettingsController