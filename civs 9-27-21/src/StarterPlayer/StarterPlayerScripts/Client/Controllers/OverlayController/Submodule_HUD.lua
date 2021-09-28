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
local SPR = require(REPLICATED_STORAGE.SPR)
local Knit = require(REPLICATED_STORAGE.Shared:WaitForChild("Knit"))
local Promise = require(Knit.Util.Promise)
local Flipper = require(Knit.SharedModules.Flipper)
local BuildingData = require(Knit.SharedSystems.BuildingData)
local TownhallData = require(Knit.SharedSystems.TownhallData)

local SelectionController = Knit.Controllers['SelectionController']
local IdentifyController = Knit.Controllers['IdentifyController']


--------------------------------------------------------
-- GUI
local VillageUI = PlayerGUI.VillageUI.MainFrame
local HUD = VillageUI.HUD
local Settings = VillageUI.Settings.CutoutFrame
local Build = VillageUI.Build.CutoutFrame


--------------------------------------------------------
-- Functions
local function GetModelData(Model)
	local Str = Model.Name
	local StrTbl = string.split(Str, " Level")

	return {
		Name = StrTbl[1];
		Level = StrTbl[2]
	}
end

local function Tween(obj, prop, length)
	local NTI: TweenInfo
	local TI = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	
	if length ~= nil then
		NTI = TweenInfo.new(length, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	else
		NTI = TI
	end
	
	TWEEN_SERVICE:Create(obj, NTI, prop):Play()
end

local function HideOtherUI()
	SPR.target(Settings.MainFrame, 1, 5.5, {Position = UDim2.fromScale(0, 1)})
	SPR.target(Build.MainFrame.ExtraFrame, 1, 5.5, {Position = UDim2.fromScale(0, 1)})
	Settings.MainFrame:SetAttribute("Toggled", false)
	Build.MainFrame.ExtraFrame:SetAttribute("Toggled", false)
end

local function ButtonEnter(obj)
	workspace.Sounds.Hover:Play()
	if obj.Parent.Name == "BottomLeft" then
		Tween(obj, {Rotation = 5})
	end

	if obj.Parent.Name == "BottomRight" then
		Tween(obj, {Rotation = -5})
	end
end

local function ButtonLeave(obj)
	if obj.Parent.Name == "BottomLeft" or "BottomRight" then
		Tween(obj, {Rotation = 0})
	end
end

local function ButtonClick(obj, x, y)
	workspace.Sounds.Click:Play()
	workspace.Sounds.Swipe:Play()

	Tween(obj, {Size = obj.Size - UDim2.new(0.003, 0, 0.003, 0)}, 0.1)
	task.wait(0.1)
	Tween(obj, {Size = obj.Size + UDim2.new(0.003, 0, 0.003, 0)}, 0.1)

	HideOtherUI()
	task.wait(0.05)

	if obj.Name == "Settings" then
		if Settings.MainFrame:GetAttribute("Toggled") == false or nil then 
			SPR.target(Settings.MainFrame, 0.9, 4.5, {Position = UDim2.fromScale(0, 0)})
			Settings.MainFrame:SetAttribute("Toggled", true)
			task.delay(2, function()
				SPR.stop(Settings.MainFrame)
			end)
		else
			SPR.target(Settings.MainFrame, 0.9, 4.5, {Position = UDim2.fromScale(0, 1)})
			Settings.MainFrame:SetAttribute("Toggled", false)
			task.delay(2, function()
				SPR.stop(Settings.MainFrame)
			end)
		end
		
		SPR.target(Settings.MainFrame, 0.9, 4.5, {Position = UDim2.new(0, 0, 0, 0)})
	elseif obj.Name == "Build" then
		if Build.MainFrame.ExtraFrame:GetAttribute("Toggled") == false or nil then 
			SPR.target(Build.MainFrame.ExtraFrame, 0.9, 4.5, {Position = UDim2.fromScale(0, 0)})
			Build.MainFrame.ExtraFrame:SetAttribute("Toggled", true)
			task.delay(1.75, function()
				SPR.stop(Build.MainFrame.ExtraFrame)
			end)
		else 
			SPR.target(Build.MainFrame.ExtraFrame, 0.9, 4.5, {Position = UDim2.fromScale(0, 1)})
			Build.MainFrame.ExtraFrame:SetAttribute("Toggled", false)
			task.delay(1.75, function()
				SPR.stop(Build.MainFrame.ExtraFrame)
			end)
		end
	end
end


--------------------------------------------------------
-- Module
local Module = {
	Connections = {}
}

function Module:Initialize()
	self.Buttons = {}
	local ClassEvents = {
		["MouseEnter"] = ButtonEnter, 
		["MouseLeave"] = ButtonLeave,
		["MouseButton1Click"] = ButtonClick
	}

	for _, frames in ipairs(HUD:GetChildren()) do
		for _, button in ipairs(frames:GetChildren()) do
			if button:IsA("ImageButton") then
				table.insert(self.Buttons, button)
			end
		end
	end

	-- Events

	for name, button in ipairs(self.Buttons) do
		for index, func in pairs(ClassEvents) do
			if button[index] ~= nil then
				button[index]:Connect(function()
					func(button)
				end)
			end
		end
	end
end

return Module

--[[


---- Values

local TI = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)

----- Objects

local frame = script.Parent
local player = Players.LocalPlayer
local mouse = player:GetMouse()

------ Arrays

-- Functions
]]