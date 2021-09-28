--[[
--------------------------------------------------------
-- PineappleDoge | CanvasService
-- Handles creating/getitng player data on player join, alongside saving it on leave
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////

	CanvasService:SavePlayerCanvas(Player: Player, CanvasSlot: string | number)
		> Forcefully saves the player's canvas. If CanvasSlot ~= nil, save BaseData to a specific CanvasSlot
		
	CanvasService:LoadPlayerCanvas(Player: Player, CanvasSlot: string | number)
		> Loads BuildingData/Skin to a player's canvas. If CanvasSlot ~= nil, load a specific canvas slot
		
	CanvasService:EnableEditMode(Player: Player)
		> Enables Edit Mode for a player, which allows the player to manage their base
		> Return: Passed: boolean
		
		
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared.Knit)
local CanvasService = Knit.CreateService{
	Name = "CanvasService", Client = {}
}

local BuildingService: nil


-------------------------------------------------------------------------
-- Private Functions


-------------------------------------------------------------------------
-- CanvasService Properties
CanvasService.Prefix = "[CanvasService]:"
CanvasService.Connections = {}


-------------------------------------------------------------------------
-- CanvasService Functions
function CanvasService:LoadCanvas(Player: Player, CanvasSlot: string | number)
	
end

function CanvasService:SaveCanvas(Player: Player, CanvasSlot: string | number)
	
end

function CanvasService:EnableEditMode(Player: Player)
	
end



-------------------------------------------------------------------------
-- CanvasService Functions [Knit Start/Init]
function CanvasService:KnitInit()

end

function CanvasService:KnitStart()
	BuildingService = Knit.GetService("BuildingService")
end


-------------------------------------------------------------------------
-- CanvasService Functions [Client]
function CanvasService.Client:LoadCanvas(Player: Player, CanvasSlot: string | number)
	return self.Server:LoadCanvas(Player, CanvasSlot)
end

function CanvasService.Client:SaveCanvas(Player: Player, CanvasSlot: string | number)
	return self.Server:SaveCanvas(Player, CanvasSlot)
end

function CanvasService.Client:EnableEditMode(Player: Player)
	return self.Server.EnableEditMode(Player)
end


-------------------------------------------------------------------------
-- CanvasService Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return CanvasService