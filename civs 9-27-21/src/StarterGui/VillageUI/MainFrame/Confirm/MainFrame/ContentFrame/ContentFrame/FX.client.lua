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

-------------------------------------------------------------------------
-- PineappleDoge / BuildingService
-- Add a description here
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local SPR = require(REPLICATED_SERVICE.SPR)


-------------------------------------------------------------------------
-- Objects
local ButtonTable = {}
local Frames = {}
local frame = script.Parent
local train = frame.Parent.Parent.Parent.Parent.Train.MainFrame.ContentFrame
local speed = 0
local TI = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)


-------------------------------------------------------------------------
-- Function
function Tween(obj, prop, length)
	speed = length
	TS:Create(obj, TI, prop):Play()
end

local function TypeCheck()
	local att = frame.Parent:GetAttribute("Type")
	
	if att == "Train" then
		Tween(train.Fade, {BackgroundTransparency = 1}, 0.5)
	end
	
	frame.Parent:SetAttribute("Type", "")
end

local function ButtonClick(obj)
	SPR.target(frame.Parent, 1.25, 6, {
		Position = UDim2.fromScale(0, 1)
	})
	
	local function EndSpring()
		SPR.stop(frame.Parent)
	end
	
	task.delay(1, EndSpring)
	-- Tween(frame.Parent, {Position = UDim2.new(0,0,1,0)}, 0.5)

	TypeCheck()
end

local ClassEvents = {
	["MouseButton1Click"] = ButtonClick
}

for _, button in ipairs(frame:GetChildren()) do
	if button:IsA("ImageButton") then
		table.insert(Frames, button)
	end
end

-- Events

for name, button in ipairs(Frames) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button)
			end)
		end
	end
end