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
local Flipper = require(Knit.SharedModules.Flipper)
local BuildingData = require(Knit.SharedSystems.BuildingData)
local TownhallData = require(Knit.SharedSystems.TownhallData)
local PlayerLevel = Player:GetAttribute("CurrentLevel")
local spr = require(REPLICATED_STORAGE.SPR)

local MiscFunctions = require(REPLICATED_STORAGE.Shared.Util.Miscellanous)
local ViewportModule = require(script.ViewportHelper)

local SelectionController = Knit.Controllers['SelectionController']
local PlacementController = Knit.Controllers['PlacementController']

local LockedLevel = "Level_" .. PlayerLevel
local TownhallLevel = TownhallData[LockedLevel]
local VillageUI = PlayerGUI.VillageUI.MainFrame
local Build = VillageUI.Build.CutoutFrame.MainFrame.ExtraFrame.ContentFrame
local NotifyBar = VillageUI.Build.NotifyBar
local CreateAssetCopy = require(Knit.Shared.Util.CreateAssetCopy)
ArmyConnections = {}
DefenseConnections = {}
ResourcesConnections = {}
TrapsConnections = {}


--------------------------------------------------------
-- Functions
function Tween(obj, prop, speed)
	local TI = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	TWEEN_SERVICE:Create(obj, TI, prop):Play()
end

function ButtonEnter(obj)
	Tween(obj.DB, {BackgroundColor3 = Color3.fromRGB(100,100,100)}, 0.2)
end

function ButtonLeave(obj)
	Tween(obj.DB, {BackgroundColor3 = Color3.fromRGB(57,57,57)}, 0.2)
end

function ErrorMessage(msg)
	NotifyBar.NotifyFrame.ContentFrame.Message.Text = msg
	Tween(NotifyBar.NotifyFrame, {Position = UDim2.new(0,0,0,0)}, 0.2)
	task.wait(2.5)
	Tween(NotifyBar.NotifyFrame, {Position = UDim2.new(0,0,-1,0)}, 0.2)
end

local function ButtonClick(obj)
	if obj:GetAttribute("Locked") == true then
		workspace.Sounds.Error:Play()
		ErrorMessage("Error: Building is not available at current townhall level!")
	else
		local StructureData = BuildingData:FindBuildingData(obj:GetAttribute("ItemName"))

		if StructureData ~= nil then
			local RemainingCurrency = Player:GetAttribute("Currency") - StructureData.Level_1.BuildCost
			
			if (RemainingCurrency >= 0) == true then
				local Results = PlacementController:BuyBuilding(obj:GetAttribute("ItemName"), 1)
				if Results.Passed == true then
					local ModelName = StructureData.Name .. " Level 1"
					local ModelAsset = CreateAssetCopy(ModelName)
					SelectionController:LinkBuildingToMouse(ModelAsset)
					workspace.Sounds.Swipe:Play()
					workspace.Sounds.Accept:Play()
					spr.target(VillageUI.Build.CutoutFrame.MainFrame.ExtraFrame, 1.25, 3.5, {Position = UDim2.fromScale(0, 1)})
					task.delay(1.5, function()
						spr.stop(VillageUI.Build.CutoutFrame.MainFrame.ExtraFrame)
					end)
				else
					workspace.Sounds.Error:Play()
					ErrorMessage(("Error: Promise Failed. Missing %s %s to purchase %s"):format(RemainingCurrency, StructureData.CostType, obj:GetAttribute("ItemName")))
				end
			else
				workspace.Sounds.Error:Play()
				ErrorMessage(("Error: Missing %s %s to purchase %s"):format(RemainingCurrency, StructureData.CostType, obj:GetAttribute("ItemName")))
			end
		else
			workspace.Sounds.Error:Play()
			ErrorMessage(("Error: Building model could not be found: %s"):format(tostring(obj:GetAttribute("ItemName"))))
		end
	end
end



