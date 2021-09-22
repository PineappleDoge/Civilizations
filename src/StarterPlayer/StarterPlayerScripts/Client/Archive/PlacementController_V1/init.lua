--------------------------------------------------------
-- PineappleDoge | PlacementController
-- 6-14-2021 | Prototype
-- Manages Placement Client-Sided, provides interface
--------------------------------------------------------
-- Services
local CONTEXT_ACTION_SERVICE = game:GetService("ContextActionService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local USER_INPUT_SERVICE = game:GetService("UserInputService")
local RUN_SERVICE = game:GetService("RunService")
local PLAYERS = game:GetService("Players")


--------------------------------------------------------
-- Directories
local Player = PLAYERS.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Shared = REPLICATED_STORAGE:WaitForChild("Shared")
local Client = PlayerScripts:WaitForChild("Client")


--------------------------------------------------------
-- Knit Setup
local Knit = require(Shared:WaitForChild("Knit"))
local Signal = require(Knit.Util.Signal)
local Keybinds = require(script:WaitForChild("Keybinds"))
local RotatedRegion3 = require(Knit.SharedModules.RotatedRegion3)
local PlacementController = Knit.CreateController{
	Name = "PlacementController"
}

local TimeFormat = require(Knit.SharedModules.TFMv2)
local TimerModule = require(Knit.SharedModules.Timer)
local BuildingData = require(Knit.SharedSystems.BuildingData)
local DataController = nil;
local PlacementService = nil;


--------------------------------------------------------
-- Private Functions
function GetMouseDelta()
	return USER_INPUT_SERVICE:GetMouseLocation().X, USER_INPUT_SERVICE:GetMouseLocation().Y
end

function GetBuildingData(Model)
	local UserID = Player.UserId
	local CurrentLevel = Model:GetAttribute("Level") or string.match(Model.Name, "Level %d")

	if string.find(CurrentLevel, "Level") then
		CurrentLevel = string.match(CurrentLevel, "%d")
	end

	local ModelName = string.split(Model.Name, " Level")[1]
	local NewLevel = tostring(tonumber(CurrentLevel) + 1)

	return {Level = CurrentLevel; Name = ModelName;}
end

function ClearCurrentModel()
	if PlacementController.CurrentModel ~= nil and PlacementController.CurrentModel.Destroy ~= nil then
		PlacementController.CurrentModel:Destroy()
	end
	
	PlacementController.CurrentModel = nil
end

function ClearSelectedModel()
	if PlacementController.SelectedModel ~= nil then
		local LevelPart = PlacementController.SelectedModel:FindFirstChild("LevelPart")

		if LevelPart ~= nil then
			LevelPart:Destroy()
		end

		PlacementController.SelectedModel.PrimaryPart.Color = Color3.fromRGB(30, 130, 30)
	end

	PlacementController.SelectedModel = nil
end

function MouseRaycast(raycastParams, blacklist)
	local MouseX, MouseY = GetMouseDelta()
	local Camera = workspace.CurrentCamera
	local UnitRay = Camera:ViewportPointToRay(MouseX, MouseY, 0)

	local RaycastDetails = RaycastParams.new()
	local RaycastBlacklist = blacklist or {}
	RaycastDetails.FilterType = Enum.RaycastFilterType.Blacklist
	RaycastDetails.FilterDescendantsInstances = RaycastBlacklist

	return workspace:Raycast(UnitRay.Origin, UnitRay.Direction * 1000, raycastParams or RaycastDetails)
end

function ReplaceModel()
	local RaycastResults = MouseRaycast()
	local Position = RaycastResults.Position
	local Rotation = PlacementController.CurrentRotation
	local CurrentCFrame = PlacementController:CalculateCFrame(PlacementController.CurrentModel, Position, Rotation)
	local SuccessfulPlace = PlacementService:Place(PlacementController.CurrentModel, CurrentCFrame, "Replace")
	PlacementController.CurrentModel:SetPrimaryPartCFrame(CurrentCFrame)
	
	if SuccessfulPlace == true then
		PlacementController.CurrentModel.PrimaryPart.Color = Color3.fromRGB(30, 130, 30)
		PlacementController.CurrentModel = nil
	end

	PlacementController.IsPlacing = false
end

function FindBuildingOnRaycast()
	local RaycastResults = MouseRaycast()
	local IsInstance = (RaycastResults ~= nil and RaycastResults.Instance ~= nil)

	if IsInstance == true then
		local FolderObject = workspace:FindFirstChild("Buildings_" .. Player.UserId)
		local FolderChildren = FolderObject:GetChildren()

		for _, model in ipairs(FolderChildren) do
			local childOf = RaycastResults.Instance:IsDescendantOf(model)
			
			if (childOf == true) then
				return model
			end
		end
		
		return nil
	end
end

function OnKeyClick(input, isTyping)
	if isTyping == true then return end

	if PlacementController.Keybinds[input.KeyCode] ~= nil then
		local buildingName = PlacementController.Keybinds[input.KeyCode].Name
		local buildingLevel = PlacementController.Keybinds[input.KeyCode].Level
		local buildingNameComplete = buildingName .. " Level " .. buildingLevel
		ClearSelectedModel()
		ClearCurrentModel()
		
		if PlacementController.CurrentModel ~= nil then
			local CurrentModelName = PlacementController.CurrentModel.Name
			local PossibleAsset = PlacementController.Assets[buildingNameComplete]
			
			if PossibleAsset ~= nil then -- Player is unequipping current mode;
				if CurrentModelName == PossibleAsset.Name then
					return
				elseif CurrentModelName ~= PossibleAsset.Name then -- Player is swithcing to new model
				end
			end
		end
		
		
		local Results = MouseRaycast()
		local CloneModel = PlacementService:CloneModel(buildingNameComplete) 
		assert(Results ~= nil, "Raycast failed, model cannot be drawn.")
		
		local NewPosition = Results.Position
		local NewRotation = PlacementController.CurrentRotation
		local NewCFrame = PlacementController:CalculateCFrame(CloneModel, NewPosition, NewRotation)
		CloneModel.PrimaryPart.Color = Color3.fromRGB(221, 221, 221)
		CloneModel:SetPrimaryPartCFrame(NewCFrame)
		
		PlacementController.CurrentModel = CloneModel
	end
end

function OnMouseMove(dt)
	if PlacementController.CurrentModel ~= nil then
		local Results = MouseRaycast()
		
		if Results.Instance == nil then return end  -- this happens when the player's mouse is focused on a non 3D space.
		
		local NewPosition = Results.Position
		local NewRotation = PlacementController.CurrentRotation
		local NewCFrame = PlacementController:CalculateCFrame(PlacementController.CurrentModel, NewPosition, NewRotation)

		PlacementController.CurrentModel:SetPrimaryPartCFrame(NewCFrame)
	end
end


--------------------------------------------------------
-- ContextActionService Callbacks (Actions)
function OnRotateRequest(actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		PlacementController:RotateModel()
	end
end

function OnPlaceRequest(actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		return PlacementController:PlaceModel()
	end
end

function OnSelectRequest(actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		PlacementController:SelectModel()
	end
end

function OnSaveRequest(actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		PlacementController:SaveCanvas()
	end
end

function OnLoadRequest(actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		PlacementController:LoadCanvas()
	end
end

function OnClearRequest(actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		PlacementController:ClearCanvas()
	end
end

function OnUpgradeRequest(actionName, inputState, input)
	if inputState == Enum.UserInputState.Begin then
		PlacementController:RequestUpgrade()
	end
end


--------------------------------------------------------
-- PlacementController Properties
PlacementController.Prefix = "[PlacementController]: "
PlacementController.Assets = {}
PlacementController.Events = {
	["BuildingSelected"] = Signal.new();
	["BuildingDeselected"] = Signal.new();
}
PlacementController.Keybinds = {}
PlacementController.Connections = {}
PlacementController.UpgradingBuildings = {}
PlacementController.ActionNames = {
	"Save", "Load", "Clear","Rotate",
	"Upgrade", "Place", "Select"
}

PlacementController.Buildings = nil
PlacementController.CanvasPart = nil
PlacementController.CurrentModel = nil
PlacementController.SelectedModel = nil
PlacementController.CurrentRotation = 4.7123889803847


--------------------------------------------------------
-- PlacementController Methods
function PlacementController:Initialize()
	local PlayerData = DataController:GetPlayerData()
	
	self.Buildings = PlayerData.Buildings
	self.CanvasPart = PlayerData.CanvasPart
	
	for index, building in pairs(self.Buildings) do
		local Keybind = Keybinds.Buildings[index]
		local Level = building.Level
		local BuildingName = building.Name .. " Level " .. Level
		
		self.Assets[BuildingName] = Knit.Assets:WaitForChild(BuildingName)
		self.Keybinds[Keybind] = building
	end
	
	CONTEXT_ACTION_SERVICE:BindAction("Save", OnSaveRequest, false, Keybinds.Save)
	CONTEXT_ACTION_SERVICE:BindAction("Load", OnLoadRequest, false, Keybinds.Load)
	CONTEXT_ACTION_SERVICE:BindAction("Clear", OnClearRequest, false, Keybinds.Clear)
	CONTEXT_ACTION_SERVICE:BindAction("Rotate", OnRotateRequest, false, Keybinds.Rotate)
	CONTEXT_ACTION_SERVICE:BindAction("Upgrade", OnUpgradeRequest, false, Keybinds.Upgrade)
	
	CONTEXT_ACTION_SERVICE:BindActionAtPriority("Place", OnPlaceRequest, false, 5, Keybinds.Place)
	CONTEXT_ACTION_SERVICE:BindActionAtPriority("Select", OnSelectRequest, false, 4, Keybinds.Select)
	
	self.Connections["MouseUpdate"] = RUN_SERVICE.Stepped:Connect(OnMouseMove)
	self.Connections["BuildingSelect"] = USER_INPUT_SERVICE.InputBegan:Connect(OnKeyClick)
end

function PlacementController:Enable()
	if self.Enabled == true then
		return 
	end
	
	self:Initialize()
end

function PlacementController:Disable()
	local BoundedActions = CONTEXT_ACTION_SERVICE:GetAllBoundActionInfo()
	for index, name in pairs(self.ActionNames) do
		if BoundedActions[index] ~= nil then
			CONTEXT_ACTION_SERVICE:UnbindAction(index)
		end
	end
end

function PlacementController:CalculateCanvas()
	local canvasSize = self.CanvasPart.Size

	local UpSide, BackSide = Vector3.new(0, 1, 0), -Vector3.FromNormalId(Enum.NormalId.Top)
	local Dot = BackSide:Dot(Vector3.new(0, 1, 0))
	local Axis = (math.abs(Dot) == 1) and Vector3.new(-Dot, 0, 0) or UpSide

	local right = CFrame.fromAxisAngle(Axis, math.pi/2) * BackSide
	local top = BackSide:Cross(right).unit

	local cf = self.CanvasPart.CFrame * CFrame.fromMatrix(-BackSide * canvasSize / 2, right, top, BackSide)
	local size = Vector2.new((canvasSize * right).magnitude, (canvasSize * top).magnitude)

	return cf, size
end

function PlacementController:CalculateCFrame(Model, Pos, Rot)
	local cf, size = self:CalculateCanvas()

	local modelSize = CFrame.fromEulerAnglesYXZ(0, Rot, 0) * Model.PrimaryPart.Size
	modelSize = Vector3.new(math.abs(modelSize.x), math.abs(modelSize.y), math.abs(modelSize.z))

	local lpos = cf:pointToObjectSpace(Pos)
	local size2 = (size - Vector2.new(modelSize.x, modelSize.z))/2
	local x = math.clamp(lpos.x, -size2.x, size2.x)
	local y = math.clamp(lpos.y, -size2.y, size2.y)

	local gridUnit = 4
	if (gridUnit > 0) then
		x = math.sign(x)*((math.abs(x) - math.abs(x) % gridUnit) + (size2.x % gridUnit))
		y = math.sign(y)*((math.abs(y) - math.abs(y) % gridUnit) + (size2.y % gridUnit))
	end

	return cf * CFrame.new(x, y, -modelSize.y/2) * CFrame.Angles(-math.pi/2, Rot, 0)
end



--------------------------------------------------------
-- PlacementController Methods [Actual Placement]
function PlacementController:RotateModel()
	if self.CurrentModel == nil then return end
	if self.IsRotating == true then return end 
	
	self.IsRotating = true
	self.CurrentRotation += math.pi/2
	self.IsRotating = false
end

function PlacementController:SelectModel()
	local building = FindBuildingOnRaycast()
	
	if building ~= nil then
		if building == self.SelectedModel then
			ClearSelectedModel()
			self.CurrentModel = building
			self.CurrentModel.PrimaryPart.Color = Color3.fromRGB(30, 130, 30)
			self.Events.BuildingDeselected:Fire(building)
		elseif building ~= self.SelectedModel then
			ClearSelectedModel()
			self.SelectedModel = building 
			
			local buildingBase = building.PrimaryPart
			local buildingData = GetBuildingData(building)
			local buildingCFrame = building:GetPrimaryPartCFrame()
			
			if self.UpgradingBuildings[building] == nil then
				local levelPart = Shared.Assets:FindFirstChild("LevelPart"):Clone()
				local cframeThing = CFrame.new(0, 4.5, 0)
				local frame = levelPart.Overhead.Frame

				frame.Level.Text = "Level " .. buildingData.Level
				frame:FindFirstChild("Name").Text = buildingData.Name
				levelPart.CFrame = buildingCFrame * cframeThing
				levelPart.Parent = building
			end
			
			buildingBase.Color = Color3.fromRGB(221, 221, 221)
			self.Events.BuildingSelected:Fire(building)
		end
	elseif self.SelectedModel ~= nil then
		self.SelectedModel.PrimaryPart.Color = Color3.fromRGB(30, 130, 30)
		ClearSelectedModel()
		self.Events.BuildingDeselected:Fire(building)
	end
end

function PlacementController:PlaceModel()
	if self.CurrentModel == nil then 
		return Enum.ContextActionResult.Pass
	end
	
	if self.IsPlacing == true then return end
	self.IsPlacing = true
	
	local FolderObject = workspace:FindFirstChild("Buildings_" .. Player.UserId )
	local IsModelDescendantOfCanvas = self.CurrentModel:IsDescendantOf(FolderObject)
	local DoesModelHasData = BuildingData:FindBuildingData(GetBuildingData(self.CurrentModel).Name) 
	local ModelData = GetBuildingData(self.CurrentModel)
	local ModelLevel = ModelData.Level
	
	if IsModelDescendantOfCanvas == true then
		ReplaceModel()
		return
	end
	
	if DoesModelHasData ~= nil then
		local PlacementCost = DoesModelHasData.UpgradeCost(ModelLevel)
		local CurrentCurrency = DataController:GetPlayerData().PlayerData.Currency
		
		if CurrentCurrency - PlacementCost >= 0 then -- successful placement
			local RaycastResults = MouseRaycast()
			local Position = RaycastResults.Position
			local Rotation = self.CurrentRotation
			local CurrentCFrame = self:CalculateCFrame(self.CurrentModel, Position, Rotation)
			self.CurrentModel:SetPrimaryPartCFrame(CurrentCFrame)
			
			local SuccessfulPlace = PlacementService:Place(self.CurrentModel, CurrentCFrame)
			
			if SuccessfulPlace == true then
				self.CurrentModel.PrimaryPart.Color = Color3.fromRGB(30, 130, 30)
				ClearCurrentModel()
			end
			
			self.IsPlacing = false
		else
			ClearCurrentModel()
			self.IsPlacing = false
		end
	else
		ClearCurrentModel()
		self.IsPlacing = false
	end
end

function PlacementController:RequestUpgrade()
	local Model = self.SelectedModel
	
	if Model ~= nil then
		local IsSuccessful, results = PlacementService:RequestUpgrade(Model)
		
		if IsSuccessful then
			local levelPart = Model:FindFirstChild("LevelPart")

			if levelPart ~= nil then
				levelPart:Destroy()
			end

			local timerPart = Shared.Assets:FindFirstChild("TimerPart"):Clone()
			local baseModel = Model:FindFirstChildWhichIsA("Model")
			local modelPrimary = Model.PrimaryPart
			local buildingFence = Shared.Assets:FindFirstChild("BuildingFence"):Clone()
			local FenceSize = Vector3.new(modelPrimary.Size.X, modelPrimary.Size.X, modelPrimary.Size.Z)
			local timerFrame = timerPart.PrimaryPart:FindFirstChildOfClass("BillboardGui"):FindFirstChildOfClass("Frame")
			local TimeDetails = TimeFormat.Convert(results[2] - os.time())
			local TextFormat = 
				   TimeDetails['day'] .. "d "
				.. TimeDetails['hr'] .. "h " 
				.. TimeDetails['min'] .. "m " 
				.. TimeDetails['sec'] .. "s"
			
			--[[for i, v in ipairs(baseModel:GetChildren()) do
				if v:IsA("BasePart") then
					v.Transparency = 1
				end
			end
			]]

			timerFrame:FindFirstChild("Name").Text = GetBuildingData(Model).Name
			timerFrame.Timer.Text = TextFormat
			timerPart.Parent = Model
			timerPart:SetPrimaryPartCFrame(
				Model.PrimaryPart.CFrame * CFrame.new(0, 4.5, 0)
			)
			
			buildingFence:SetPrimaryPartCFrame(
				Model.PrimaryPart.CFrame * CFrame.Angles(math.rad(-90), math.rad(90), 0) * CFrame.new(-1.5, 0, 0)
			)
			
			buildingFence.Parent = Model
			buildingFence.PrimaryPart.Size = FenceSize
			self.UpgradingBuildings[Model] = true
			local func = coroutine.wrap(function()
				local Counter = 0
				while true do
					repeat 
						Counter += RUN_SERVICE.RenderStepped:Wait()
					until Counter >= 1
					
					Counter = 0
					local RealDetails = TimeFormat.Convert(results[2] - os.time())
					local RealFormat = 
						RealDetails['day'] .. "d " .. 
						RealDetails['hr'] .. "h " .. 
						RealDetails['min'] .. "m " .. 
						RealDetails['sec'] .. "s"
					
					timerFrame.Timer.Text = RealFormat
					
					if results[2] - os.time() <= 0 then
						print("Yielded")
						coroutine.yield()
					end
				end
			end)
			
			func()
		end
	end
end

function PlacementController:SaveCanvas()
	local SuccessfulSave = PlacementService:SaveCanvas()
end

function PlacementController:LoadCanvas()
	local SuccessfulLoad = PlacementService:LoadCanvas()
end

function PlacementController:ClearCanvas()
	local SuccessfulClear = PlacementService:ClearCanvas()
end


--------------------------------------------------------
-- Runtime Code + Knit Methods
function PlacementController:KnitStart()
	PlacementService = Knit.GetService("PlacementService")
	DataController = Knit.GetController("DataController")
	
	PlacementController:Initialize()
end


--------------------------------------------------------
return PlacementController