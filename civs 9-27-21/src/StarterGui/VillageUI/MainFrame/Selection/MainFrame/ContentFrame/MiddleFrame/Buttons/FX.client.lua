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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SPR = require(ReplicatedStorage.SPR)
---- Objects

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local frame = script.Parent
local confirm = frame.Parent.Parent.Parent.Parent.Parent.Confirm.MainFrame.ContentFrame.ContentFrame

----- Arrays

local ButtonTable = {}
local Frames = {}

------ Values

local debounce = false
local costMsg = "Please confirm that you are ready to make this decision, it shall cost you the following:"

-- Functions

function Tween(obj, prop, speed)
	local TS = game:GetService("TweenService")
	local TI = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	TS:Create(obj, TI, prop):Play()
end

local function Init(obj, currency, amount, receive)
	SPR.target(
		obj.Parent,
		0.75,
		3.5,
		{Position = UDim2.fromScale(0, 0)}
	)
	
	task.delay(0.5, function()
		SPR.stop(obj.Parent)
	end)
	
	obj.Amount.Text = amount
	
	if receive then
		obj.Title.Text = string.gsub(costMsg, "it shall cost you", "you will receive")
	else
		obj.Title.Text = costMsg
	end
	
	for _, image in ipairs(obj:GetChildren()) do
		if image:IsA("ImageLabel") then
			if image.Name == currency then
				image.Visible = true
			else
				image.Visible = false
			end
		end
	end
	
	debounce = false
end

local function ButtonEnter(obj)
	Tween(obj.MainFrame, {BackgroundColor3 = Color3.fromRGB(100,100,100)}, 0.2)
end

local function ButtonLeave(obj)
	Tween(obj.MainFrame, {BackgroundColor3 = Color3.fromRGB(57,57,57)}, 0.2)
end

local function ButtonClick(obj, x, y)
	Ripple(obj, x, y)
	
	if debounce == false then
		debounce = true
		-- funds check pls xd, message will be "Error: You have insufficient funds to purchase this!" for the buying buttons lel
		-- you need to add so that the prompt shows how much the cost is. its ez
		if obj.Name == "GoldUpgrade" then
			Init(confirm, "Gold", "100,000", false)
		end
		
		if obj.Name == "SoulUpgrade" then
			Init(confirm, "Souls", "100,000", false)
		end
		
		if obj.Name == "Finish" then
			Init(confirm, "Crystals", "500", false)
		end
		
		if obj.Name == "GemBoost" then
			Init(confirm, "Crystals", "50 for 10x/hr", false)
		end
		
		if obj.Name == "Cancel" then -- will need to determine what currency was used to upgrade in order to show the icon correctly.
			Init(confirm, "Gold", "50% Refund", true)
		end
		
		if obj.Name == "Info" then -- you will need to alter all the components of this. so like building health and stuff, there are bars too. maximum fill is maximum level capacity.
			SPR.target(
				frame.Parent.Parent.Parent.Parent.Parent.Info.MainFrame.ContentFrame,
				1.25,
				3.5,
				{Position = UDim2.fromScale(0, 0)}
			)
			task.wait(0.5)
			SPR.stop(frame.Parent.Parent.Parent.Parent.Parent.Info.MainFrame.ContentFrame)
			-- Tween(frame.Parent.Parent.Parent.Parent.Parent.Info.MainFrame.ContentFrame, {Position = UDim2.new(0,0,0,0)}, 0.5)
			-- do all the editing, i shouldve probs made the path a variable bc its long lmao
			debounce = false
		end
		
		if obj.Name == "Purchase" then
			Tween(frame.Parent.Parent.Parent.Parent, {Position = UDim2.new(0,0,1,0)}, 0.5)
			debounce = false
		end
		
		if obj.Name == "Rotate" then
			-- lol do rotate building code here this is only for WEAPONS!!!! only weaponry buildings can be rotated.
		end
		
		if obj.Name == "Boost" then
			Init(confirm, "Boost", "24x for 1hr", true)
		end
	end
end

function ErrorMessage(msg)
	frame.Parent.Parent.Parent.Parent.NotifyBar.NotifyFrame.ContentFrame.Message.Text = msg
	Tween(frame.Parent.Parent.Parent.Parent.NotifyBar.NotifyFrame, {Position = UDim2.new(0,0,0,0)}, 0.2)
	wait(2)
	Tween(frame.Parent.Parent.Parent.Parent.NotifyBar.NotifyFrame, {Position = UDim2.new(0,0,-1,0)}, 0.2)
	debounce = false
end

function Ripple(obj, x, y)
	local circle = frame.Parent.Circle:Clone()
	circle.Parent = obj.MainFrame.ContentFrame
	circle.Size = UDim2.new(0,1,0,1)
	circle.ImageTransparency = .5
	circle.ZIndex = 2

	local pos = UDim2.new(0, (x - obj.AbsolutePosition.X), 0, (y - obj.AbsolutePosition.Y))
	circle.Position = pos

	Tween(circle, {Size = UDim2.new(0, 250, 0, 250), ImageTransparency = 1}, .5)
end

local ClassEvents = {
	["MouseEnter"] = ButtonEnter, 
	["MouseLeave"] = ButtonLeave,
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
				func(button, mouse.X, mouse.Y)
			end)
		end
	end
end