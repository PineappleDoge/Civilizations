--------------------------------------------------------
-- PineappleDoge | OverlayController
-- Date | Update Version
-- Description of what Controller does
--------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local TWEEN_SERVICE = game:GetService("TweenService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")


--------------------------------------------------------
-- Player Things
local Player = PLAYERS.LocalPlayer
local PlayerGUI = Player.PlayerGui
local PlayerScripts = Player:WaitForChild("PlayerScripts")


--------------------------------------------------------
-- Knit Setup
local Knit = require(REPLICATED_STORAGE.Shared:WaitForChild("Knit"))
local Promise = require(Knit.Util.Promise)
local Flipper = require(Knit.SharedModules.Flipper)
local BuildingData = require(Knit.SharedSystems.BuildingData)
local TownhallData = require(Knit.SharedSystems.TownhallData)

local SelectionController = Knit.Controllers['SelectionController']
local IdentifyController = Knit.Controllers['IdentifyController']
local VillageUI = PlayerGUI.VillageUI.MainFrame
local Selection = VillageUI.Selection.MainFrame
local ConfirmFrame = VillageUI.Confirm.MainFrame
local Presets = {frequency = 5.5, dampingRatio = 0.8}
local GoalMotor = Flipper.GroupMotor.new({
	X = 0, Y = 0
})


--------------------------------------------------------
-- Functions
function OnStep(values)
	Selection.ContentFrame.Position = UDim2.fromScale(values.X, values.Y)
end

function GoalCompleted()
	GoalMotor:stop()
end

function GetModelData(Model)
	local Str = Model.Name
	local StrTbl = string.split(Str, " Level")

	return {
		Name = StrTbl[1];
		Level = StrTbl[2]
	}
end

function SelectionEnabled(Model)
	local ModelData = GetModelData(Model)
	local ModelData2 = BuildingData:FindBuildingData(ModelData.Name)
	local MiddleFrame = Selection.ContentFrame.MiddleFrame
	local Options = IdentifyController:FindOptions(Model)
	
	for i, v in ipairs(MiddleFrame.Buttons:GetChildren()) do
		if v:IsA("ImageButton") then
			v.Visible = false
			
			if Options.Upgrade ~= nil then
				if ModelData2.CostType == "Currency" then
					Options['GoldUpgrade'] = true
				elseif ModelData2.CostType == "Souls" then
					Options['SoulUpgrade'] = true
				end
			end
			
			if Options.Collect ~= nil then
				if ModelData.Name == "Soul Pump" then
					Options['SoulCollect'] = true
				elseif ModelData.Name == "Gold Mine" then
					Options['GoldCollect'] = true
				elseif ModelData.Name == "Crystal Furnace" then
					Options['GemCollect'] = true
				end
			end
			
			if Options[v.Name] then
				v.Visible = Options[v.Name]
				if string.find(v.Name, "Upgrade") then
					if ModelData2["Level_" .. ModelData.Level + 1] ~= nil then
						v:FindFirstChild("MainFrame")
						:FindFirstChild("ContentFrame")
						:FindFirstChild("Amount").Text = ModelData2["Level_" .. ModelData.Level + 1].BuildCost
					else 
						v.Visible = false
					end
				end
			end
		end
	end
	
	MiddleFrame:FindFirstChild("Name").Text = ("%s Level %s"):format(ModelData.Name, ModelData.Level)
	GoalMotor:setGoal({
		X = Flipper.Spring.new(0, Presets);
		Y = Flipper.Spring.new(0, Presets)
	})
end

function SelectionDisabled(Model)
	GoalMotor:setGoal({
		X = Flipper.Spring.new(0, Presets);
		Y = Flipper.Spring.new(1, Presets)
	})
end


--------------------------------------------------------
-- GUI
GoalMotor:onStep(OnStep)


--------------------------------------------------------
-- Module
local Module = {}
Module.Connections = {}

function Module:Initialize()
	Selection.ContentFrame.Position = UDim2.fromScale(0, 1)
	Module.Connections['Selected'] = SelectionController.BuildingSelected:Connect(SelectionEnabled)
	Module.Connections['Deselected'] = SelectionController.BuildingDeselected:Connect(SelectionDisabled)
end

return Module
