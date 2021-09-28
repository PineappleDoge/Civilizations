--------------------------------------------------------
-- PineappleDoge | Submodule_Settings
-- 8-12-2021 | Settings Module
-- Manages settings UI + More
--------------------------------------------------------
-- Services
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local REPLICATED_SERVICE = game:GetService("ReplicatedStorage")
local TWEEN_SERVICE = game:GetService("TweenService")
local PLAYERS = game:GetService("Players")

local Spr = require(REPLICATED_SERVICE.SPR)

--------------------------------------------------------
-- Objects
local Player = PLAYERS.LocalPlayer
local PlayerGUI = Player.PlayerGui 

--------------------------------------------------------
-- GUI + Objects
local VillageUI = PlayerGUI.VillageUI
local SettingsFrame = VillageUI.MainFrame.Settings.CutoutFrame.MainFrame
local Slider: ImageButton = SettingsFrame.ContentFrame.ScrollingFrame.SoundsContent.Volume.Slider
local orgpos = Slider.Button.AbsolutePosition.X

local TI = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
local GreenColours = {Light = Color3.fromRGB(85, 255, 127), Dark = Color3.fromRGB(41, 125, 60)}
local GreyColours = {Light = Color3.fromRGB(255, 255, 255), Dark = Color3.fromRGB(56, 56, 56)}
local Debounce = false

local Percent: number

local Switches = {
	Name = 'Switches'
}
local Sliders = {
	Name = 'Sliders'
}
local Buttons = {
	Name = 'Buttons'
}


--------------------------------------------------------
-- Functions
function Tween(obj, prop, length)
	TWEEN_SERVICE:Create(obj, TI, prop):Play()
end

function Ripple(obj, x, y)
	local circle = SettingsFrame.Circle:Clone()
	circle.Parent = obj
	circle.Size = UDim2.new(0,1,0,1)
	circle.ImageTransparency = 0
	circle.ZIndex = 2

	local pos = UDim2.new(0, (x - obj.AbsolutePosition.X), 0, (y - obj.AbsolutePosition.Y))
	circle.Position = pos

	Tween(circle, {Size = UDim2.new(0, 50, 0, 50), ImageTransparency = 1}, .5)
end

local function SwitchToggle(obj)
	if Debounce == false then
		Debounce = true
		if obj:GetAttribute("Toggled") == true then
			Spr.target(obj.Parent.Circle, 1.05, 6.5, {
				Position = UDim2.fromScale(0.25, -0.024);
				BackgroundColor3 = GreyColours.Light
			})
			Tween(obj.Parent.Bar, {BackgroundColor3 = GreyColours.Dark}, 0.1)
			--Tween(obj.Parent.Circle, {BackgroundColor3 = GreyColours.Light}, 0.1)

			task.delay(0.25, function()
				Spr.stop(obj.Parent.Circle)
			end)

			obj:SetAttribute("Toggled", false)
			--print("Turning Off")
		elseif obj:GetAttribute("Toggled") == false then
			Spr.target(obj.Parent.Circle, 1.05, 6.5, {
				Position = UDim2.fromScale(0.68, -0.024);
				BackgroundColor3 = GreenColours.Light;
			})
			--print("Turning On")
			Tween(obj.Parent.Bar, {BackgroundColor3 = GreenColours.Dark}, 0.1)
			--Tween(obj.Parent.Circle, {BackgroundColor3 = GreenColours.Light}, 0.1)
			
			task.delay(0.25, function()
				Spr.stop(obj.Parent.Circle)
			end)
			
			obj:SetAttribute("Toggled", true)
		end
		Debounce = false
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
		Spr.target(SettingsFrame, 0.95, 5.5, {Position = UDim2.fromScale(0, 1)})
		task.delay(0.25, function()
			Spr.stop(SettingsFrame)
		end)
	end
end

function SetupFrames()
	for _, layer in ipairs(SettingsFrame.ContentFrame.ScrollingFrame:GetChildren()) do
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
end


--------------------------------------------------------
-- Functions
local Module = {
	Bars = {Sliders, Buttons, Switches}
}

function Module:Initialize()
	local ClassEvents = {MouseButton1Click = ButtonClick}
	SetupFrames()
	
	task.defer(function()
		SettingsFrame.ContentFrame.TopBar.Close.MouseButton1Click:Connect(function()
			ButtonClick(SettingsFrame.ContentFrame.TopBar.Close)
		end)
	end)
	
	for i, subtable in ipairs(Module.Bars) do
		-- Loop through the tables
		for _, button in ipairs(subtable) do
			for index, func in pairs(ClassEvents) do
				if button[index] ~= nil then
					button[index]:Connect(function()
						local MousePos = USER_INPUT_SERVICE:GetMouseLocation()
						func(button, MousePos.X, MousePos.Y)
					end)
				end
			end
		end
	end
end

return Module