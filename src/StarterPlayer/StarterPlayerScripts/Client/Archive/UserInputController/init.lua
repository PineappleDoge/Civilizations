-------------------------------------------------------------------------
-- PineappleDoge / UserInputController
-- Add a description here
-------------------------------------------------------------------------
-- Services
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local UserInputController = Knit.CreateController{
	Name = "UserInputController"
}

local UserInput = require(script.Parent.UserInput)
local InputModeProcessor = require(script.InputModeProcessor)
local InputModeState = require(script.InputModeState)
local InputStates = require(script.InputStates)
----
local ControllerInputState = InputModeState.new()
local KeyboardInputState = InputModeState.new()
local TouchInputState = InputModeState.new()

ControllerInputState:AddKeys(InputStates.Controller)
KeyboardInputState:AddKeys(InputStates.Keyboard, Enum.KeyCode)
TouchInputState:AddKeys(InputStates.Touch)


-------------------------------------------------------------------------
-- Private Functions
function Initialize()
	local LastInput = USER_INPUT_SERVICE:GetLastInputType()
	
	if LastInput == Enum.UserInputType.Touch then
		UserInputController.CurrentPlatform = "Mobile" 
	elseif LastInput == Enum.UserInputType.Gamepad1  then
		UserInputController.CurrentPlatform = "Console"
	else
		UserInputController.CurrentPlatform = "Computer"
	end 
end

function ManageInput(input, isTyping)
	if isTyping then return end --TODO: Use better practice so we can handle switching controls while typing
	
	
end

function GamepadConnected(gamepad)
	
end

function GamepadDisconnected(gamepad)
	
end


-------------------------------------------------------------------------
-- UserInputController Properties
UserInputController.Prefix = "[ControllerTemplate]:"
UserInputController.Connections = {}
UserInputController.CurrentPlatform = "Computer"


-------------------------------------------------------------------------
-- UserInputController Functions
function UserInputController:DoSomething(Player)
	print((self.Prefix .. " %s has done something!"):format(Player.Name))
end


-------------------------------------------------------------------------
-- UserInputController Functions [Knit Start/Init]
function UserInputController:GetInputPlatform()
	return UserInputController.CurrentPlatform
end

function UserInputController:KnitInit()

end

function UserInputController:KnitStart()

end

function UserInputController:Initialize()
	Initialize() -- Initial thing
	
	self.Connections["UserInput"] = USER_INPUT_SERVICE.InputBegan:Connect(ManageInput)
	self.Connections["GamepadEnabled"] = USER_INPUT_SERVICE.GamepadConnected:Connect(GamepadConnected)
	self.Connections["GamepadDisabled"] = USER_INPUT_SERVICE.GamepadDisconnected:Connect(GamepadDisconnected)
end


-------------------------------------------------------------------------
-- UserInputController Runtime Code [Pre-Knit Start/Init]
-- print(UserInputController.Prefix, "has been initialized")
UserInputController:Initialize()


-------------------------------------------------------------------------
return UserInputController