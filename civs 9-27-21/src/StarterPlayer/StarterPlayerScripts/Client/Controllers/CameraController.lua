--[[
--------------------------------------------------------
-- S1RGames & Lxe | Camera controller
-- Controlls the user camera.
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////

	CameraController:UpdateCanvasCamera(PlayerCanvas: player | string)
		> PlayerCanvas - The new canvas of which you want the local player to target. Example: PlayerCanvas could be the enemy, leave as "!preset" for preset battles.
		> Return: StructureID: string
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]

-- Services
local RUN_SERVICE = game:GetService("RunService")
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local REPLICATED_SERVICE = game.ReplicatedStorage
local TWEEN_SERVICE = game:GetService("TweenService")

-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local Janitor = require(Knit.SharedModules.Janitor)
local CameraController = Knit.CreateController{
	Name = "CameraController"
}

local Canvas
local Minimum, Maximum
local Camera = workspace.CurrentCamera
local Flipper = require(REPLICATED_SERVICE.Shared.Modules.Flipper)
local CameraEnabled = false
local DefaultCameraCFrame
local LastTouchTranslation = nil

local CounterX = 0
local CounterY = 0

local CameraSpeed = .25
local TweenTime = .35


-- Flipper Setup
local Table = {'X', 'Y', 'Z', 'R00', 'R01', 'R02', 'R10', 'R11', 'R12', 'R20', 'R21', 'R22'}
local NewTbl = {}
for i, v in pairs(Table) do 
	NewTbl[v] = 0
end
print(Table, NewTbl)
local CamMotor = Flipper.GroupMotor.new(NewTbl)
local CamProperties = {
	frequency = 15,
	dampingRatio = 1.25,
}

-------------------------------------------------------------------------
-- Private Functions
function Init()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	CameraController:UpdateCanvasCamera(game.Players.LocalPlayer)
	Camera.CFrame = (Canvas.ctest.CFrame + Vector3.new(15,30,-10)) * CFrame.Angles(math.rad(-45),math.rad(-10),math.rad(-10))
	DefaultCameraCFrame = Camera.CFrame - Vector3.new(Camera.CFrame.X, 0, Camera.CFrame.Z)
	CameraEnabled = true
end

function DesktopPan()
	local KeyDown = USER_INPUT_SERVICE:GetMouseButtonsPressed()
	local RightButtonDown = false

	for i, v in ipairs(KeyDown) do
		if v.UserInputType == Enum.UserInputType.MouseButton2 then
			RightButtonDown = true
		end
	end

	if RightButtonDown and CameraEnabled and DefaultCameraCFrame ~= nil then
		local MousePosition = USER_INPUT_SERVICE:GetMouseDelta()
		local CameraDifferenceX, CameraDifferenceY = (MousePosition.Y * CameraSpeed), (-1 * MousePosition.X * CameraSpeed)
		
		CounterX += CameraDifferenceX
		CounterY += CameraDifferenceY
		
		CounterX = math.clamp(CounterX, Minimum.X, Maximum.X)
		CounterY = math.clamp(CounterY, Minimum.Z, Maximum.Z)
		local NewCFrame = DefaultCameraCFrame + Vector3.new(CounterX, 0, CounterY)
		
		local Tween = TWEEN_SERVICE:Create(Camera, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = DefaultCameraCFrame + Vector3.new(CounterX, 0, CounterY)} )
		Tween:Play()
	end
end

function MobilePan(touchPositions, totalTranslation, velocity, state)
	if (state == Enum.UserInputState.Change or state == Enum.UserInputState.End) and CameraEnabled then
		local difference = totalTranslation - LastTouchTranslation
		
		CounterX += difference.X
		CounterY += difference.Y

		CounterX = math.clamp(CounterX, Minimum.X, Maximum.X)
		CounterY = math.clamp(CounterY, Minimum.Z, Maximum.Z)
		local Tween = TWEEN_SERVICE:Create(Camera, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = DefaultCameraCFrame + Vector3.new(CounterX, 0, CounterY)} )
		Tween:Play()
	end

	LastTouchTranslation = totalTranslation
end

function ButtonDown(input, typing)
	if typing then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		USER_INPUT_SERVICE.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		game:GetService("UserInputService").MouseIconEnabled = false
	end
end

function ButtonUp(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		USER_INPUT_SERVICE.MouseBehavior = Enum.MouseBehavior.Default
		game:GetService("UserInputService").MouseIconEnabled = true
	end
end


-------------------------------------------------------------------------
-- CameraController Properties
CameraController.Prefix = "[CameraController]:"
CameraController.Janitor = Janitor.new()
CameraController.Connections = {}


-------------------------------------------------------------------------
-- CameraController Functions
function CameraController:UpdateCanvasCamera(PlayerCanvas)
	if PlayerCanvas ~= "!preset" then
		Canvas = game.Workspace:WaitForChild("CanvasPart" .. PlayerCanvas.UserId)
	else
		Canvas = game.Workspace:WaitForChild("Default") -- // Implement this in the future to what canvas is what ofc.
	end
	Minimum, Maximum = Canvas.DEMO_CANVAS.Position +(Vector3.new(Canvas.DEMO_CANVAS.Size.X*.75,Canvas.DEMO_CANVAS.Size.Y*.5,Canvas.DEMO_CANVAS.Size.Z*.5)*-1) , Canvas.DEMO_CANVAS.Position + Vector3.new(Canvas.DEMO_CANVAS.Size.X*.25,Canvas.DEMO_CANVAS.Size.Y*.5,Canvas.DEMO_CANVAS.Size.Z*.25)
end

function CameraController:EnableCamera()
	if self.CameraEnabled == true then
		warn(("%s Camera is already enabled and running."):format(self.Prefix))
	end

	self.Janitor:Add(USER_INPUT_SERVICE.InputBegan:Connect(ButtonDown))
	self.Janitor:Add(USER_INPUT_SERVICE.InputEnded:Connect(ButtonUp))
	self.Janitor:Add(USER_INPUT_SERVICE.TouchPan:Connect(MobilePan))
	self.Janitor:Add(RUN_SERVICE.RenderStepped:Connect(DesktopPan))
	self.CameraEnabled = true
end

function CameraController:DisableCamera()
	if self.CameraEnabled ~= true then
		warn(("%s Camera is not enabled"):format(self.Prefix))
	end

	self.Janitor:Cleanup()
	self.CameraEnabled = false
end


-------------------------------------------------------------------------
-- CameraController Functions [Knit Start/Init]
function CameraController:KnitInit()

end

function CameraController:KnitStart()
	task.spawn(Init)
	task.spawn(function()
		self:EnableCamera()
	end)
	--print("Ran")
end


-------------------------------------------------------------------------
-- CameraController Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return CameraController