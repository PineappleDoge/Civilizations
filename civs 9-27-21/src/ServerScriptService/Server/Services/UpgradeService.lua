--[[
-------------------------------------------------------------------------
-- PineappleDoge / UpgradeService
-- Handles internally managing upgrades, removing/adding structureData for upgrades
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	UpgradeService:UpgradeBuilding(Player: Player, StructureID: string)
		> Adds a building to the update queue, with an optional function to run when the timer completes
		> Return: {Passed: boolean, StartTime: number, EndTime: number}
	
	UpgradeService:CompleteUpgrade(Player: Player, StructureID: string)
		> Replaces the provided structure with a structure with a higher level
		> Return: Passed: boolean
		
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]
type _Results = {Passed: boolean, StartTime: number, EndTime: number}
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared.Knit)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)
local UtilFunctions = require(REPLICATED_SERVICE.Shared.Util.Miscellanous)
local BuildingData = require(REPLICATED_SERVICE.Shared.Systems.BuildingData)
local TownhallData = require(REPLICATED_SERVICE.Shared.Systems.TownhallData)
local StructureData = require(REPLICATED_SERVICE.Shared.Modules.StructureData)
local UpgradeService = Knit.CreateService{
	Name = "UpgradeService", Client = {
		UpgradeComplete = RemoteSignal.new()
	}
}

local DataService = nil
local UpdateService = nil


-------------------------------------------------------------------------
-- Private Functions
function FindModel(Player: Player, StructureID: string)
	for i, v in ipairs(workspace:FindFirstChild("CanvasPart" .. Player.UserId).Buildings:GetChildren()) do
		if v:GetAttribute("StructureID") == StructureID then
			return v
		end
	end
end


-------------------------------------------------------------------------
-- UpgradeService Properties
UpgradeService.Prefix = "[UpgradeService]:"
UpgradeService.Connections = {}


-------------------------------------------------------------------------
-- UpgradeService Functions
function UpgradeService:UpgradeBuilding(Player: Player, StructureID: string)
	local Result = {Passed = false, StartTime = 0, EndTime = 0}
	
	local PlayerData = DataService:GetPlayerData(Player)
	local UnserPlayerData = DataService:GetUnserializedPlayerData(Player)
	local BaseData = UnserPlayerData.BaseData
	local Building = FindModel(Player, StructureID)
	local Structure = BaseData.KnownStructures[StructureID]
	
	if (Building == nil) or (Structure == nil) then
		print('Check1')
		return Result
	end
	
	local ModelCache = UtilFunctions.GetModelData(Building)
	local StructureData = BuildingData:FindBuildingData(ModelCache.Name)
	local StructureCost = StructureData[("Level_%s"):format(ModelCache.Level + 1)].BuildCost
	local CurrencyAmount = Player:GetAttribute(StructureData.CostType) - StructureCost
	local CostType = StructureData.CostType
	
	local IdValidation = Building:GetAttribute("StructureID") ~= nil
	local CurrencyValidation = CurrencyAmount >= 0
	local TownhallValidation = (TownhallData[Player:GetAttribute("CurrentLevel")][ModelCache.Name] ~= nil)
		and (tonumber(ModelCache.Level) < TownhallData[Player:GetAttribute("CurrentLevel")][ModelCache.Name].Level) == true
	
	if (IdValidation and CurrencyValidation and TownhallValidation) == false then 
		--print("Check2", IdValidation, CurrencyValidation, TownhallValidation)
		return Result
	end
	
	Structure.Upgrading = true
	Structure.UpgradeData = {
		StartTime = os.time();
		EndTime = os.time() + 10 --StructureData[("Level_%s"):format(ModelCache.Level + 1)].BuildTime;
	}
	
	Building:SetAttribute("Upgrading", true)
	UnserPlayerData[CostType]:Set(CurrencyAmount)
	Result.Passed = true
	Result.EndTime = Structure.UpgradeData.EndTime -- Structure.UpgradeData.EndTime
	Result.StartTime = Structure.UpgradeData.StartTime
	
	local function UpgradeComplete()
		self:CompleteUpgrade(Player, StructureID)
		self.Client.UpgradeComplete:Fire(Player, StructureID)
		Building:Destroy()
	end
	
	local MinimalisticTable = {
		StartTime = Structure.UpgradeData.StartTime;
		EndTime = Structure.UpgradeData.EndTime;
		ID = StructureID;
	}
	
	UpdateService:AddBuilding(Player, MinimalisticTable, UpgradeComplete)
	return Result
end

function UpgradeService:CompleteUpgrade(Player: Player, StructureID: string)
	local PlayerData = DataService:GetPlayerData(Player)
	local UnserPlayerData = DataService:GetUnserializedPlayerData(Player)
	local BaseData = UnserPlayerData.BaseData
	local CurrentStructure = BaseData.KnownStructures[StructureID]
	--print(CurrentStructure)
	local CurrentStructureData = BuildingData:FindBuildingData(CurrentStructure.Name)[("Level_%s"):format(CurrentStructure.Level)]
	local NewStructureData = BuildingData:FindBuildingData(CurrentStructure.Name)[("Level_%s"):format(CurrentStructure.Level + 1)]
	local Structure = StructureData.new(CurrentStructure.Name, {Level = CurrentStructure.Level + 1, Skin = "Default"})
	local Base = workspace["CanvasPart" .. Player.UserId]
	local ModelClone = Knit.Assets[("%s Level %s"):format(CurrentStructure.Name, CurrentStructure.Level + 1)]:Clone()
	
	BaseData:RemoveStructure(CurrentStructure)
	local Pos = CurrentStructure.Position
	local HitPos = DataService:GetUnserializedPlayerData(Player).Canvas:CellPositionToWorldPosition(Pos)
	local Result = BaseData:PlaceStructure(Structure, Pos)
	
	if Result == true then  
		ModelClone:SetAttribute("Health", CurrentStructure.Properties.Health)
		ModelClone:SetAttribute("BaseSize", CurrentStructure.Size)
		ModelClone:SetAttribute("Level", CurrentStructure.Level + 1)
		ModelClone:SetAttribute("StructureID", tostring(Structure.Id))
		ModelClone:SetPrimaryPartCFrame(CFrame.new(HitPos.X, HitPos.Y, HitPos.Z))
		ModelClone.Parent = Base.Buildings
	else 
		
	end
end


-------------------------------------------------------------------------
-- UpgradeService Functions [Knit Start/Init]
function UpgradeService:KnitInit()

end

function UpgradeService:KnitStart()
	DataService = Knit.GetService("DataService")
	UpdateService = Knit.GetService("UpdateService")
end


-------------------------------------------------------------------------
-- UpgradeService Functions [Client]
function UpgradeService.Client:UpgradeBuilding(Player: Player, StructureID)
	return self.Server:UpgradeBuilding(Player, StructureID)
end


-------------------------------------------------------------------------
-- UpgradeService Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return UpgradeService