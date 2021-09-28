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

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

---- Objects

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local canvas = game.Workspace:WaitForChild("CanvasPart" .. player.UserId)

----- Values
local MaxValues: Vector2 = nil
local lastTouchTranslation = nil
local mousedown = false
local camenabled = false

-- Functions

local function Init()
	local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Knit"))
	Knit.OnStart():Await()

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable

	camera.CFrame = (canvas.ctest.CFrame + Vector3.new(15,30,-10)) * CFrame.Angles(math.rad(-45),math.rad(-10),math.rad(-10))

	camenabled = true
end

-- Events

local Character = player.Character or player.CharacterAdded:Wait()

Init()

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and camenabled then
		mousedown = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and camenabled then
		mousedown = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)

RunService.RenderStepped:Connect(function()
	if mousedown and camenabled then
		local MousePosition = UserInputService:GetMouseDelta()
		camera.CFrame += Vector3.new(MousePosition.Y*0.25, 0, -1*MousePosition.X*0.25)
	end
end)

UserInputService.TouchPan:Connect(function(touchPositions, totalTranslation, velocity, state)
	if (state == Enum.UserInputState.Change or state == Enum.UserInputState.End) and camenabled then
		local difference = totalTranslation - lastTouchTranslation
		camera.CFrame += Vector3.new(difference.Y*0.25, 0, -1*difference.X*0.25)
	end
	lastTouchTranslation = totalTranslation
end)
