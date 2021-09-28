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
		
	BuildingService:SpawnPlayerBuildings(Player: Player, BaseData)
		> Loads in a player's base-data visually by spawning models 
		> Clears any former models on the base previously.
		
		
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
			--print("Running A")
		end,
	};
	['Defense'] = {
		Init = function(PlayerPacket: PlayerPacket_Update, BuildingPacket: BuildingPacket_Update)
			--print("Running D")
		end,
	};
	['Resources'] = {
		Init = function(PlayerPacket, BuildingPacket)
			--print("Running R")
			
			local LevelData = BuildingPacket.BuildingData[("Level_%s"):format(BuildingPacket.Level)]
			
			if (LevelData.Capacity ~= nil and LevelData.Production ~= nil) == true then -- Assume it's a generator
				--print("Generator Found")
				HandleCapacityUpdate(LevelData, PlayerPacket, BuildingPacket)
				HandleProductionUpdate(LevelData, PlayerPacket, BuildingPacket)
			elseif LevelData.Capacity ~= nil then -- Assume it's a storage unit
				HandleCapacityUpdate(LevelData, PlayerPacket, BuildingPacket)
			end
		end,
	};
	['Traps'] = {
		Init = function(PlayerPacket: PlayerPacket_Update, BuildingPacket: BuildingPacket_Update)
			--print("Running T")
		end,
	};
}
function FindModel(Player: Player, StructureID: string)
	for i, v in ipairs(workspace:FindFirstChild("CanvasPart" .. Player.UserId).Buildings:GetChildren()) do
		if v:GetAttribute("StructureID") == StructureID then
			return v
		end
	end
end

function HandleCapacityUpdate(LevelData, PlayerPacket, BuildingPacket)
	local EstimatedCapacity = (LevelData.Capacity) -- Replace with a formula that includes townhall capacity
	BuildingPacket.Model:SetAttribute("Capacity", LevelData.Capacity)
	
	for id, thing in pairs(PlayerPacket.BaseData.KnownStructures) do 
		if thing.Properties.Capacity ~= nil then 
			local Model = FindModel(PlayerPacket.Player, id)
			EstimatedCapacity += thing.Properties.Capacity 
			
			if Model ~= nil then 
				Model:SetAttribute("Capacity", thing.Properties.Capacity)
			end
		end
	end

	local UnserializedData = DataService:GetUnserializedPlayerData(PlayerPacket.Player)
	local MaxCurrencyObject = UnserializedData["Max" .. BuildingPacket.BuildingData.CostType]
	local CurrentCurrencyObject = UnserializedData[BuildingPacket.BuildingData.CostType]
	local Cache = CurrentCurrencyObject:Get()

	if MaxCurrencyObject ~= nil then 
		MaxCurrencyObject:Set(EstimatedCapacity)
	end

	if CurrentCurrencyObject ~= nil then 
		CurrentCurrencyObject:Set(math.min(Cache, EstimatedCapacity))
	end
end

function HandleProductionUpdate(LevelData, PlayerPacket, BuildingPacket)
	local Production = (LevelData.Production) -- Replace with a formula that includes townhall capacity
	BuildingPacket.Model:SetAttribute("Production", LevelData.Production)

	for id, thing in pairs(PlayerPacket.BaseData.KnownStructures) do 
		if thing.Properties.Production ~= nil then 
			local Model = FindModel(PlayerPacket.Player, id)
			local MinutelyProduction = thing.Properties.Production / 60 
			local LastLeaveSession = thing.LastLeave
			Production += thing.Properties.Production 
			
			-- Calculate the difference 
			if os.time() - LastLeaveSession > 0 then
				local TimeDifferenceSeconds = os.time() - LastLeaveSession
				-- print(("%s's time difference is:"):format(Model.Name), TimeDifferenceSeconds)
				local TotalAmount = thing.Properties.Capacity 
			end
			
			
			if Model ~= nil then 
				Model:SetAttribute("Production", thing.Properties.Production)
			end
		end
	end
end

function HandleBuildingUpdates(PlayerPacket, BuildingPacket)
	local Category = BuildingData:FindBuildingData(BuildingPacket.Name).Category
	if CategoryLookup[Category] ~= nil then
		CategoryLookup[Category].Init(PlayerPacket, BuildingPacket)
	end
end

function PlaceModelVisuals(Player, ModelClone, ModelData, BaseData)
	ModelClone:SetAttribute("Level", ModelData.Level)
	ModelClone:SetAttribute("StructureID", tostring(ModelData.Id))
	ModelClone:SetAttribute("Health", ModelData.Properties.Health)
	ModelClone:SetAttribute("BaseSize", ModelData.Size)
	ModelClone:SetPrimaryPartCFrame(CFrame.new(ModelData.X, ModelData.Y, ModelData.Z))
	ModelClone.Parent = workspace:WaitForChild("CanvasPart" .. Player.UserId):WaitForChild("Buildings")
	
	local PlayerPacket: PlayerPacket_Update = {
		['BaseData'] = BaseData;
		['Player'] = Player;
		['ID'] = Player.UserId;
	}

	local BuildingPacket: BuildingPacket_Update = {
		['Name'] = MiscFunctions.GetModelData(ModelClone).Name;
		['Level'] = MiscFunctions.GetModelData(ModelClone).Level;
		['Model'] = ModelClone;
		['BuildingData'] = BuildingData:FindBuildingData(ModelData.Name);
		['StructureData'] = ModelData;
	}
	
	HandleBuildingUpdates(PlayerPacket, BuildingPacket)
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
	--print(ModelStrData)
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
	
	--print("Server finished calculating", Result)
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

function BuildingService:SpawnPlayerBuildings(Player: Player, BaseData)
	local BuildingFolder = workspace:WaitForChild("CanvasPart" .. Player.UserId)
	BuildingFolder.Buildings:ClearAllChildren() -- Remove previous buildings
	
	for i, data in pairs(BaseData.KnownStructures) do
		local Position = BaseData.StructurePositions[data]
		local ModelName = ("%s Level %s"):format(data.Name, data.Level) 
		local ModelClone = MiscFunctions.CreateAssetCopy(ModelName)
		local WorldPos = DataService:GetUnserializedPlayerData(Player).Canvas:CellPositionToWorldPosition(Position)
		
		data.X, data.Y, data.Z = WorldPos.X, WorldPos.Y, WorldPos.Z
		task.spawn(PlaceModelVisuals, Player, ModelClone, data, BaseData)
	end
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