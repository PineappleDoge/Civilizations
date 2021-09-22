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
--- Objects

local frame = script.Parent

---- Arrays

local ButtonTable = {}
local Frames = {}

----- Values

local debounce = false

-- Functions

function Tween(obj, prop, speed)
	local TS = game:GetService("TweenService")
	local TI = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	TS:Create(obj, TI, prop):Play()
end

local function ButtonEnter(obj)
	Tween(obj.DB, {BackgroundColor3 = Color3.fromRGB(100,100,100)}, 0.2)
end

local function ButtonLeave(obj)
	Tween(obj.DB, {BackgroundColor3 = Color3.fromRGB(57,57,57)}, 0.2)
end

local function ButtonClick(obj)
	if debounce == false then
		debounce = true
		if obj:GetAttribute("Locked") == true then
			ErrorMessage("Error: You cannot purchase this building just yet!")
			-- you will need to add a check for the insufficient funds, message will be "Error: You have insufficient funds to purchase this!"
		else
			Tween(frame.Parent.Parent.Parent, {Position = UDim2.new(0,0,1,0)}, 0.5)
		end
	end
end

function ErrorMessage(msg)
	frame.Parent.Parent.NotifyBar.NotifyFrame.ContentFrame.Message.Text = msg
	Tween(frame.Parent.Parent.NotifyBar.NotifyFrame, {Position = UDim2.new(0,0,0,0)}, 0.2)
	wait(2)
	Tween(frame.Parent.Parent.NotifyBar.NotifyFrame, {Position = UDim2.new(0,0,-1,0)}, 0.2)
	debounce = false
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
				func(button)
			end)
		end
	end
end