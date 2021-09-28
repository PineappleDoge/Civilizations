-------------------------------------------------------------------------
-- PineappleDoge / ControllerTemplate
-- Add a description here
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared.Knit)
local ControllerTemplate = Knit.CreateController{
	Name = "ControllerTemplate"
}


-------------------------------------------------------------------------
-- Private Functions


-------------------------------------------------------------------------
-- ControllerTemplate Properties
ControllerTemplate.Prefix = "[ControllerTemplate]:"
ControllerTemplate.Connections = {}


-------------------------------------------------------------------------
-- ControllerTemplate Functions
function ControllerTemplate:DoSomething(Player)
	print((self.Prefix .. " %s has done something!"):format(Player.Name))
end


-------------------------------------------------------------------------
-- ControllerTemplate Functions [Knit Start/Init]
function ControllerTemplate:KnitInit()

end

function ControllerTemplate:KnitStart()

end


-------------------------------------------------------------------------
-- ControllerTemplate Runtime Code [Pre-Knit Start/Init]
-- print(ControllerTemplate.Prefix, "has been initialized")


-------------------------------------------------------------------------
return ControllerTemplate