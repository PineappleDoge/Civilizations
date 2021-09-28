-------------------------------------------------------------------------
-- PineappleDoge / SelectionController
-- Manages dispatching BuildingSelected/Deselected events, handles visuals for selection, fires off "PlaceBuilding"
-------------------------------------------------------------------------
-- Services / Types
type Packet = {
	XPos: number, 
	YPos: number,
	RaycastParams: RaycastParams?, 
	Blacklist: {}?
}

local CONTEXT_ACTION_SERVICE = game:GetService("ContextActionService")
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared.Knit)
local Signal = require(Knit.Util.Signal)
local SelectionController = Knit.CreateController{
	Name = "SelectionController"
}

local SelectionIndicator = require(Knit.Modules.BuildingSelectionIndicator)
local DataController = nil;
local CameraController = nil
local PlacementController = nil

local BuildingData = require(Knit.SharedSystems.BuildingData)
local Flipper = require(Knit.SharedModules.Flipper)
local Janitor = require(Knit.SharedModules.Janitor)
local Promise = require(Knit.Util.Promise)
local Canvas = require(Knit.Modules.Canvas)

local PLAYER_CANVAS = workspace:WaitForChild("CanvasPart" .. game.Players.LocalPlayer.UserId)
local PLACEMENT_SPRING_PROPERTIES = {frequency = 20, dampingRatio = 1.2}
local GROUP_MOTOR_PRESET = {X = 0; Y = 0; Z = 0}

local LevelPart = Knit.Assets:FindFirstChild("_LevelPart"):Clone()
local LevelPartGui = LevelPart.PrimaryPart:WaitForChild("Overhead"):WaitForChild("Frame")


-------------------------------------------------------------------------
-- Private Functions
function VisualizeSelectedModel(Model, Bool)
	if Bool == true then
		Model.PrimaryPart.Color = Color3.fromRGB(185, 200, 199)
	else
		Model.PrimaryPart.Color = Color3.fromRGB(30, 130, 30)
	end
end

function GetMouseDelta()
	local MouseLoc = USER_INPUT_SERVICE:GetMouseLocation()
	return MouseLoc.X, MouseLoc.Y
end

function MouseRaycast(Packet: Packet)
	local Camera = workspace.CurrentCamera
	local UnitRay = Camera:ViewportPointToRay(Packet.XPos, Packet.YPos, 0)
	
	local RaycastDetails = RaycastParams.new()
	local RaycastBlacklist = Packet.Blacklist or {}
	RaycastDetails.FilterType = Enum.RaycastFilterType.Blacklist
	RaycastDetails.FilterDescendantsInstances = RaycastBlacklist

	return workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, Packet.RaycastParams or RaycastDetails)
end

function GetModelData(Model)
	local Str = Model.Name
	local StrTbl = string.split(Str, " Level")
	
	return {
		Name = StrTbl[1];
		Level = StrTbl[2]
	}
end

function SelectBuilding(input, typing)
	if typing == true then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local Position = USER_INPUT_SERVICE:GetMouseLocation()
		local PacketResult = {XPos = Position.X, YPos = Position.Y}
		local Results = MouseRaycast(PacketResult)
		
		if Results ~= nil then
			if Results.Instance then
				if Results.Instance:IsDescendantOf(SelectionController.SelectedBuilding) == true and SelectionController.SelectedBuilding ~= nil then
					SelectionController:LinkBuildingToMouse(SelectionController.SelectedBuilding)
					return
					-- print("Binded building to mouse movement", SelectionController.SelectedBuilding)
				else
					SelectionController:DeselectBuilding()
					for _, building in ipairs(PLAYER_CANVAS.Buildings:GetChildren()) do
						if Results.Instance:IsDescendantOf(building) then
							SelectionController:SelectBuilding(building)
							return 
							-- print("Switched Buildings from %s to %s", SelectionController.SeletedBuilding, building)
						end
					end
				end
			else
				-- print("No instance, deselected building")
				SelectionController:DeselectBuilding()
				return
			end
		else
			-- print("No results, deselected building")
			SelectionController:DeselectBuilding()
			return
		end
	else 
		SelectionController:DeselectBuilding()
	end
end


-------------------------------------------------------------------------
-- SelectionController Properties
SelectionController.Prefix = "[SelectionController]:"
SelectionController.Janitor = Janitor.new()
SelectionController.Connections = {}
SelectionController.PlacingMotor = Flipper.GroupMotor.new(GROUP_MOTOR_PRESET)
SelectionController.BuildingSelected = Signal.new()
SelectionController.BuildingDeselected = Signal.new()
SelectionController.SelectedBuilding = nil
SelectionIndicator.SelectEffect = nil


-------------------------------------------------------------------------
-- SelectionController Functions
function SelectionController:SelectBuilding(Model)
	-- print(("Building requested to be selected! Name: %s"):format(Model:GetFullName()))
	self.Janitor:Cleanup() -- Cleaning up any residue
	VisualizeSelectedModel(Model, true)
	local ModelData = GetModelData(Model)
	
	if Model:GetAttribute("Upgrading") ~= true then
		LevelPartGui.Visible = false
		LevelPart:SetPrimaryPartCFrame(Model:GetPrimaryPartCFrame() * CFrame.new(0, 5.95, 0))
		LevelPartGui:FindFirstChild("Level").Text = "Level " .. ModelData.Level
		LevelPartGui:FindFirstChild("Name").Text = ModelData.Name
	end
	
	workspace.Sounds.BuildingSelect:Play()
	
	if self.SelectEffect ~= nil then 
		self.SelectEffect:Destroy() 
		self.SelectEffect = nil
	end
	
	LevelPartGui.Visible = true
	self.SelectEffect = SelectionIndicator.new()
	self.SelectEffect:Select(Model)
	LevelPart.Parent = workspace
	self.SelectedBuilding = Model
	self.BuildingSelected:Fire(Model)
