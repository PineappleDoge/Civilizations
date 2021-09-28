-------------------------------------------------------------------------
-- PineappleDoge / ServiceTemplate
-- Add a description here
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local ServiceTemplate = Knit.CreateService{
	Name = "ServiceTemplate", Client = {}
}


-------------------------------------------------------------------------
-- Private Functions


-------------------------------------------------------------------------
-- ServiceTemplate Properties
ServiceTemplate.Prefix = "[ServiceTemplate]:"
ServiceTemplate.Connections = {}


-------------------------------------------------------------------------
-- ServiceTemplate Functions
function ServiceTemplate:DoSomething(Player)
	print((self.Prefix .. " %s has done something!"):format(Player.Name))
end


-------------------------------------------------------------------------
-- ServiceTemplate Functions [Knit Start/Init]
function ServiceTemplate:KnitInit()

end

function ServiceTemplate:KnitStart()

end


-------------------------------------------------------------------------
-- ServiceTemplate Functions [Client]
function ServiceTemplate.Client:DoSomething(Player)
	return self.Server:DoSomething(Player)
end


-------------------------------------------------------------------------
-- ServiceTemplate Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return ServiceTemplate