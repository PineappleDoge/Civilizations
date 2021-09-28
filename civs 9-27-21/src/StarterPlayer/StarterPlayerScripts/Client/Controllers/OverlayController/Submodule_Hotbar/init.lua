--------------------------------------------------------
-- PineappleDoge | OverlayController
-- Date | Update Version
-- Description of what Controller does
--------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local TWEEN_SERVICE = game:GetService("TweenService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local USER_INPUT_SERVICE = game:GetService("UserInputService")


--------------------------------------------------------
-- Player Things
local Player = PLAYERS.LocalPlayer
local PlayerGUI = Player.PlayerGui
local PlayerScripts = Player:WaitForChild("PlayerScripts")


--------------------------------------------------------
-- Knit Setup
local Knit = require(REPLICATED_STORAGE.Shared:WaitForChild("Knit"))
local Options = require(script.Options)
local Promise = require(Knit.Util.Promise)

local SelectionController = Knit.Controllers['SelectionController']
local IdentifyController = Knit.Controllers['IdentifyController']
local VillageUI = PlayerGUI.VillageUI.MainFrame
local Selection = VillageUI.Selection.MainFrame
local ConfirmFrame = VillageUI.Confirm.MainFrame
local Buttons = Selection.ContentFrame.MiddleFrame.Buttons


--------------------------------------------------------
-- Functions
local function ClearSpaces(str)
	return str:gsub(" ", "")
end


--------------------------------------------------------
-- GUI


--------------------------------------------------------
-- Module
local Module = {}
Module.Connections = {}

function Module:Initialize()
	for _, button in ipairs(Buttons:GetChildren()) do
		if button:IsA("ImageButton") then
			local Button: ImageButton = button
			local Result = {
				Name = Button.Name;
				Data = {
					
				};
			}
			
			local SplitStr = string.split(Button.Name, "Upgrade")
			if string.find(Button.Name, "Upgrade") then
				Result.Name = "Upgrade"
				Result.Data.CostType = ClearSpaces(SplitStr[1])
				Result.Data.CostAmount = 500
			elseif string.find(Button.Name, "Collect") then
				SplitStr = string.split(Button.Name, "Collect")
				Result.Name = "Collect"
				Result.Data.CostType = ClearSpaces(SplitStr[1])
			end
			
			local function ButtonClicked()
				if Options[Result.Name] ~= nil then
					local func = Options[Result.Name]
					Result.Data.Building = SelectionController.SelectedBuilding
					func(Result.Data)
				end
			end
			
			Button.Activated:Connect(ButtonClicked)
		end
	end
end

return Module
