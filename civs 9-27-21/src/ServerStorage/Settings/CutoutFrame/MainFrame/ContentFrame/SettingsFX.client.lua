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
local UIS = game:GetService("UserInputService")

local spr = require(ReplicatedStorage.SPR)

--- Objects

local localPlayer = Players.LocalPlayer
local frame = script.Parent
local mouse = localPlayer:GetMouse()
local slider = frame.ScrollingFrame.SoundsContent.Volume.Slider

---- Values

local TI = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)

local GreenColours = {Light = Color3.fromRGB(85, 255, 127), Dark = Color3.fromRGB(41, 125, 60)}
local GreyColours = {Light = Color3.fromRGB(255, 255, 255), Dark = Color3.fromRGB(56, 56, 56)}

local held = false
local debounce = false

local percent

local orgpos = slider.Button.AbsolutePosition.X

----- Arrays

local Switches = {}
local Sliders = {}
local Buttons = {}

-- Functions

function Tween(obj, prop, length)
	TS:Create(obj, TI, prop):Play()
end

function Ripple(obj, x, y)
	local circle = frame.Circle:Clone()
	circle.Parent = obj
	circle.Size = UDim2.new(0,1,0,1)
	circle.ImageTransparency = 0
	circle.ZIndex = 2

	local pos = UDim2.new(0, (x - obj.AbsolutePosition.X), 0, (y - obj.AbsolutePosition.Y))
	circle.Position = pos

	Tween(circle, {Size = UDim2.new(0, 50, 0, 50), ImageTransparency = 1}, .5)
end


local function SwitchToggle(obj)
	if debounce == false then
		debounce = true
		if obj:GetAttribute("Toggled") then
			spr.target(obj.Parent.Circle, 1.25, 8.5, {Position = UDim2.new(0.25,0,-0.024,0)})
			
			Tween(obj.Parent.Circle, {BackgroundColor3 = GreyColours.Light}, 0.1)
			Tween(obj.Parent.Bar, {BackgroundColor3 = GreyColours.Dark}, 0.1)
			
			task.wait(0.15)
			
			spr.stop(obj.Parent.Circle)
			obj:SetAttribute("Toggled", false)
		else
			spr.target(obj.Parent.Circle, 1.25, 8.5, {Position = UDim2.new(0.68,0,-0.024,0)})
		
			Tween(obj.Parent.Circle, {BackgroundColor3 = GreenColours.Light}, 0.1)
			Tween(obj.Parent.Bar, {BackgroundColor3 = GreenColours.Dark}, 0.1)
			
			task.wait(0.15)
			
			spr.stop(obj.Parent.Circle)
			obj:SetAttribute("Toggled", true)
		end
		debounce = false
	end
end

local function ButtonClick(obj, x, y)
	if obj.Parent.Name == "Switch" then
		SwitchToggle(obj)
	end
	
	if obj.Name == "Click" then
		Ripple(obj.Parent, x, y)
	end
	
	if obj.Name == "Close" then
		spr.target(frame.Parent, 0.75, 3.5, {Position = UDim2.new(0, 0, 1, 0)})
		wait(0.5)
		spr.stop(frame.Parent)
	end
end

local function MouseDown(obj)
	if obj.Parent.Name == "Button" then
		held = true
		Tween(slider.Button.Amount, {TextTransparency = 0, TextStrokeTransparency = 0}, 0.2)
	end
end

local function MouseUp(obj)
	held = false
	Tween(slider.Button.Amount, {TextTransparency = 1, TextStrokeTransparency = 1}, 0.2)
end

local ClassEvents = {
	["MouseButton1Click"] = ButtonClick,
	["MouseButton1Down"] = MouseDown
}

for _, layer in ipairs(frame.ScrollingFrame:GetChildren()) do
	if layer:IsA("Frame") then
		for _, slayer in ipairs(layer:GetChildren()) do
			if slayer:IsA("Frame") then
				if slayer:FindFirstChild("Switch") ~= nil then
					table.insert(Switches, slayer.Switch.Button)
				end
				
				if slayer:FindFirstChild("Slider") ~= nil then
					table.insert(Sliders, slayer.Slider.Button.Click)
				end
				
				if slayer:FindFirstChild("Button") ~= nil then
					table.insert(Buttons, slayer.Button.Click)
				end
			end
		end
	end
end

-- Events

for name, button in ipairs(Switches) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button)
			end)
		end
	end
end

for name, button in ipairs(Sliders) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button)
			end)
		end
	end
end

for name, button in ipairs(Buttons) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button, mouse.X, mouse.Y)
			end)
		end
	end
end

mouse.Move:Connect(function()
	if held then
		slider.Button.Position = UDim2.new(UDim.new(0, math.clamp(mouse.X - slider.AbsolutePosition.X, 0, slider.Bar.AbsoluteSize.X - (slider.Bar.AbsoluteSize.X / 30))), slider.Button.Position.Y)
		slider.Bar.UIGradient.Offset = Vector2.new(math.clamp(((slider.Button.AbsolutePosition.X - slider.AbsolutePosition.X) / (orgpos - slider.AbsolutePosition.X)) - 0.5, -0.5, 0.5))	
		
		percent = math.floor(((slider.Bar.UIGradient.Offset.X + 0.5) * 100) + 0.5)
		slider.Button.Amount.Text = tostring(percent)
		
		return percent
	end
end)

frame.TopBar.Close.MouseButton1Click:Connect(function()
	ButtonClick(frame.TopBar.Close)
end)

UIS.InputEnded:Connect(MouseUp)