--------------------------------------------------------
-- PineappleDoge | DataService
-- 5-24-2021 | Prototype
-- Handles Management + Replication of Player Data
--------------------------------------------------------
-- Services
local SERVER_SCRIPT_SERVICE= game:GetService("ServerScriptService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local COLLECTION_SERVICE = game:GetService("CollectionService")
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
local Option = require(Knit.Util.Option)
local DeepCopy = require(Knit.SharedModules.DeepCopy)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)
local RemoteProperty = require(Knit.Util.Remote.RemoteProperty)
local DataService = Knit.CreateService{
	Name = "DataService", Client = {Data = Option.None};
}

local TimerModule = require(Knit.SharedModules.Timer)
local DefaultData = require(script:WaitForChild("DefaultData"))
local ProfileService = require(Knit.Modules.ProfileService)


--------------------------------------------------------
-- ProfileService \ ReplicaService Setup
local DataVersion = script:GetAttribute("Version") or "1.0"
local GameStore = ProfileService.GetProfileStore("PlayerData_" .. DataVersion, {})
local BaseParts = {}


--------------------------------------------------------
-- Private Functions
function OnPlayerJoin(Player: Player)
	local UserID = Player.UserId
	local Results = DataService:OnPlayerJoin(Player)
	DataService.Players[UserID] = Results
end

function OnPlayerLeave(Player: Player)
	DataService:OnPlayerLeave(Player)
end

function OnGameCrash()
	for i, player in pairs(PLAYERS:GetPlayers()) do
		OnPlayerLeave(player)
	end
end

function OnProfileRelease(Player)
	local UserID = Player.UserId

	DataService.Players[UserID] = nil
	Player:Kick("Player kicked to preserve data safety.")
end

function CreateDefaultData()
	return DefaultData()
end


--------------------------------------------------------
-- DataService Properties
DataService.Prefix = "[DataService]: "
DataService.Players = {}
DataService.Connections = {}
DataService.ServerBanned = {}