end

function SelectionController:DeselectBuilding()
	self.Janitor:Cleanup()
	LevelPart.Parent = nil
	
	if self.SelectEffect ~= nil then 
		self.SelectEffect:Destroy() 
		self.SelectEffect = nil
	end
	
	if self.SelectedBuilding ~= nil and self.SelectedBuilding.PrimaryPart ~= nil then
		VisualizeSelectedModel(self.SelectedBuilding, false)
	end

	self.BuildingDeselected:Fire(self.SelectedModel)
	self.SelectedBuilding = nil
end

function SelectionController:LinkBuildingToMouse(Model)
	SelectionController:DeselectBuilding()
	self.SelectedBuilding = Model
	VisualizeSelectedModel(Model, true)

	if self.Connections['SelectInput'] ~= nil then
		self.Connections['SelectInput']:Disconnect()
		self.Connections['SelectInput'] = nil
	end

	local Connection = nil
	local Position: Vector2 = nil
	local ModelName = string.split(Model.Name, " Level")[1]
	local ModelData = BuildingData:FindBuildingData(ModelName)
	local ModelSize = ModelData.Size

	if USER_INPUT_SERVICE.MouseEnabled == true then -- Legacy Code, Change When UserInputController is functional
		Position = self.Canvas:GetHitPosition(ModelSize)
		local hitPos = self.Canvas:CellPositionToWorldPosition(Position)
		self.PlacingMotor:setGoal({
			X = Flipper.Spring.new(hitPos.X, PLACEMENT_SPRING_PROPERTIES),
			Y = Flipper.Spring.new(hitPos.Y, PLACEMENT_SPRING_PROPERTIES),
			Z = Flipper.Spring.new(hitPos.Z, PLACEMENT_SPRING_PROPERTIES)
		})
	end

	local function PlaceBuilding(input, isTyping)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or (input.UserInputType == Enum.UserInputType.Touch) then
			Connection:disconnect()
			self.Janitor:Cleanup()

			if self.SelectedBuilding:IsDescendantOf(PLAYER_CANVAS.Buildings) then
				local MoveBuilding = PlacementController:MoveBuilding(self.SelectedBuilding, Position)
				:andThen(function()
					-- print("Replacement Succeeded")
					self:DeselectBuilding()
					self.Janitor:Cleanup()
					CameraController:EnableCamera()
					self.Connections['SelectInput'] = USER_INPUT_SERVICE.InputBegan:Connect(SelectBuilding)
				end)

				:catch(function()
					-- print("Replacement Failed")
					self:DeselectBuilding()
					self.Janitor:Cleanup()
					CameraController:EnableCamera()
					self.Connections['SelectInput'] = USER_INPUT_SERVICE.InputBegan:Connect(SelectBuilding)
				end)
			else
				local BuildingPlaced = PlacementController:PlaceBuilding(self.SelectedBuilding, Position)
				:andThen(function(resultPacket)
					-- print(("Placement Succeeded"))
					self:DeselectBuilding()
					self.Janitor:Cleanup()
					CameraController:EnableCamera()
					self.Connections['SelectInput'] = USER_INPUT_SERVICE.InputBegan:Connect(SelectBuilding)
				end)
				--
				:catch(function(errorPacket)
					-- print(("Placement Failed"))
					self:DeselectBuilding()
					self.Janitor:Cleanup()
					CameraController:EnableCamera()
					self.Connections['SelectInput'] = USER_INPUT_SERVICE.InputBegan:Connect(SelectBuilding)
				end)
			end
		end
	end

	local function AdvanceMotorOnStep(values)
		local NewCFrame = CFrame.new(Vector3.new(values.X, values.Y, values.Z))
		self.SelectedBuilding:SetPrimaryPartCFrame(NewCFrame)
	end

	local function CalculatePos(inputType, isTyping)
		if isTyping then return end
		-- TODO: Add mobile/console support
		Position = self.Canvas:GetHitPosition(ModelSize)
		local hitPos = self.Canvas:CellPositionToWorldPosition(Position)
		self.PlacingMotor:setGoal({
			X = Flipper.Spring.new(hitPos.X, PLACEMENT_SPRING_PROPERTIES),
			Y = Flipper.Spring.new(hitPos.Y, PLACEMENT_SPRING_PROPERTIES),
			Z = Flipper.Spring.new(hitPos.Z, PLACEMENT_SPRING_PROPERTIES)
		})
	end
	
	CameraController:DisableCamera()
	Connection = self.PlacingMotor:onStep(AdvanceMotorOnStep)
	self.Janitor:Add(USER_INPUT_SERVICE.InputChanged:Connect(CalculatePos)) -- you can change to renderstep if you want
	self.Janitor:Add(USER_INPUT_SERVICE.InputBegan:Connect(PlaceBuilding))
end

function SelectionController:GetSelectedBuilding(): Instance
	return self.SelectedBuilding
end


-------------------------------------------------------------------------
-- SelectionController Functions [Knit Start/Init]
function SelectionController:KnitInit()

end

function SelectionController:KnitStart()
	CameraController = Knit.GetController("CameraController")
	PlacementController = Knit.GetController("PlacementController")
	DataController = Knit.GetController("DataController")
	self.Canvas = DataController:GetPlayerData().Canvas
	SelectionController:DeselectBuilding()
	self.Connections['SelectInput'] = USER_INPUT_SERVICE.InputBegan:Connect(SelectBuilding)
end


-------------------------------------------------------------------------
-- SelectionController Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return SelectionController