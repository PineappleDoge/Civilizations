-------------------------------------------------------------------------
-- stellar#4242 / Empire System
-- Add a description here
-------------------------------------------------------------------------
-- Services
local replicated_storage = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(replicated_storage.Shared:WaitForChild("Knit"))
local EmpireService = Knit.CreateService{
	Name = "EmpireService", Client = {}
}


-------------------------------------------------------------------------
-- Private Functions


-------------------------------------------------------------------------
-- ServiceTemplate Properties
EmpireService.Prefix = "[EmpireService]:"
EmpireService.Connections = {}


-------------------------------------------------------------------------
-- ServiceTemplate Functions
function EmpireService:DoSomething(Player)
	print((self.Prefix .. " %s has done something!"):format(Player.Name))
end


-------------------------------------------------------------------------
-- ServiceTemplate Functions [Knit Start/Init]
function EmpireService:KnitInit()

end

function EmpireService:KnitStart()

end

-------------------------------------------------------------------------
return EmpireService