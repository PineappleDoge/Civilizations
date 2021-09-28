-------------------------------------------------------------------------
-- PineappleDoge / UpgradeController
-- Add a description here
-------------------------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local RUN_SERVICE = game:GetService("RunService")
local REPLICATED_SERVICE = game.ReplicatedStorage

local Player = PLAYERS.LocalPlayer


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared.Knit)
local Promise = require(Knit.Util.Promise)
local MiscFunctions = require(REPLICATED_SERVICE.Shared.Util.Miscellanous)
local TimeFormat = require(REPLICATED_SERVICE.Shared.Modules.TFMv2)
local BuildingData = require(REPLICATED_SERVICE.Shared.Systems.BuildingData)
local TownhallData = require(REPLICATED_SERVICE.Shared.Systems.TownhallData)
local UpgradeController = Knit.CreateController{
	Name = "UpgradeController"
}

local SelectionController = nil
local PlacementController = nil


-------------------------------------------------------------------------
-- Private Functions
function ClearSpaces(str)
	return str:gsub(" ", "")
end

function GetModelData(Model)
	local Str = Model.Name
	local StrTbl = string.split(Str, " Level")

	return {
		Name = StrTbl[1];
		Level = ClearSpaces(StrTbl[2])
	}
end

function VisualizeUpgrade(Building: Model, StructureData, StructureDataGlobal)
	local ModelCache = GetModelData(Building)
	-- Fence Model
	local FenceModel = REPLICATED_SERVICE.Shared.Assets:FindFirstChild(("%sx%s"):format(StructureDataGlobal.Size.X, StructureDataGlobal.Size.Y)):Clone()
	local BuildingCFrame = Building:GetPrimaryPartCFrame()
	FenceModel.PrimaryPart.Transparency = 1
	FenceModel:SetPrimaryPartCFrame(BuildingCFrame)
	FenceModel.Parent = Building
	
	SelectionController:DeselectBuilding()
	-- Timer Part + Timer
	local TimerPart = REPLICATED_SERVICE.Shared.Assets._TimerPart:Clone() 
	local TimerPartGui = TimerPart.PrimaryPart.Overhead.Frame
	local ConvertedTime = TimeFormat.Convert(os.time() + StructureData.BuildTime - os.time())
	local TimerString = ("%sd %sh %sm %ss")
	local TimerTable = {ConvertedTime.day, ConvertedTime.hr, ConvertedTime.min, ConvertedTime.sec}
	TimerPartGui:FindFirstChild("Timer").Text = TimerString:format(table.unpack(TimerTable))
	TimerPartGui:FindFirstChild("Name").Text = ModelCache.Name
	TimerPart:SetPrimaryPartCFrame(BuildingCFrame * CFrame.new(0, 5.95, 0))
	TimerPart.Parent = Building
	
	return {
		FenceModel = FenceModel, 
		TimerPart = TimerPart, 
		TimerPartGui = TimerPartGui}
end


-------------------------------------------------------------------------
-- UpgradeController Properties
UpgradeController.Prefix = "[UpgradeController]:"
UpgradeController.Buildings = {}
UpgradeController.Connections = {}
UpgradeController.Counter = 0


-------------------------------------------------------------------------
-- UpgradeController Functions
function UpgradeController:UpdateBuildingTimers(dt)
	if #self.Buildings == 0 then return end
	
	if math.fmod(self.Counter, 30) == 0 then -- Limit Update to 2FPS
		for i, subtbl in ipairs(self.Buildings) do
			local EndTime = subtbl.EndTime - os.time()
			local ConvertedTime = TimeFormat.Convert(EndTime)
			local TimerString = ("%sd %sh %sm %ss")
			local TimerTable = {ConvertedTime.day, ConvertedTime.hr, ConvertedTime.min, ConvertedTime.sec}
			
			if EndTime <= 0 then 
				table.remove(self.Buildings, i)
				subtbl.Completed()
				return
			end
			
			subtbl.GuiPart:FindFirstChild("Timer").Text = TimerString:format(table.unpack(TimerTable))
			subtbl.GuiPart:FindFirstChild("Name").Text = subtbl.Name
		end
	end
	
	self.Counter += 1 
	if self.Counter >= 60 then
		self.Counter = 0
	end
