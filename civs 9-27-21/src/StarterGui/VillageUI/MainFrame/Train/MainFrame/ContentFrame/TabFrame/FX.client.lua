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

local Players = game:GetService("Players")

---- Objects

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local frame = script.Parent
local current = "DefenseFrame"

----- Arrays

local ButtonTable = {}
local Frames = {}

------ Values

local middle = UDim2.new(0.044, 0, 0.071, 0)
local left = UDim2.new(-1, 0, 0.071, 0)
local right = UDim2.new(1.044, 0, 0.071, 0)

-- Functions

function Tween(obj, prop, speed)
	local TS = game:GetService("TweenService")
	local TI = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	TS:Create(obj, TI, prop):Play()
end

local function ButtonEnter(obj)
	if obj:GetAttribute("On") == false then
		Tween(obj.Parent.Parent[obj.Name], {BackgroundColor3 = Color3.fromRGB(100,100,100)}, 0.2)
	end
end

local function ButtonLeave(obj)
	if obj:GetAttribute("On") == false then
		Tween(obj.Parent.Parent[obj.Name], {BackgroundColor3 = Color3.fromRGB(57,57,57)}, 0.2)
	end
end

local function ButtonClick(obj, x, y)
	local circle = frame.Circle:Clone()
	circle.Parent = obj
	circle.Size = UDim2.new(0,1,0,1)
	circle.ImageTransparency = .5
	circle.ZIndex = 2

	local pos = UDim2.new(0, (x - obj.AbsolutePosition.X), 0, (y - obj.AbsolutePosition.Y))
	circle.Position = pos

	Tween(circle, {Size = UDim2.new(0, 250, 0, 250), ImageTransparency = 1}, .5)
	
	if obj:GetAttribute("On") == false then
		Tween(obj.Parent.Parent[obj.Name], {BackgroundColor3 = Color3.fromRGB(150,150,150)}, 0.2)
		
		for name, button in ipairs(Frames) do
			if button.Name ~= obj.Name then
				Tween(button.Parent.Parent[button.Name], {BackgroundColor3 = Color3.fromRGB(57,57,57)}, 0.2)
				button:SetAttribute("On", false)
			end
		end
		
		local name = obj.Name .. "Frame"
		
		if name == "ArmyFrame" then
			Tween(frame.Parent.ArmyFrame, {Position = UDim2.new(0.044,0,0.071,0)},0.5)
			Tween(frame.Parent.DefenseFrame, {Position = UDim2.new(1.044,0,0.071,0)},0.5)
			Tween(frame.Parent.ResourceFrame, {Position = UDim2.new(2.044,0,0.071,0)},0.5)
			Tween(frame.Parent.TrapsFrame, {Position = UDim2.new(3.044,0,0.071,0)},0.5)
		end
		
		if name == "DefenseFrame" then
			Tween(frame.Parent.ArmyFrame, {Position = UDim2.new(-1,0,0.071,0)},0.5)
			Tween(frame.Parent.DefenseFrame, {Position = UDim2.new(0.044,0,0.071,0)},0.5)
			Tween(frame.Parent.ResourceFrame, {Position = UDim2.new(1.044,0,0.071,0)},0.5)
			Tween(frame.Parent.TrapsFrame, {Position = UDim2.new(2.044,0,0.071,0)},0.5)
		end
		
		if name == "ResourceFrame" then
			Tween(frame.Parent.ArmyFrame, {Position = UDim2.new(-2,0,0.071,0)},0.5)
			Tween(frame.Parent.DefenseFrame, {Position = UDim2.new(-1,0,0.071,0)},0.5)
			Tween(frame.Parent.ResourceFrame, {Position = UDim2.new(0.044,0,0.071,0)},0.5)
			Tween(frame.Parent.TrapsFrame, {Position = UDim2.new(1.044,0,0.071,0)},0.5)
		end
		
		if name == "TrapsFrame" then
			Tween(frame.Parent.ArmyFrame, {Position = UDim2.new(-3,0,0.071,0)},0.5)
			Tween(frame.Parent.DefenseFrame, {Position = UDim2.new(-2,0,0.071,0)},0.5)
			Tween(frame.Parent.ResourceFrame, {Position = UDim2.new(-1,0,0.071,0)},0.5)
			Tween(frame.Parent.TrapsFrame, {Position = UDim2.new(0.044,0,0.071,0)},0.5)
		end
		
		obj:SetAttribute("On", true)
	end
end

local ClassEvents = {
	["MouseEnter"] = ButtonEnter, 
	["MouseLeave"] = ButtonLeave,
	["MouseButton1Click"] = ButtonClick
}

for _, button in ipairs(frame.Buttons:GetChildren()) do
	if button:IsA("ImageButton") then
		table.insert(Frames, button)
	end
end

-- Events

for name, button in ipairs(Frames) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button, mouse.X, mouse.Y)
			end)
		end
	end
end