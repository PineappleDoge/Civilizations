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
---Services

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")

---- Arrays

local TrainingTable = {}
local TroopTable = {}
local Frames = {}

local Weights = {
	Warrior = 1,
	Archer = 1,
	Troll = 1,
	Giant = 5,
	Bomber = 3,
	Knight = 10,
	Assassin = 6,
	Zeppelin = 5,
	Pixie = 10,
	Samurai = 30
}

----- Objects

local frame = script.Parent
local troopFrame = frame.ButtonFrame
local trainFrame = frame.TrainBar.ContentFrame
local confirm = frame.Parent.Parent.Parent.Parent.Confirm.MainFrame.ContentFrame.ContentFrame
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local speed = 0
local TI = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)

------ Values

local msg = "Please confirm that you are ready to make this decision, it shall cost you the following:"

-- Functions

function Tween(obj, prop, length)
    speed = length
	TS:Create(obj, TI, prop):Play()
end

function Ripple(obj, colour, mouse, x, y)
	local circle = frame.Circle:Clone()
	circle.Parent = obj
	circle.Size = UDim2.new(0,1,0,1)
	circle.ImageTransparency = .5
	circle.ZIndex = 2
	circle.ImageColor3 = colour
	
	if mouse then
		circle.Position = UDim2.new(0, (x - obj.AbsolutePosition.X), 0, (y - obj.AbsolutePosition.Y))
	else
		circle.Position = UDim2.new(0.5,0,0.5,0)
	end

	Tween(circle, {Size = UDim2.new(0, 250, 0, 250), ImageTransparency = 1}, .5)
end

local function Init(obj, currency, amount)
	confirm.Parent:SetAttribute("Type", "Train")
	Tween(frame.Parent.Fade, {BackgroundTransparency = 0.25}, 0.2)
	Tween(obj.Parent, {Position = UDim2.new(0,0,0,0)}, 0.5)
	obj.Amount.Text = amount
	obj.Title.Text = msg

	for _, image in ipairs(obj:GetChildren()) do
		if image:IsA("ImageLabel") then
			if image.Name == currency then
				image.Visible = true
			else
				image.Visible = false
			end
		end
	end
end

local function AddTroop(obj, x, y)
	local troop = string.sub(obj.Name, 2, #obj.Name)
	local val = frame.TrainBar:GetAttribute(troop)
	local button = frame.TrainBar.ContentFrame[obj.Name]
	local cap = string.split(frame.ACount.Text, "/")
	
	if Weights[troop] + tonumber(cap[1]) <= tonumber(cap[2]) then
		if val == 0 then
			button.Visible = true
			Tween(button.MainFrame, {Position = UDim2.new(0,0,0,0)}, 0.2)
			button.MainFrame.ContentFrame.Amount.Text = "x1"
		else
			local amount = tonumber(string.match(button.MainFrame.ContentFrame.Amount.Text, "%d+"))
			button.MainFrame.ContentFrame.Amount.Text = "x" .. amount + 1

			Ripple(button.MainFrame, Color3.fromRGB(255, 255, 255), false)
		end
		
		frame.ACount.Text = tonumber(cap[1] + Weights[troop]) .. "/" .. cap[2]
		frame.TrainBar:SetAttribute(troop, val + 1)
	else
		Tween(frame.ACount, {TextColor3 = Color3.fromRGB(255, 93, 96)}, 0.2)
		Tween(frame.AIcon, {ImageColor3 = Color3.fromRGB(255, 93, 96)}, 0.2)
		wait(0.2)
		Tween(frame.ACount, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
		Tween(frame.AIcon, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
	end
	
	Ripple(obj.ContentFrame, Color3.fromRGB(255, 255, 255), true, x, y)
end

local function RemoveTroop(obj)
	local button = obj.Parent.Parent.Parent
	local troop = string.sub(button.Name, 2, #obj.Name)
	local val = frame.TrainBar:GetAttribute(troop)
	local cap = string.split(frame.ACount.Text, "/")
	
	if val - 1 <= 0 then
		Tween(button.MainFrame, {Position = UDim2.new(0,0,1,0)}, 0.2)
		button.MainFrame.ContentFrame.Amount.Text = "x0"
		wait(0.2)
		button.Visible = false
	else
		local amount = tonumber(string.match(obj.Parent.Amount.Text, "%d"))
		obj.Parent.Amount.Text = "x" .. amount - 1

		Ripple(button.MainFrame, Color3.fromRGB(255, 93, 96), false)
	end
	
	frame.ACount.Text = tonumber(cap[1] - Weights[troop]) .. "/" .. cap[2]
	frame.TrainBar:SetAttribute(troop, val - 1)
end

local function ButtonClick(obj, x, y)
	if obj.Name == "Boost" then
		Init(confirm, "Crystals", "50 for 4x for 1hr")
	end

	if obj.Name == "Finish" then
		Init(confirm, "Crystals", "50")
	end
	
	if obj.Parent.Name == "ButtonFrame" then
		AddTroop(obj, x, y)
	end
	
	if obj.Name == "Minus" then
		RemoveTroop(obj)
	end
end

local ClassEvents = {
	["MouseButton1Click"] = ButtonClick
}

for _, button in ipairs(frame:GetChildren()) do
	if button:IsA("ImageButton") then
		table.insert(Frames, button)
	end
end

for _, button in ipairs(troopFrame:GetChildren()) do
	if button:IsA("ImageButton") then
		table.insert(TroopTable, button)
	end
end

for _, troop in ipairs(trainFrame:GetChildren()) do
	if troop:IsA("ImageLabel") then
		for _, button in ipairs(troop.MainFrame.ContentFrame:GetChildren()) do
			if button:IsA("TextButton") then
				table.insert(TrainingTable, button)
			end
		end
	end
end

-- Events

for name, button in ipairs(Frames) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button, mouse.X, mouse.X)
			end)
		end
	end
end

for name, button in ipairs(TroopTable) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button, mouse.X, mouse.Y)
			end)
		end
	end
end

for name, button in ipairs(TrainingTable) do
	for index, func in pairs(ClassEvents) do
		if button[index] ~= nil then
			button[index]:Connect(function()
				func(button, mouse.X, mouse.Y)
			end)
		end
	end
end