--[[
    ____  _                __            __ __  ____  ____  ____ ___
   / __ \(_)__________    / /  _____  __/ // /_/ __ \/ __ \/ __ <  /
  / / / / / ___/ ___(_)  / / |/_/ _ \/_  _  __/ / / / / / / / / / / 
 / /_/ / (__  ) /___    / />  </  __/_  _  __/ /_/ / /_/ / /_/ / /  
/_____/_/____/\___(_) _/_/_/|_|\___/ /_//_/_ \____/\____/\____/_/   

    ____        __    __                ____
   / __ \____  / /_  / /___  _  ___    / __/____     _____          
  / /_/ / __ \/ __ \/ / __ \| |/_(_)  / /_/ ___/    / ___/          
 / _, _/ /_/ / /_/ / / /_/ />  <_    / __(__  )    (__  )           
/_/ |_|\____/_.___/_/\____/_/|_(_)  /_/ /____/____/____/            
                                            /_____/                 
--]]

-- Variables
--- Services

local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local spr = require(ReplicatedStorage.SPR)

---- Values

local TI = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)

----- Objects
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local frame = script.Parent
local player = Players.LocalPlayer
local toLoad = {
	table.unpack(workspace.Default:GetChildren()),
	table.unpack(PlayerGui:WaitForChild("VillageUI"):GetDescendants())
}

-- Functions

local function Tween(obj, prop, length)
	local NTI
	if length ~= nil then
		NTI = TweenInfo.new(length, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	else
		NTI = TI
	end
	TS:Create(obj, NTI, prop):Play()
end

local function TweenInHUD()
	for _, parent in ipairs(frame.Parent.Parent.VillageUI.MainFrame.HUD:GetChildren()) do
		for _, child in ipairs(parent:GetChildren()) do
			if not child:IsA("UIAspectRatioConstraint") then
				workspace.Sounds.Hover:Play()
				--Tween(child.CutoutFrame, {Position = UDim2.new(0,0,0,0)})
				spr.target(child.CutoutFrame, 0.5, 3.5, {Position = UDim2.new(0,0,0,0)})
				wait(.05)
			end
		end
	end
end

local function BarLoad()
	local total = #toLoad
	workspace.Sounds.MainTheme:Play()
	
	for i, v in pairs(toLoad) do
		frame.BarFrame.Bar.Size = UDim2.new(i/total, 0, 1, 0)
		ContentProvider:PreloadAsync({v})
	end
	
	for i = 0.25, 0, -0.05 do
		workspace.Sounds.MainTheme.Volume = i
		wait(0.1)
	end
	
	Players.LocalPlayer:SetAttribute("Loaded", true)
	workspace.Sounds.MainTheme:Stop()
	
	Tween(frame, {Position = UDim2.new(-1, 0, 0, 0)})
	Tween(frame.Parent.Background, {ImageTransparency = 1})
	
	--wait(.5)
	
	workspace.Sounds.VillageTheme.Volume = 0
	workspace.Sounds.VillageTheme:Play()
	
	for i = 0, 0.25, 0.05 do
		workspace.Sounds.VillageTheme.Volume = i
		wait(0.1)
	end
	
	TweenInHUD()
end

-- Events
script.Parent.Parent.Enabled = true
local Rep = game:GetService("ReplicatedFirst")
Rep:RemoveDefaultLoadingScreen()
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
local Character = player.Character or player.CharacterAdded:Wait()

BarLoad()