end

function UpgradeController:UpgradeRequest(Data)
	return Promise.new(function(resolve, reject)
		local ModelCache = GetModelData(Data.Building)
		local StructureDataGlobal = BuildingData:FindBuildingData(ModelCache.Name)
		local StructureDataLevel = StructureDataGlobal[("Level_%s"):format(ModelCache.Level)]
		local StructureCost = StructureDataLevel.BuildCost

		local ID = Data.Building:GetAttribute("StructureID")
		local IdValidation = ID ~= nil
		local CurrencyValidation = Player:GetAttribute("Currency") - StructureCost >= 0
		local TownhallValidation = tonumber(ModelCache.Level) < TownhallData[Player:GetAttribute("CurrentLevel")][ModelCache.Name].Level 
		
		if (IdValidation and CurrencyValidation and TownhallValidation) == true then
			-- Start the upgrade anyways
			local VisualizedTable = VisualizeUpgrade(Data.Building, StructureDataLevel, StructureDataGlobal)
			
			local function OnSuccess(Results)
				local BuildTime = StructureDataLevel.BuildTime 
				
				local UpdateTable = {
					ID = ID;
					Name = ModelCache.Name;
					Building = Data.Building;
					GuiPart = VisualizedTable.TimerPartGui;
					StartTime = Results.StartTime;
					EndTime = Results.EndTime;
					Completed = function()
						--[[local NewData = StructureDataGlobal[("Level_%s"):format(ModelCache.Level + 1)]
						local NewModel = MiscFunctions.CreateAssetCopy((ModelCache.Name .. " Level %s"):format(ModelCache.Level + 1))
						local PositionData, AB = PlacementController:GetStructureData(ID)
						local NewCFrame = CFrame.new(PositionData.X, PositionData.Y, PositionData.Z)
						NewModel:SetPrimaryPartCFrame(NewCFrame)
						NewModel.Parent = workspace
						
						PlacementController:PlaceBuilding(NewModel, AB.Position)
						:andThen(function()
							Data.Building:Destroy()
							print("Replaced the thing")
						end)
						:catch(function(err)
							print(err)
							NewModel:Destroy()
							print('failure')
						end)]]
						
						VisualizedTable.TimerPart:Destroy()
						VisualizedTable.FenceModel:Destroy()
					end,
				}
				
				table.insert(self.Buildings, UpdateTable)
				resolve('Success')
			end

			local function OnFailure(err)
				print(err)
				VisualizedTable.TimerPart:Destroy()
				VisualizedTable.FenceModel:Destroy()
				reject('Failure')
			end

			local function Manage(resolve, reject)
				local Success = Knit.GetService("UpgradeService"):UpgradeBuilding(ID)

				if Success.Passed == true then
					resolve(Success)
				else 
					reject("failed")
				end
			end
			
			Promise.new(Manage):andThen(OnSuccess):catch(OnFailure)
		else 
			reject("Failure")
		end
	end)
end


-------------------------------------------------------------------------
-- UpgradeController Functions [Knit Start/Init]
function UpgradeController:KnitInit()

end

function UpgradeController:KnitStart()
	PlacementController = Knit.GetController("PlacementController")
	SelectionController = Knit.GetController("SelectionController")
	self.Connections['UpgradeUpdater'] = RUN_SERVICE.Heartbeat:Connect(function(dt)
		self:UpdateBuildingTimers(dt)
	end)
	
end


-------------------------------------------------------------------------
-- UpgradeController Runtime Code [Pre-Knit Start/Init]
-- print(UpgradeController.Prefix, "has been initialized")


-------------------------------------------------------------------------
return UpgradeController