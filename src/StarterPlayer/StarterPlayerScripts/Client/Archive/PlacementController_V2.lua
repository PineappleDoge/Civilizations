-------------------------------------------------------------------------
-- PineappleDoge / PlacementController
-- Add a description here
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local Signal = require(Knit.Util.Signal)
local PlacementController = Knit.CreateController{
	Name = "PlacementController"
}


-------------------------------------------------------------------------
-- Private Functions


-------------------------------------------------------------------------
-- ControllerTemplate Properties
PlacementController.Prefix = "[PlacementController]:"
PlacementController.Connections = {}
PlacementController.BuildingPlaced = Signal.new()


-------------------------------------------------------------------------
-- ControllerTemplate Functions
function PlacementController:DoSomething(Player)
	print((self.Prefix .. " %s has done something!"):format(Player.Name))
end


-------------------------------------------------------------------------
-- PlacementController Functions [Knit Start/Init]
function PlacementController:KnitInit()

end

function PlacementController:KnitStart()

end

function PlacementController:PlaceBuilding()
	
end

function PlacementController:CreateVisualClone(packet)
	local ModelRef = Knit.Assets:FindFirstChild(packet[1])
	local VisualClone = nil;
	
	if ModelRef ~= nil then
		print("Successfully cloned!")	
		VisualClone = ModelRef:Clone()
		VisualClone.Parent = workspace
	end
	
	print(packet, ModelRef, VisualClone)
	return VisualClone
end


-------------------------------------------------------------------------
-- PlacementController Runtime Code [Pre-Knit Start/Init]
-- print(PlacementController.Prefix, "has been initialized")



-------------------------------------------------------------------------
return PlacementController