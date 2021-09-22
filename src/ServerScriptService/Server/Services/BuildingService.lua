--[[
--------------------------------------------------------
-- PineappleDoge | BuildingService
-- Manages purchasing and placing buildings
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////

	BuildingService:BuyBuilding(Player: Player, CanvasSlot: string | number)
		> Purchases a building, creates a new StructureData and returns a new strcutureID 
		> Return: StructureID: string
		
	BuildingService:PlaceBuilding(Player: Player, StructureId: string)
		> Physically places a building in the game-world, and activates any generators
		
	BuildingService:MoveBuilding(Player: Player, ID: string)
		> Enables Edit Mode for a player, which allows the player to manage their base
		> Return: Passed: boolean
		
		
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]

type BuildingPacket_Update = {
	Name: string,
	Level: number | string,
	Model: Model,
	StructureData: any?,
	BuildingData: any?
}

type PlayerPacket_Update = {
	BaseData: any,
	Player: Player,
	ID: string | number
}

-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared.Knit)
local BuildingData = require(REPLICATED_SERVICE.Shared.Systems.BuildingData)
local StructureData = require(REPLICATED_SERVICE.Shared.Modules.StructureData)
local BuildingService = Knit.CreateService{
	Name = "BuildingService", Client = {}
}

local DataService = nil
local CanvasService = nil
local MiscFunctions = require(REPLICATED_SERVICE.Shared.Util.Miscellanous)


-------------------------------------------------------------------------
-- Functions
local CategoryLookup = {
	['Army'] = {
		Init = function(PlayerPacket: PlayerPacket_Update, BuildingPacket: BuildingPacket_Update)
			print("Running A")
		end,
	};
	['Defense'] = {
		Init = function(PlayerPacket: PlayerPacket_Update, BuildingPacket: BuildingPacket_Update)
			print("Running D")
		end,
	};
	['Resources'] = {
		Init = function(PlayerPacket, BuildingPacket)
			print("Running R")
			
			local LevelData = BuildingPacket.BuildingData[("Level_%s"):format(BuildingPacket.Level)]
			
			if (LevelData.Capacity ~= nil and LevelData.Production ~= nil) == true then -- Assume it's a generator
				-- Stuff
				print("Generator Found")
			elseif LevelData.Capacity ~= nil then -- Assume it's a storage unit
				print("Storage Found")
			end
		end,
	};
	['Traps'] = {
		Init = function(PlayerPacket: PlayerPacket_Update, BuildingPacket: BuildingPacket_Update)
			print("Running T")
		end,
	};
}

function HandleCategory(PlayerPacket, BuildingPacket)
	
end

function HandleBuildingUpdates(PlayerPacket, BuildingPacket)
	local Category = BuildingData:FindBuildingData(BuildingPacket.Name).Category
	if CategoryLookup[Category] ~= nil then
		CategoryLookup[Category].Init(PlayerPacket, BuildingPacket)
	end
end


-------------------------------------------------------------------------
-- BuildingService Properties
BuildingService.Prefix = "[BuildingService]:"
BuildingService.Connections = {}


-------------------------------------------------------------------------
-- BuildingService Functions
function BuildingService:BuyBuilding(Player, Packet)
	local ProfileData = DataService:GetPlayerData(Player)
	local PlayerData = ProfileData.PlayerData
	local BaseData = ProfileData.BaseData
	local BuildingInternals = BuildingData:FindBuildingData(Packet.Name)
	local CurrencyType = BuildingInternals.CostType
	local BuildCost = BuildingInternals["Level_" .. Packet.Level].BuildCost
	
	local CurrencyAmount = DataService:GetUnserializedPlayerData(Player)[CurrencyType]:Get()
	local RemainingCurrency = CurrencyAmount - BuildCost
	local Results = {Passed = false, ID = ""}

	if RemainingCurrency >= 0 then
		DataService:GetUnserializedPlayerData(Player)[CurrencyType]:Set(RemainingCurrency)
		Results.Passed = true
	else
		Results.Passed = false
	end

	return Results
end