--------------------------------------------------------
-- DataService Methods [Player]
function DataService:OnPlayerJoin(Player)
	local UserID = Player.UserId
	local Profile = GameStore.Mock:LoadProfileAsync("Player_" .. UserID, "ForceLoad")
	local IsLoaded = (Profile ~= nil and Player:IsDescendantOf(PLAYERS))

	if (IsLoaded == false and Player:IsDescendantOf(PLAYERS)) == true then
		Player:Kick("Error Code 201: Player data could not be loaded. If error persists, email Roblox or DM a developer.")
	end

	Profile:ListenToRelease(function()
		OnProfileRelease(Player)
	end)

	----------------------- 
	if #Profile.Data <= 0 then
		local PlayerData, BuildingData, MiscellanousData = DefaultData()
		
		Profile.Data["Miscellanous"] = MiscellanousData
		Profile.Data["PlayerData"] = PlayerData
		Profile.Data["Buildings"] = BuildingData
		Profile.Data.Canvas = {}
		
		coroutine.wrap(function()
			for name, value in pairs(PlayerData) do
				Player:SetAttribute(name, value:Get())
			end
		end)()
		
		local CanvasPart = workspace.GrassScene:Clone()
		local FarthestCanvasPart = BaseParts[#BaseParts]

		CanvasPart.Name = "CanvasPart_" .. Player.Name 
		CanvasPart:SetPrimaryPartCFrame(FarthestCanvasPart:GetPrimaryPartCFrame() * CFrame.new(-500, 0, 0))
		CanvasPart.Parent = workspace

		BaseParts[#BaseParts + 1] = CanvasPart
		Profile.Data.CanvasPart = CanvasPart.PrimaryPart
		COLLECTION_SERVICE:AddTag(CanvasPart, "CanvasPart")
	end
	-----------------------

	return Profile
end

function DataService:OnPlayerLeave(Player)
	local UserID = Player.UserId
	local Profile = DataService.Players[UserID]
	BaseParts[#BaseParts] = nil

	if Profile == nil then
		return
	end

	Profile:Release()
end

function DataService:GetPlayerProfile(Player: Player)
	local UserID = Player.UserId
	
	if (self.Players[UserID] ~= nil) then
		return self.Players[UserID]
	else
		repeat RUN_SERVICE.Heartbeat:Wait() until self.Players[UserID] ~= nil
		return self.Players[UserID]
	end 
end

function DataService:GetPlayerData(Player: Player)
	local UserID = Player.UserId
	local Counter = 0
	
	if (self.Players[UserID] ~= nil) then
		return self.Players[UserID].Data
	else
		repeat 
			Counter += RUN_SERVICE.Heartbeat:Wait() 
		until self.Players[UserID] ~= nil or Counter >= 4
		
		if Counter >= 4 then 
			return
		end
	end
	
	return self.Players[UserID].Data
end


--------------------------------------------------------
-- DataService Methods [Canvas]
function DataService:SavePlayerCanvas(Player: Player, canvasInfo)
	local UserID = Player.UserId
	local UserData = self.Players[UserID]
	UserData.Data.Canvas = canvasInfo
	
	if UserData.Data.Canvas == canvasInfo then
		return true
	else
		return false, "Failed to save data"
	end
end

function DataService:LoadPlayerCanvas(Player : Player, canvasPart)
	local UserID = Player.UserId
	local UserData = self.Players[UserID]
	local CanvasSize = UserData.Data.Canvas[1]
	local CanvasPart = UserData.Data.CanvasPart
	local PlayerFolder = workspace:FindFirstChild("Buildings_" .. UserID)
	local CanvasDataCopy = UserData.Data.Canvas
	
	if CanvasDataCopy ~= nil then
		return CanvasDataCopy
	else
		return nil, "no data saved"
	end
end


--------------------------------------------------------
-- DataService Methods [Buildings]
function DataService:StartPlacement(player, timePacket, modelPacket)
	local UserID = player.UserId
	local UserData = self.Players[UserID].Data
	local UpgradingBuilding = {
		BuildingData = modelPacket;
		TimeData = timePacket;
		Timer = TimerModule.new(timePacket[2] - timePacket[1])
	}

	UpgradingBuilding.Timer:Start()
	UpgradingBuilding.Timer:OnFinished(function()
		self:AddBuilding(player, modelPacket.OldBuildingData, modelPacket.NewBuildingData)
		print("Finished")
	end)

	table.insert(UserData["Miscellanous"], UpgradingBuilding)
	return true, UpgradingBuilding
end

function DataService:StartUpgrade(player, timePacket, buildingPacket)
	local UserID = player.UserId
	local UserData = self.Players[UserID].Data
	local UpgradingBuilding = {
		BuildingData = buildingPacket;
		TimeData = timePacket;
		Timer = TimerModule.new(timePacket[2] - timePacket[1])
	}
	
	UpgradingBuilding.Timer:Start()
	UpgradingBuilding.Timer:OnFinished(function()
		self:AddBuilding(player, buildingPacket)
		print("Finished Building")
	end)
	
	table.insert(UserData["Miscellanous"], UpgradingBuilding)
	return true, UpgradingBuilding
end

function DataService:AddBuilding(player, newBuildingData)
	local UserID = player.UserId
	local UserData = self.Players[UserID].Data
	
	for i, buildingData in ipairs(UserData.Buildings) do
		if buildingData.Name == newBuildingData.Name and buildingData.Level == newBuildingData.Level then
			buildingData.Amount += 1
		elseif buildingData.Name ~= newBuildingData.Name then
			table.insert(UserData, newBuildingData)
		end
	end
end

function DataService:UpgradeBuilding(player, oldBuildingData, newBuildingData)
	local UserID = player.UserId
	local UserData = self.Players[UserID].Data
	
	for i, buildingData in ipairs(UserData.Buildings) do
		if buildingData.Name == oldBuildingData.Name and buildingData.Level == oldBuildingData.Level then
			if buildingData.Amount > 1 then
				table.insert(UserData.Buildings, newBuildingData)
				buildingData.Amount -= 1
			elseif buildingData.Amount == 1 then
				UserData.Buildings[i] = nil
				table.insert(UserData.Buildings, newBuildingData)
			end
			
			return true
		end
	end
	
	return false, "Could not be found"
end

function DataService:BuyBuilding(Player, amount)
	local UserID = Player.UserId
	local UserData = self.Players[UserID].Data
	local PlayerData = UserData.PlayerData
	local NewAmount = PlayerData.Currency:Get() - amount 
	
	if NewAmount < 0 then 
		return
	elseif NewAmount >= 0 then
		print(PlayerData.Currency:Get(), NewAmount)
		UserData.PlayerData.Currency:Set(NewAmount)
		Player:SetAttribute("Currency", PlayerData.Currency:Get())
	end
end


--------------------------------------------------------
function DataService.Client:GetPlayerData(player: Player)
	return self.Server:GetPlayerData(player) -- this is a visual copy, so we should extract any data the client doesn't need
end


--------------------------------------------------------
-- Runtime Code + Knit Methods
table.insert(BaseParts, workspace.GrassScene)

DataService.Connections["PlayerJoin"] = PLAYERS.PlayerAdded:Connect(OnPlayerJoin)
DataService.Connections["PlayerLeave"] = PLAYERS.PlayerRemoving:Connect(OnPlayerLeave)
DataService.Connections["ServerCrash"] = game:BindToClose(OnGameCrash)

function DataService:KnitInit() -- If players have already joined, we use this method to automatically add them
	local Players = PLAYERS:GetPlayers()

	for _, player in ipairs(Players) do
		OnPlayerJoin(player)
	end
end


--------------------------------------------------------
return DataService