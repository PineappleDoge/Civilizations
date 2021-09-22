--[[
-------------------------------------------------------------------------
-- PineappleDoge / UpdateService
-- Handles internally updating upgrades in the server
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	UpdateService:AddBuilding(Player: Player, Data, ExecuteFunc)
		> Adds a building to the update queue, with an optional function to run when the timer completes
	
	UpdateService:RemoveBuilding(ID: string)
		> Removes a building with the associated ID from the update queue
		
	UpdateService:GetBuildings()
		> Returns buildings in the update queue


--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]
-------------------------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local RUN_SERVICE = game:GetService("RunService")
local HTTP_SERVICE = game:GetService("HttpService")
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared.Knit)
local Janitor = require(REPLICATED_SERVICE.Shared.Knit.Util.Janitor)
local UpdateService = Knit.CreateService{
	Name = "UpdateService", Client = {}
}


-------------------------------------------------------------------------
-- Private Functions
function UpdateBuildings(dt)
	for i, subtbl in ipairs(UpdateService.Buildings) do
		-- print(string.format("Building %s", i), subtbl, os.time() - subtbl.EndTime, os.time() - subtbl.EndTime >= 0)
		
		if os.time() - subtbl.EndTime >= 0 then
			table.remove(UpdateService.Buildings, i)
			warn("Finished")
			subtbl.Execute()
		end
	end
end

function AddBuilding(Player: Player, Data, ExecuteFunc)
	local ID = #UpdateService.Buildings + 1
	table.insert(UpdateService.Buildings, {
		ID = Data.ID;
		Execute = ExecuteFunc;
		PlayerID = Player.UserId;
		StartTime = Data.StartTime;
		EndTime = Data.EndTime;
		PlacementInTable = ID
	})
	
	return UpdateService.Buildings[ID], ID
end

function RemoveBuilding(ID: string)
	for i, subtbl in ipairs(UpdateService.Buildings) do
		if subtbl.ID == ID then
			table.remove(UpdateService.Buildings[i])
		end
	end
end

function PlayerLeave(Player: Player)
	if UpdateService.Connections[Player.UserId] ~= nil then
		UpdateService.Connections[Player.UserId].Janitor:Destroy()
	end
end


-------------------------------------------------------------------------
-- UpdateService Properties
UpdateService.Prefix = "[UpdateService]:"
UpdateService.Buildings = {}
UpdateService.Connections = {}


-------------------------------------------------------------------------
-- UpdateService Functions
function UpdateService:AddBuilding(Player, Data, ExecuteFunc)
	local BuildingResults, ID = AddBuilding(Player, Data, ExecuteFunc)
	
	if self.Connections[Player.UserId] == nil then
		local PlayerBuildings = {}
		local ID = 0
		PlayerBuildings.Buildings = {}
		PlayerBuildings.Janitor = Janitor.new()
		PlayerBuildings.Destroy = function()
			for i, v in ipairs(PlayerBuildings.Buildings) do
				if type(v) == "table" then
					table.remove(UpdateService.Buildings, v.PlacementInTable)
					table.remove(PlayerBuildings.Buildings, i)
				end
			end
		end
		
		PlayerBuildings.Janitor:Add(PlayerBuildings)
		
		table.insert(PlayerBuildings.Buildings, BuildingResults)
		self.Connections[Player.UserId] = PlayerBuildings
	else 
		table.insert(self.Connections[Player.UserId], BuildingResults)
	end
end

function UpdateService:RemoveBuilding(ID: string)
	RemoveBuilding(ID)
end

function UpdateService:GetBuildings()
	return self.Buildings
end


-------------------------------------------------------------------------
-- UpdateService Functions [Knit Start/Init]
function UpdateService:KnitInit()
	
end

function UpdateService:KnitStart()
	self.Connections['PlayerLeave'] = PLAYERS.PlayerRemoving:Connect(PlayerLeave)
	self.Connections['UpdateLoop'] = RUN_SERVICE.Heartbeat:Connect(UpdateBuildings)
end


-------------------------------------------------------------------------
-- UpdateService Functions [Client]
function UpdateService.Client:DoSomething(Player)
	return nil 
end


-------------------------------------------------------------------------
-- UpdateService Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return UpdateService