function BuildingService:PlaceBuilding(Player: Player, Packet)
	local ProfileData = DataService:GetPlayerData(Player)
	local ReturnData = {PlacedCompleted = false}
	local PlayerData = ProfileData.PlayerData
	local BaseData = DataService:GetUnserializedPlayerData(Player).BaseData
	local Base = workspace["CanvasPart" .. Player.UserId]
	
	local ModelClone = Knit.Assets[Packet.Model]:Clone()
	local ModelStrData = (Packet.Model):split(" Level ")
	print(ModelStrData)
	local ModelStructure = StructureData.new(ModelStrData[1], {
		Level = MiscFunctions.ClearSpaces(ModelStrData[2]), 
		Skin = "Default"
	})
	
	local HitPos = DataService:GetUnserializedPlayerData(Player).Canvas:CellPositionToWorldPosition(Packet.Position)
	local Result = BaseData:PlaceStructure(ModelStructure, Packet.Position)

	if Result == true then  
		ModelClone:SetAttribute("Level", ModelStrData[2])
		ModelClone:SetAttribute("StructureID", tostring(ModelStructure.Id))
		ModelClone:SetAttribute("Health", ModelStructure.Properties.Health)
		ModelClone:SetAttribute("BaseSize", ModelStructure.Size)
		ModelClone:SetPrimaryPartCFrame(CFrame.new(HitPos.X, HitPos.Y, HitPos.Z))
		ModelClone.Parent = Base.Buildings
		
		local PlayerPacket: PlayerPacket_Update = {
			['BaseData'] = BaseData;
			['Player'] = Player;
			['ID'] = Player.UserId;
		}
		
		local BuildingPacket: BuildingPacket_Update = {
			['Name'] = MiscFunctions.GetModelData(ModelClone).Name;
			['Level'] = MiscFunctions.GetModelData(ModelClone).Level;
			['Model'] = ModelClone;
			['BuildingData'] = BuildingData:FindBuildingData(ModelStrData[1]);
			['StructureData'] = ModelStructure;
		}
		
		HandleBuildingUpdates(PlayerPacket, BuildingPacket)
	else
		ModelClone:Destroy()
	end
	
	print("Server finished calculating", Result)
	return Result 
end

function BuildingService:MoveBuilding(Player: Player, Packet)
	local ProfileData = DataService:GetPlayerData(Player)
	local UnserData = DataService:GetUnserializedPlayerData(Player)
	local PlayerData = ProfileData.PlayerData
	local BaseData = UnserData.BaseData
	local Base = workspace:FindFirstChild("CanvasPart" .. Player.UserId)
	
	local ModelStrData = (Packet.Model.Name):split("Level")
	local ModelStructure = BaseData.KnownStructures[Packet.Model:GetAttribute("StructureID")]

	local HitPos = UnserData.Canvas:CellPositionToWorldPosition(Packet.Position)
	local Result = BaseData:MoveStructure(ModelStructure, Packet.Position)
	local ReturnData = {PlacedCompleted = false}
	ReturnData.PlacedCompleted = Result
	
	if Result == true then  
		Packet.Model:SetPrimaryPartCFrame(CFrame.new(HitPos.X, HitPos.Y, HitPos.Z))
	end

	return ReturnData
end


-------------------------------------------------------------------------
-- BuildingService Functions [Knit Start/Init]
function BuildingService:KnitInit()

end

function BuildingService:KnitStart()
	DataService = Knit.GetService("DataService")
	CanvasService = Knit.GetService("CanvasService")
end


-------------------------------------------------------------------------
-- BuildingService Functions [Client]
function BuildingService.Client:PlaceBuilding(Player: Player, Packet)	
	return self.Server:PlaceBuilding(Player, Packet)
end

function BuildingService.Client:BuyBuilding(Player: Player, Packet)
	return self.Server:BuyBuilding(Player, Packet)
end

function BuildingService.Client:MoveBuilding(Player: Player, Packet)
	return self.Server:MoveBuilding(Player, Packet)
end


-------------------------------------------------------------------------
-- BuildingService Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return BuildingService