--------------------------------------------------------
-- GUI
function CreateGuiClone(data)
	local GuiClone = Build.BaseTemplate:Clone()
	local GuiContent = GuiClone.Content
	local GuiIcon = GuiContent:FindFirstChild("Icon")
	
	if data.CostType == "Currency" then
		GuiIcon.Image = "rbxassetid://7080065691"
	elseif data.CostType == "Souls" then
		GuiIcon.Image = "rbxassetid://7080091044"
	elseif data.CostType == "Crystals" then
		GuiIcon.Image = "rbxassetid://7080095972"
	end

	local Model = MiscFunctions.CreateAssetCopy(data.Name .. " Level 1")
	if Model == nil then 
		Model = MiscFunctions.CreateAssetCopy("Barracks Level 1")
	end
	
	--[[
	GuiClone.Content.ViewportFrame:ClearAllChildren()
	Model.Parent = GuiClone.Content.ViewportFrame
	local Cam = Instance.new("Camera")
	Cam.Parent = GuiClone.Content.ViewportFrame
	GuiClone.Content.ViewportFrame.CurrentCamera = Cam 
	local ViewportClass = ViewportModule.new(GuiClone.Content.ViewportFrame, Cam)
	local cf, size = Model:GetBoundingBox()
	ViewportClass:SetModel(Model) 
	ViewportClass:Calibrate()
	
	local theta = 0
	local orientation = CFrame.new()
	orientation = CFrame.fromEulerAnglesYXZ(math.rad(-20), theta, 0)
	Cam.CFrame = ViewportClass:GetMinimumFitCFrame(orientation)]]
	
	if TownhallLevel[data.Name] == nil then
		GuiContent.Locked.Visible = true
		GuiContent.LockFade.Visible = true
		GuiClone:SetAttribute("Locked", true)
	else
		GuiClone:SetAttribute("Locked", false)
	end
	
	GuiContent:FindFirstChild("Amount").Text = data.Level_1.BuildCost
	GuiContent:FindFirstChild("Name").Text = data.Name
	GuiClone:SetAttribute("Price", data.Level_1.BuildCost)
	GuiClone:SetAttribute("ItemName", data.Name)
	return GuiClone
end


--------------------------------------------------------
-- Module
local Module = {}

function Module:Initialize()
	local i = 1
	
	local SubConnections = {'Army', 'Defense', 'Resources', 'Traps'}
	
	for _, category in ipairs(SubConnections) do
		for _, data in ipairs(BuildingData[string.lower(category)].array) do
			local GuiClone = CreateGuiClone(data)
			local TblName = category .. "Connections"
			GuiClone.Name = i
			GuiClone.Visible = true
			GuiClone.Parent = Build[category .. "Frame"]
			
			table.insert(getfenv()[TblName], GuiClone.MouseEnter:Connect(function()
				ButtonEnter(GuiClone)
			end))
			
			table.insert(getfenv()[TblName], GuiClone.MouseLeave:Connect(function()
				ButtonLeave(GuiClone)
			end))
			
			table.insert(getfenv()[TblName], GuiClone.MouseButton1Click:Connect(function()
				ButtonClick(GuiClone)
			end))
		end
		
		i = 1
		task.defer(function()
			-- Sort based on locked/unlocked
			local function GetChildren()
				local actualChildren = {}
				
				for i, v in ipairs(Build[category .. "Frame"]:GetChildren()) do
					if v:IsA("ImageButton") then
						table.insert(actualChildren, v)
					end
				end
				
				return actualChildren
			end
			
			local Children = GetChildren()
			local LockedButtons = {}
			local UnlockedButtons = {}
			local Locked, Unlocked = 0, 0
			
			for i, v in ipairs(Children) do
				if v:GetAttribute("Locked") == true then
					Locked += 1
					table.insert(LockedButtons, v)
				else
					Unlocked += 1
					table.insert(UnlockedButtons, v)
				end
			end
			
			local Sort1, Sort2 = {}, {}
			
			for i = 1, Unlocked do
				local button = UnlockedButtons[i]
				button.Name = i
				table.insert(Sort1, i, button)
			end
			
			for i = 1, Locked do
				local button = LockedButtons[i]
				button.Name = i + Unlocked
				table.insert(Sort2, i, button)
			end
		end)
	end
end

return Module

