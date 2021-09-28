-------------------------------------------------------------------------
-- UnsuspectingSawblade / PlacementController
-- Handles the placement of items and canvas logic
-------------------------------------------------------------------------
-- Services
local RunService = game:GetService("RunService")
local ReplicatedService = game:GetService("ReplicatedStorage")


-------------------------------------------------------------------------
-- Knit
local Knit = require(ReplicatedService.Shared:WaitForChild("Knit"))
local Signal = require(Knit.Util.Signal)
local Promise = require(Knit.Util.Promise)
local Janitor = require(Knit.SharedModules.Janitor)
local PlacementController = Knit.CreateController{
	Name = "PlacementController"
}

local BuildingService = nil
local DataController = nil
local Canvas = require(Knit.Modules.Canvas)
local Flipper = require(Knit.Shared.Modules.Flipper)
local BuildingData = require(Knit.Shared.Systems.BuildingData)
local CreateAssetCopy = require(Knit.Shared.Util.CreateAssetCopy)


-------------------------------------------------------------------------
-- Private Functions
local CancelPlacing = Signal.new()
local PlaceStructure = Signal.new()
local PlacementStarted = Signal.new()

local PLACEMENT_SPRING_PROPERTIES = {
	frequency = 32,
	dampingRatio = 4,
}


-------------------------------------------------------------------------
-- PlacementController Properties
PlacementController.Prefix = "[PlacementController]:"
PlacementController.Connections = {}
PlacementController.Canvas = nil
PlacementController.PlacingMotor = Flipper.GroupMotor.new({X = 0, Y = 0, Z = 0})


-------------------------------------------------------------------------
-- PlacementController Functions
function PlacementController:PlaceBuilding(Model, Position)
	local NewPos = self.Canvas:CellPositionToWorldPosition(Position)
	local NewCFrame = CFrame.new(NewPos.X, NewPos.Y, NewPos.Z)
	Model:SetPrimaryPartCFrame(NewCFrame)
	return Promise.new(function(resolve, reject)
		local ClientPacket = {
			['Model'] = Model.Name,
			['Position'] = Position
		}
		
		local Results = BuildingService:PlaceBuilding(ClientPacket)
		--print("Client Received:", Results)
		if (Results == true) then
			Model:Destroy()
			resolve()
		elseif (Results == false) then
			Model:Destroy()
			reject()
		end
	end)
end

function PlacementController:MoveBuilding(Model, Position)
	local NewPos = self.Canvas:CellPositionToWorldPosition(Position)
	local NewCFrame = CFrame.new(NewPos.X, NewPos.Y, NewPos.Z)
	local OriginalPos = Model:GetPrimaryPartCFrame()
	Model:SetPrimaryPartCFrame(NewCFrame)

	return Promise.new(function(resolve, reject)
		local ClientPacket = {['Model'] = Model, ['Position'] = Position}
		local Results = BuildingService:MoveBuilding(ClientPacket)

		if (Results.PlacedCompleted == true) then
			resolve("Success")
		elseif (Results.PlacedCompleted == false or nil) then
			--print("setback")
			Model:SetPrimaryPartCFrame(OriginalPos)
			--print("chaned")
			reject("Error")
		end
	end)
end

function PlacementController:BuyBuilding(BuildingName, BuildingLevel)
	local ClientPacket = {['Name'] = BuildingName, ['Level'] = BuildingLevel}
	local Results = BuildingService:BuyBuilding(ClientPacket)
	return Results
end

function PlacementController:GetStructureData(StructureID)
	local UnserData = DataController:GetNewestUnserializedData()
	local SerData = DataController:GetPlayerData()
	local BaseData = UnserData.BaseData 
	
	if BaseData.KnownStructures[StructureID] ~= nil then
		local PositionData = BaseData.Structures[BaseData.KnownStructures[StructureID]]
		local KnownStructure = BaseData.KnownStructures[StructureID]
		PositionData = SerData.Canvas:CellPositionToWorldPosition(KnownStructure.Position)
		return PositionData, BaseData.KnownStructures[StructureID]
	end
end

function PlacementController:PlaceCurrentPlacement()
	PlaceStructure:Fire()
end

function PlacementController:CancelPlacement()
	CancelPlacing:Fire()
end

-------------------------------------------------------------------------
-- PlacementController Functions [Knit Start/Init]
function PlacementController:KnitInit()

end

function PlacementController:KnitStart()
	BuildingService = Knit.GetService("BuildingService")
	DataController = Knit.GetController("DataController")
	self.Canvas = DataController:GetPlayerData().Canvas
end


-------------------------------------------------------------------------
-- PlacementController Runtime Code [Pre-Knit Start/Init]
-- print(PlacementController.Prefix, "has been initialized")


-------------------------------------------------------------------------
return PlacementController