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

-- Cleaned up by PineappleDoge, thank me for your reading convenience
-- - PineappleDoge
--------------------------------------------------------
-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 20)

script.Parent.Parent.Enabled = true
script.Parent.Parent.Parent = PlayerGui
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
ReplicatedFirst:RemoveDefaultLoadingScreen()


--------------------------------------------------------
-- Objects
local TI = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
local SPR = require(script.Parent.SPR)
local IntroUI = script.Parent.Parent
local MainFrame = script.Parent
script.Parent.SPR:Destroy()

local VillageTheme = script:WaitForChild("VillageTheme", math.huge)
local MenuTheme = script:WaitForChild("MainTheme", math.huge)


--------------------------------------------------------
-- Functions
local function Tween(obj, prop, length)
	local NTI
	
	if length ~= nil then
		NTI = TweenInfo.new(length, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	else
		NTI = TI
	end
	
	TweenService:Create(obj, NTI, prop):Play()
end

local function TweenInHUD()
	local PlayerGui = Players.LocalPlayer.PlayerGui
	
	for _, parent in ipairs(PlayerGui.VillageUI.MainFrame.HUD:GetChildren()) do
		for _, child in ipairs(parent:GetChildren()) do
			if not child:IsA("UIAspectRatioConstraint") then
				workspace.Sounds.Hover:Play()
				--Tween(child.CutoutFrame, {Position = UDim2.new(0,0,0,0)})
				SPR.target(child.CutoutFrame, 0.5, 4.5, {Position = UDim2.new(0,0,0,0)})
				task.wait(.05)
				
				task.delay(1.5, function()
					SPR.stop(child.CutoutFrame)
				end)
			end
		end
	end
	
	IntroUI:Destroy()
	script:Destroy()
end

local function BarLoad()
	MenuTheme:Play()
	local VillageUI = PlayerGui:WaitForChild("VillageUI", 2)
	
	if VillageUI == nil then 
		VillageUI = StarterGui.VillageUI:Clone()
		VillageUI.Parent = PlayerGui
	end
	
	local PreloadAssets = {
		table.unpack(VillageUI:WaitForChild("MainFrame", 15)
			:WaitForChild("HUD", 15)
			:GetChildren()
		);
		
		VillageUI.MainFrame.Build;
		VillageUI.MainFrame.Settings;
	}
	local total = #PreloadAssets
	
	for i, v in pairs(PreloadAssets) do
		MainFrame.BarFrame.Bar.Size = UDim2.new(i/total, 0, 1, 0)
		ContentProvider:PreloadAsync({v})
	end
	
	for i = 0.25, 0, -0.05 do
		MenuTheme.Volume = i
		task.wait(0.075)
	end
	
	Players.LocalPlayer:SetAttribute("Loaded", true)
	MenuTheme:Stop()
	
	Tween(MainFrame, {Position = UDim2.new(-1, 0, 0, 0)})
	Tween(MainFrame.Parent.Background, {ImageTransparency = 1})	
	VillageTheme.Volume = 0
	VillageTheme:Play()
	
	task.spawn(function()
		for i = 0, 0.25, 0.05 do
			VillageTheme.Volume = i
			task.wait(0.1)
		end
	end)
	
	TweenInHUD()
	StarterGui:SetCore("ResetButtonCallback", false)
end


--------------------------------------------------------
-- End
BarLoad()
