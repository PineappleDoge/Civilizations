--------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local TWEEN_SERVICE = game:GetService("TweenService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")

--------------------------------------------------------
-- Player Things
local Player = PLAYERS.LocalPlayer
local PlayerGUI = Player.PlayerGui
local VillageUI = PlayerGUI.VillageUI.MainFrame
local Selection = VillageUI.Selection.MainFrame
local ConfirmFrame = VillageUI.Confirm.MainFrame


--------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_STORAGE.Shared.Knit)
local Promise = require(Knit.Util.Promise)
local BuildingData = require(REPLICATED_STORAGE.Shared.Systems.BuildingData)
local TownhallData = require(REPLICATED_STORAGE.Shared.Systems.TownhallData)


--------------------------------------------------------
-- Functions
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

return {
	Train = function(Data)
		print("Train")
	end,
	
	Collect = function(Data)
		print("Collect")
	end,
	
	Upgrade = function(Data)
		local Connections = {}
		
		local function End(obj)
			if obj.UserInputType == Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch then
				for i, v in ipairs(Connections) do
					v:Disconnect()
					v = nil 
				end
			end
		end
		
		local function OnButtonClick(obj)
			if obj.UserInputType == Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch then
				End(obj)

				local function Success(results)
					print(results)
				end

				local function Failure(err)
					print(err)
				end
				
				
				Knit.GetController("UpgradeController"):UpgradeRequest(Data)
				:andThen(Success)
				:catch(Failure)
			end
		end
		
		local ModelCache = GetModelData(Data.Building)
		local StructureDataGlobal = BuildingData:FindBuildingData(ModelCache.Name)
		local StructureDataLevel = StructureDataGlobal[("Level_%s"):format(ModelCache.Level)]
		local StructureCost = StructureDataLevel.BuildCost
		
		ConfirmFrame.ContentFrame.ContentFrame.Amount.Text = StructureCost
		print("Number Set", ConfirmFrame.ContentFrame.ContentFrame.Amount, ConfirmFrame.ContentFrame.ContentFrame.Amount, Data)
		table.insert(Connections, ConfirmFrame.ContentFrame.ContentFrame.Confirm.Activated:Connect(OnButtonClick))
		table.insert(Connections, ConfirmFrame.ContentFrame.ContentFrame.Cancel.Activated:Connect(End))
	end,
	
	Cancel = function(Data)
		print("Cancel")
	end,
	
	Info = function(Data)
		print("Info")
	end,
}