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

local spr = require(ReplicatedStorage.SPR)

---- Values

local TI = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)

----- Objects

local frame = script.Parent
local player = Players.LocalPlayer
local mouse = player:GetMouse()

------ Arrays

local Buttons = {}

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

local function Ripple(obj, x, y)
	local circle = frame.Circle:Clone()
	circle.Parent = obj.MainFrame
	circle.Size = UDim2.new(0,1,0,1)
	circle.ImageTransparency = .5
	circle.ZIndex = 2

	local pos = UDim2.new(0, (x - obj.AbsolutePosition.X), 0, (y - obj.AbsolutePosition.Y))
	circle.Position = pos

	Tween(circle, {Size = UDim2.new(0, 250, 0, 250), ImageTransparency = 1}, .5)
end

local function HideOtherUI()
	spr.target(frame.Parent.Settings.CutoutFrame.MainFrame, 0.9, 3.5, {Position = UDim2.new(0,0,1,0)})
	spr.target(frame.Parent.Build.CutoutFrame.MainFrame.ExtraFrame, 0.9, 3.5, {Position = UDim2.new(0,0,1,0)})
	wait(0.1)
end

local function ButtonClick(obj, x, y)
	workspace.Sounds.Click:Play()
	workspace.Sounds.Swipe:Play()
	
	Tween(obj, {Size = obj.Size - UDim2.new(0.003, 0, 0.003, 0)}, 0.1)
	wait(.1)
	Tween(obj, {Size = obj.Size + UDim2.new(0.003, 0, 0.003, 0)}, 0.1)
	
	HideOtherUI()
	
	if obj.Name == "Settings" then
		spr.target(frame.Parent.Settings.CutoutFrame.MainFrame, 0.9, 3.5, {Position = UDim2.new(0,0,0,0)})
	end
	
	if obj.Name == "Build" then
		spr.target(frame.Parent.Build.CutoutFrame.MainFrame.ExtraFrame, 0.9, 4.5, {Position = UDim2.new(0,0,0,0)})
	end
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

local ClassEvents = {
	["MouseEnter"] = ButtonEnter, 
	["MouseLeave"] = ButtonLeave,
	["MouseButton1Click"] = ButtonClick
}

for _, frames in ipairs(frame:GetChildren()) do
	for _, button in ipairs(frames:GetChildren()) do
		if button:IsA("ImageButton") then
			table.insert(Buttons, button)
		end
	end
end

-- Events

for name, button in ipairs(Buttons) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button, mouse.X, mouse.Y)
			end)
		end
	end
end