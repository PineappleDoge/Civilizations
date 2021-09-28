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

-- Functions

function Tween(obj, prop, speed)
	local TS = game:GetService("TweenService")
	local TI = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false)
	TS:Create(obj, TI, prop):Play()
end

-- Events

frame.MouseButton1Click:Connect(function()
	Tween(frame.Parent.Parent, {Position = UDim2.new(0,0,1,0)}, 0.5)
end)