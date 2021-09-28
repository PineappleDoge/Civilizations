-------------------------------------------------------------------------
-- PineappleDoge / UserInputManager
-- Add a description here
-------------------------------------------------------------------------
-- Services
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local UserInputManager = Knit.CreateController{
	Name = "UserInputManager"
}


-------------------------------------------------------------------------
-- Private Functions
function InputBegan(inputObj, typing)
	if typing == true then return end
	
	if inputObj.UserInputType == Enum.UserInputType.Touch then
		UserInputManager.ActiveInputDevice = "Touch"
		UpdateTouch(inputObj)
	elseif string.find(inputObj.UserInputType.Name, "Mouse") ~= nil or inputObj.KeyCode ~= Enum.KeyCode.Unknown then
		UserInputManager.ActiveInputDevice = "Desktop"
		UpdateKeyboardMouse(inputObj)
	elseif string.find(inputObj.UserInputType.Name, "Gamepad") ~= nil then
		UserInputManager.ActiveInputDevice = "Gamepad"
		UpdateGamepad(inputObj)
	end
end

function InputEnded(inputObj, typing)
	if inputObj.UserInputType == Enum.UserInputType.Touch then
		UserInputManager.Touch['TouchPos'] = inputObj.Position
	end
end

function InputChanged(inputObj, typing)
	if inputObj.UserInputType == Enum.UserInputType.Touch then
		UserInputManager.Touch['TouchPos'] = inputObj.Position
		print(UserInputManager.Touch) 
	end
end

-- Input Specific Devices
function UpdateKeyboardMouse(inputObj: InputObject)
	if USER_INPUT_SERVICE.MouseEnabled then
		UserInputManager.Desktop['Position'] = USER_INPUT_SERVICE:GetMouseLocation()
	end
end

function UpdateGamepad(inputObj: InputObject)
	
end

function UpdateTouch(inputObj: InputObject)
	if USER_INPUT_SERVICE.TouchEnabled then
		UserInputManager.Touch['Position'] = Vector2.new(inputObj.Position.X, inputObj.Position.Y)
	end
end


-------------------------------------------------------------------------
-- UserInputManager Properties
UserInputManager.Prefix = "[UserInputManager]:"
UserInputManager.Touch = {}
UserInputManager.Desktop = {}
UserInputManager.Gamepad = {}
UserInputManager.Connections = {}
UserInputManager.ActiveInputDevice = nil


-------------------------------------------------------------------------
-- UserInputManager Functions
function UserInputManager:GetCrossPlatformPosition()
	return self[self.ActiveInputDevice].Position
end


-------------------------------------------------------------------------
-- UserInputManager Functions [Knit Start/Init]
function UserInputManager:KnitInit()

end

function UserInputManager:KnitStart()
	self.Connections['InputBegan'] = USER_INPUT_SERVICE.InputBegan:Connect(InputBegan)
	self.Connections['InputEnded'] = USER_INPUT_SERVICE.InputEnded:Connect(InputEnded)
	self.Connections['InputChanged'] = USER_INPUT_SERVICE.InputChanged:Connect(InputChanged)
end


-------------------------------------------------------------------------
-- UserInputManager Runtime Code [Pre-Knit Start/Init]
-- print(UserInputManager.Prefix, "has been initialized")


-------------------------------------------------------------------------
return UserInputManager