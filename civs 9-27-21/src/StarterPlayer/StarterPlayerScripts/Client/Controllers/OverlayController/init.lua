--------------------------------------------------------
-- PineappleDoge | OverlayController
-- Date | Update Version
-- Description of what Controller does
--------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")


--------------------------------------------------------
-- Player Things
local Player = PLAYERS.LocalPlayer
local PlayerGUI = Player.PlayerGui
local PlayerScripts = Player:WaitForChild("PlayerScripts")


--------------------------------------------------------
-- Knit Setup
local Knit = require(REPLICATED_STORAGE.Shared:WaitForChild("Knit"))
local FormatNumber = require(Knit.SharedModules.FormatNumber)
local Flipper = require(Knit.SharedModules.Flipper)
local OverlayController = Knit.CreateController{
	Name = "OverlayController"
}

local formatter = FormatNumber.NumberFormatter.with()

local DataController = nil

local CurrencyMotor = Flipper.GroupMotor.new({
	X = 0, Y = 0
})
local SoulsMotor = Flipper.GroupMotor.new({
	X = 0, Y = 0
})

local TestProps1 = {frequency = 3, dampingRatio = 0.75}


--------------------------------------------------------
-- GUI
local VillageUI = PlayerGUI.VillageUI
local HUD = VillageUI.MainFrame.HUD
local Currency = HUD.TopRight.Gold.CutoutFrame.MainFrame.ContentFrame
local Crystals = HUD.TopRight.Crystals.CutoutFrame.MainFrame.ContentFrame
local Souls = HUD.TopRight.Souls.CutoutFrame.MainFrame.ContentFrame


--------------------------------------------------------
-- Private Functions
function OnCurrencyChange()
	local MaxCurrency, CurrentCurrency = Player:GetAttribute("MaxCurrency"), Player:GetAttribute("Currency")
	
	Currency.Amount.Text = formatter:Format(CurrentCurrency)
end

function OnSoulsChange()
	local MaxSouls, CurrentSouls = Player:GetAttribute("MaxSouls"), Player:GetAttribute("Souls")

	Souls.Amount.Text = formatter:Format(CurrentSouls)
end

function OnCrystalsChange()
	local CurrentCrystals = Player:GetAttribute("Crystals")
	Crystals.Amount.Text = CurrentCrystals
end


--------------------------------------------------------
-- ControllerName Properties
OverlayController.Connections = {}
OverlayController.UpdateFunctions = {}


--------------------------------------------------------
-- ControllerName Methods
function OverlayController:Initialize()
	local Properties = DataController:GetPlayerData().PlayerData
	
	for i, v in pairs(Properties) do
		if i == "Settings" then continue end
		local Value = Player:GetAttribute(i)
		local FuncName = "On" .. i .. "Change"
		local Func = getfenv()[FuncName]
		
		if Func then
			Func()
			self.Connections[FuncName] = Player:GetAttributeChangedSignal(i):Connect(Func)
			table.insert(self.UpdateFunctions, Func)
		end
	end
end

function OverlayController:MassUpdateUI()
	for _, func in ipairs(self.UpdateFunctions) do
		func()
	end
end


--------------------------------------------------------
-- Runtime Code + Knit Methods
function OverlayController:KnitStart()
	DataController =  Knit.GetController("DataController")
	self:Initialize()
	
	local SubUIModules = {}
	task.defer(function()
		for _, module in ipairs(script:GetChildren()) do
			task.defer(function()
				if module:IsA("ModuleScript") then
					local requiredModule = require(module)
					
					if requiredModule.Initialize ~= nil then
						requiredModule:Initialize()
					end
					
					SubUIModules[module.Name] = requiredModule
				end
			end)
		end
	end)
	
	self.SubUIModules = SubUIModules
end


--------------------------------------------------------
return OverlayController