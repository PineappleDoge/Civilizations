--------------------------------------------------------
-- Author | PlacementService
-- Date | Update Version
-- Description of what Service does
--------------------------------------------------------
-- Services
local SERVER_SCRIPT_SERVICE= game:GetService("ServerScriptService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local SERVER_STORAGE = game:GetService("ServerStorage")
local RUN_SERVICE = game:GetService("RunService")
local PLAYERS = game:GetService("Players")


--------------------------------------------------------
-- Directories
local Shared = REPLICATED_STORAGE:WaitForChild("Shared")
local Server = SERVER_SCRIPT_SERVICE:WaitForChild("Server")
local ServerServices = Server:WaitForChild("Services")


--------------------------------------------------------
-- Knit Setup
local Knit = require(Shared:WaitForChild("Knit"))
local RotatedRegion3 = require(Knit.SharedModules.RotatedRegion3)
local PlacementService = Knit.CreateService{
	Name = "PlacementService", Client = {};
}

local DataService = nil
local BuildingData = require(Knit.SharedSystems.BuildingData)


--------------------------------------------------------
-- Private Functions
function Autosave(totalTime, dt)
	PlacementService.SecondsCount += dt 

	if (PlacementService.SecondsCount >= PlacementService.SaveInterval) then
		PlacementService.SecondsCount = 0 
		
		for userID, userData in pairs(PlacementService.Players) do
			local Player = PLAYERS:GetPlayerByUserId(userID)
			local IsSuccessful = PlacementService:SaveCanvas(Player)
		end
	end
end

function GetBuildingData(Model)
	local CurrentLevel = Model:GetAttribute("Level") or string.match(Model.Name, "Level %d")

	if string.find(CurrentLevel, "Level") then
		CurrentLevel = string.match(CurrentLevel, "%d")
	end

	local ModelName = string.split(Model.Name, " Level")[1]
	local NewLevel = tostring(tonumber(CurrentLevel) + 1)

	return {Level = CurrentLevel; Name = ModelName;}
end

function RegisterPlayer(Player : Player)
	--[[local UserID = Player.UserId
	local Name = workspace:WaitForChild("CanvasPart_" .. Player.Name).Name
	
	local Folder = Instance.new("Folder")
	Folder.Name = "Buildings_" .. UserID
	Folder.Parent = workspace
	Folder:SetAttribute("OwnerID", UserID)
	Folder:SetAttribute("OwnerName", Player.Name)

	PlacementService.Players[UserID] = {
		IsSaving = false;
		IsPlacing = false; 
		Buildings = Folder, 
		CanvasPart = workspace[Name]
	}
	
	return Folder]]
end

function DeregisterPlayer(Player : Player)
	local UserID = Player.UserId

	if PlacementService.Players[UserID] ~= nil then
		PlacementService.Players[UserID] = nil
	end
end

function IsColliding(Model, CF, Player)
	local _, Size = Model:GetBoundingBox()
	
	local NewSize = Vector3.new(Size.X * 0.95, 0, Size.Z * 0.95)
	local Region = RotatedRegion3.new(CF, NewSize)
	local CanvasPart = workspace:FindFirstChild("CanvasPart_" .. Player.Name)
	local IgnoreList = {table.unpack(Model:GetDescendants()), CanvasPart, workspace.Baseplate}
	local Results = Region:FindPartsInRegion3WithIgnoreList(IgnoreList, 200)
	
	for _, v in ipairs(Results) do
		if v:IsDescendantOf(Model) == false and IgnoreList[v] == nil then
			return true
		end
	end

	return false
end


--------------------------------------------------------
-- PlacementService Properties
PlacementService.Prefix = "[PlacementService]: "
PlacementService.Players = {}
PlacementService.Connections = {}
PlacementService.AutoUpgrades = {}
PlacementService.SecondsCount = 0 -- this'll get updated by the Heartbeat loop.
PlacementService.CurrentlyUpgrading = {}
PlacementService.SaveInterval = script:GetAttribute("AutosaveInterval") or 30


--------------------------------------------------------
-- PlacementService Methods
function PlacementService:InitializePlayer(Player)
	RegisterPlayer(Player)
end

function PlacementService:IsColliding(Model, CF, Player)
	return IsColliding(Model, CF, Player)
end

function PlacementService:CloneModel(Player, modelName)
	local UserID = Player.UserId
	local PlayerData = self.Players[UserID]
	local Model = Knit.Assets[modelName]:Clone()
	Model.Parent = workspace

	return Model
end


--------------------------------------------------------
-- PlacementService Methods <<|Placement|>>
function PlacementService:Place(Player, Model, ModelCFrame, str)
	local UserID = Player.UserId
	local PlayerData = self.Players[UserID]
	local CanvasPart = PlayerData.CanvasPart.Name
	local IsColliding = self:IsColliding(Model, ModelCFrame, Player)
	
	local FolderName = "Buildings_" .. Player.UserId 
	local FolderObject = workspace[FolderName] 
	local IsModelDescendantOfCanvas = Model:IsDescendantOf(FolderObject)
	local ModelData = GetBuildingData(Model)
	local DoesModelHasData = BuildingData:FindBuildingData(ModelData.Name) 
	
	assert(PlayerData.IsSaving == false, "Player is currently saving data at the moment.")
	assert(PlayerData.IsPlacing == false, "Player is currently placing objects at the moment.")
	
	if IsModelDescendantOfCanvas == true then -- they're replacing a model, don't charge em
		if IsColliding == false then
			if Model:IsDescendantOf(PlayerData.Buildings) == true then
				Model:SetPrimaryPartCFrame(ModelCFrame)
				return true
			else
				local DataModel = Model:Clone()
				DataModel:SetPrimaryPartCFrame(ModelCFrame)
				DataModel.Parent = PlayerData.Buildings
			end

			return true
		end
		
	elseif IsModelDescendantOfCanvas == false then -- newplacement, charge em
		if DoesModelHasData ~= nil then
			if IsColliding == false then
				local PlrData = DataService:GetPlayerData(Player)
				local PlrCurrency = PlrData.PlayerData.Currency:Get()
				local AmountToSpend = DoesModelHasData.UpgradeCost(ModelData.Level)
				local CanPurchase = PlrCurrency - AmountToSpend
				
				if CanPurchase >= 0 then
					local DataModel = Model:Clone()
					DataModel:SetPrimaryPartCFrame(ModelCFrame)
					DataModel.Parent = PlayerData.Buildings
					DataService:BuyBuilding(Player, AmountToSpend)
					return true
				end
			end
		end
	end

	return false
end

function PlacementService:SaveCanvas(Player)
	local UserID = Player.UserId
	local PlayerData = self.Players[UserID]
	local CanvasPart = PlayerData.CanvasPart
	local CanvasSize = tostring(CanvasPart.PrimaryPart.Size.X .. "x" .. CanvasPart.PrimaryPart.Size.Z)
	local Buildings = PlayerData.Buildings:GetChildren()
	local CanvasData = {CanvasSize} -- first argument is the canvasSize
	
	for index, model in pairs(Buildings) do
		local ModelName, ModelCFrame = model.Name, model:GetPrimaryPartCFrame()
		local ModelOffset = CanvasPart.PrimaryPart.CFrame:ToObjectSpace(ModelCFrame)
		CanvasData[#CanvasData + 1] = {Name = ModelName, Location = ModelOffset}
	end
	
	local IsSaveSuccessful, errMessage = DataService:SavePlayerCanvas(Player, CanvasData)
	return IsSaveSuccessful
end

function PlacementService:LoadCanvas(Player)
	local UserID = Player.UserId
	local PlayerData = self.Players[UserID]
	local Buildings = PlayerData.Buildings
	local CanvasData = DataService:LoadPlayerCanvas(Player)
	local PlayerFolder = workspace:FindFirstChild("Buildings_" .. UserID)
	
	if CanvasData == nil then
		return false, "Canvas save could not be loaded."
	elseif CanvasData ~= nil then
		self:ClearCanvas(Player)
		for i, v in ipairs(CanvasData) do
			if i == 1 then continue end -- this is the canvas size
			local Model = Knit.Assets:FindFirstChild(v.Name)

			if Model ~= nil then
				local ModelClone = Model:Clone()
				ModelClone.Parent = PlayerFolder
				ModelClone:SetPrimaryPartCFrame(PlayerData.CanvasPart.CFrame * v.Location)
			end
		end
		
		return true
	end
end

function PlacementService:ClearCanvas(Player)
	local UserID = Player.UserId
	local PlayerData = self.Players[UserID]
	local Buildings = PlayerData.Buildings
	
	for index, child in pairs(Buildings:GetChildren()) do
		if child:IsA("Model") then
			child:Destroy()
		end
	end
	
	if #PlayerData.Buildings:GetChildren() == 0 then
		return true
	else
		return false, "Not all buildings have been destroyed."
	end
end

function PlacementService:RequestUpgrade(Player, Model)
	local UserID = Player.UserId
	local PlayerData = self.Players[UserID]
	local Buildings = PlayerData.Buildings
	
	assert(Model:IsDescendantOf(Buildings), "Model isn't on the canvas.")
	local CurrentLevel = Model:GetAttribute("Level") or string.match(Model.Name, "Level %d")
	local ModelName = string.split(Model.Name, " Level")[1]
	local NewLevel = tostring(tonumber(CurrentLevel) + 1)
	local ModelData = BuildingData:FindBuildingData(ModelName)
	
	if string.find(CurrentLevel, "Level") then
		CurrentLevel = string.match(CurrentLevel, "%d")
	end
	
	if CurrentLevel > 0 then
		if ModelData ~= nil then
			local PlrData = DataService:GetPlayerData(Player)
			local PlayerCurrency = PlrData.PlayerData.Currency
			local ModelCost = ModelData.UpgradeCost(NewLevel)
			local UpgradeTime = ModelData.UpgradeTime(NewLevel)
			
			if PlayerCurrency - ModelCost >= 0 then
				local CurrentTime = os.time()
				local NewTime = CurrentTime + UpgradeTime
				local TimePacket = {CurrentTime, NewTime}
				local BuildingPacket = {
					OldBuildingData = {Name = ModelName, Level = CurrentLevel, Skin = "Default"};
					NewBuildingData = {Name = ModelName, Level = NewLevel, Skin = "Default"};
				}
				
				local successful, Results = DataService:StartUpgrade(Player, TimePacket, BuildingPacket)
				if successful then
					if Results ~= nil then
						if Results.Timer ~= nil then
							Results.Timer:OnFinished(function()
								local NewModelName = string.gsub(Model.Name, "Level %d", "Level " ..  NewLevel)
								local ModelCFrame = Model:GetPrimaryPartCFrame()
								local NewModel = Knit.Assets[NewModelName]:Clone()
								NewModel:SetPrimaryPartCFrame(ModelCFrame)
								NewModel.Parent = Buildings

								Model:Destroy()
							end)
						end
					end
				end
				return true, TimePacket -- indicate it's successful
			else
				return false, "Failure" -- failure
			end
		end
	end
end

--[[
local NewLevelString = "Level " .. NewLevel
local NewModelName = string.gsub(Model.Name, "Level %d", NewLevelString)
local ModelExists = (Knit.Assets[NewModelName] ~= nil)

if Knit.Assets:FindFirstChild(NewModelName) ~= nil then
					local OldBuildingData = {Name = ModelName, Level = CurrentLevel, Skin = "Default"} 
					local NewBuildingData = {Name = ModelName, Level = NewLevel, Skin = "Default"}

					local IsUpgradeSuccessful = DataService:UpgradeBuilding(Player, OldBuildingData, NewBuildingData)
					local ModelCFrame = Model:GetPrimaryPartCFrame()
					local NewModel = Knit.Assets[NewModelName]:Clone()
					NewModel:SetPrimaryPartCFrame(ModelCFrame)
					NewModel.Parent = Buildings

					Model:Destroy()
					return true
				else
					return false, "Error 301: Asset ['" .. NewModelName .. "'] does not exist."
				end
]]

--------------------------------------------------------
-- PlacementService Client Methods [Placement]
function PlacementService.Client:IsColliding(Player, Model, CF)
	return IsColliding(Model, CF)
end

function PlacementService.Client:CloneModel(Player, modelName)
	return self.Server:CloneModel(Player, modelName)
end

function PlacementService.Client:Place(Player, Model, CF, str)
	return self.Server:Place(Player, Model, CF, str)
end
	

--------------------------------------------------------
-- PlacementService Client Methods [Canvas Saving]
function PlacementService.Client:SaveCanvas(Player : Player)
	return self.Server:SaveCanvas(Player)  
end

function PlacementService.Client:LoadCanvas(Player)
	return self.Server:LoadCanvas(Player) 
end

function PlacementService.Client:ClearCanvas(Player)
	return self.Server:ClearCanvas(Player)
end

function PlacementService.Client:RequestUpgrade(Player, Building)
	return self.Server:RequestUpgrade(Player, Building)
end
	

--------------------------------------------------------
-- Runtime Code + Knit Methods
PlacementService.Connections["AutoSave"] = RUN_SERVICE.Stepped:Connect(Autosave)
PlacementService.Connections["PlayerAdded"] = PLAYERS.PlayerAdded:Connect(RegisterPlayer)
PlacementService.Connections["PlayerLeave"] = PLAYERS.PlayerRemoving:Connect(DeregisterPlayer)

function PlacementService:KnitStart()
	DataService = Knit.GetService("DataService")
end


--------------------------------------------------------
return PlacementService