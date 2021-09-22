--[[
--------------------------------------------------------
-- PineappleDoge | DataService
-- Handles creating/getitng player data on player join, alongside saving it on leave
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
	DataService:OnPlayerJoin(Player: Player)
		> Fetches player data and registers the player as "active" in the server.
		> Return: Player Profile (from ProfileService)
	
	DataService:OnPlayerJoin(Player: Player)
		> Serailizes the player's data, cancels any functions/update methods, then saves the player's data.
		> Kicks the player if they're still in the server by any chance
		
	DataService:GetPlayerProfile(Player: Player)
		> Returns the player's profile
		> Return: Player Profile (from ProfileService)
		
	DataService:GetPlayerData(Player: Player)
		> Returns a player's data (from Profile.Data)
		> Return: Player Profile (from ProfileService)
	
	DataService:SetProfileStatus(Player: Player, EnumStatus: string)
		> Sets the player's ProfileStatus to the requested string, and sends an error if non-existant
		
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]

type Profile = {, -- [table] -- Loaded once after ProfileStore:LoadProfileAsync() finishes
	MetaData = {}, -- [table] -- Updated with every auto-save
	GlobalUpdates = GlobalUpdates, -- [GlobalUpdates]
		
	_profile_store = ProfileStore, -- [ProfileStore]
	_profile_key = "", -- [string]
	
	_release_listeners = [ScriptSignal] / nil, -- [table / nil]
	_hop_ready_listeners = [ScriptSignal] / nil, -- [table / nil]
	_hop_ready = false,
		
	_view_mode = true / nil, -- [bool] or nil
		
	_load_timestamp = os.clock(),
		
	_is_user_mock = false, -- ProfileStore.Mock
	_mock_key_info = {},
}


--------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local RUN_SERVICE = game:GetService("RunService")
local SERVER_STORAGE = game:GetService("ServerStorage")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local COLLECTION_SERVICE = game:GetService("CollectionService")


--------------------------------------------------------
-- Knit Setup
local Knit = require(REPLICATED_STORAGE.Shared.Knit)
local Signal = require(REPLICATED_STORAGE.Shared.Knit.Util.Signal)
local Janitor = require(Knit.Util.Janitor)
local RemoteProperty = require(Knit.Util.Remote.RemoteProperty)
local ProfileService = require(Knit.Modules.ProfileService)
local DataService = Knit.CreateService{
	Name = "DataService", Client = {};
}

local BuildingService = nil
local Canvas = require(REPLICATED_STORAGE.Shared.Modules.Canvas)
local BaseData = require(REPLICATED_STORAGE.Shared.Modules.BaseData)
local DefaultData = require(REPLICATED_STORAGE.Shared.Modules.DefaultData)
local MiscFunctions = require(REPLICATED_STORAGE.Shared.Util.Miscellanous)

local count = 0
local PlayersInServer = 0
local autosaveInterval = 60 


--------------------------------------------------------
-- ProfileService \ ReplicaService Setup
local DataVersion = script:GetAttribute("Version") or "1.0"
local GameStore = ProfileService.GetProfileStore("PlayerData_" .. DataVersion, DefaultData())
-- PlayerData_1.0P
-- Player_652000534
local BaseParts = {}

local Enums = {
	Profile_Status = MiscFunctions.MakeEnum("Profile.Status", {"Safe", "Writing", "Removing", "Unknown"});
	Player_Status = MiscFunctions.MakeEnum("Player.GameStatus", {"Idle", "Active", "Shop"})
}


--------------------------------------------------------
-- Private Functions
function OnPlayerJoin(Player: Player)
	local UserID = Player.UserId
	local Results = DataService:OnPlayerJoin(Player)
	DataService.Players[UserID] = Results
	
	PlayersInServer += 1
end

function OnPlayerLeave(Player: Player)
	DataService:OnPlayerLeave(Player)
	PlayersInServer -= 1
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

--
--  

function Autosave(dt: number)
	if count >= autosaveInterval then
		count = 0 
		
		local Profiles = {}
		for ID, Profile in pairs(DataService.Players) do
			local success, result = pcall(function()
				local UnserializedData = DataService.UnserializedData[ID]
				Profile.Data.BaseData = UnserializedData.BaseData:Serialize()
			end)
			
			if success == false then
				local errMsg = string.format("Autosave failed for Player %s [ID: %s]", PLAYERS:GetNameFromUserIdAsync(ID), ID)
				warn(DataService.Prefix .. errMsg, result)
			else
				table.insert(Profiles, Profile)
			end
		end
		
		for i, Profile in ipairs(Profiles) do
			Profile:Save()
		end
		
		print(DataService.Prefix, "Autosave Interval Completed Successfully")
	end	
	
	count += dt
end

function SetupPlayerCanvasInWorkspace(Player: Player, Profile, Skin)
	local CanvasPart = SERVER_STORAGE.Assets[Skin]:Clone()
	local FarthestCanvasPart = BaseParts[#BaseParts]
	local FurthestCanvasCFrame = CFrame.new(table.unpack(string.split(script:GetAttribute("Pos"), ",")))

	if #BaseParts > 0 then
		FurthestCanvasCFrame = FarthestCanvasPart:GetPrimaryPartCFrame()
	end

	CanvasPart.Name = "CanvasPart" .. Player.UserId
	CanvasPart:SetPrimaryPartCFrame(FurthestCanvasCFrame * CFrame.new(-500, 0, 0))

	local Folder = Instance.new("Folder")
	Folder.Name = "Buildings"
	Folder.Parent = CanvasPart
	
	local TroopFolder = Instance.new("Folder")
	TroopFolder.Name = "Troops"
	TroopFolder.Parent = CanvasPart
	
	CanvasPart.Parent = workspace
	
	table.insert(BaseParts, CanvasPart)
	Player:SetAttribute("CanvasPositionInTable", #BaseParts)
	DataService.UnserializedData[Player.UserId].CanvasPart = CanvasPart.PrimaryPart
	COLLECTION_SERVICE:AddTag(CanvasPart, "CanvasPart")
	return CanvasPart
end


--------------------------------------------------------
-- DataService Properties
DataService.Prefix = "[DataService]:"
DataService.Players = {}
DataService.Janitors = {}
DataService.Connections = {}
DataService.UnserializedData = {}

local lookup = {
	[652000534] = function() -- wiping Pineapple's profile to test
		GameStore:WipeProfileAsync("Player_652000534")
	end,
}


--------------------------------------------------------
-- DataService Methods [Player]
function DataService:OnPlayerJoin(Player: Player)
	local UserID = Player.UserId
	
	if lookup[UserID] then
		lookup[UserID]()
	end
	
	DataService.UnserializedData[UserID] = {} 
	local Profile = GameStore:LoadProfileAsync("Player_" .. UserID, "ForceLoad")
	local IsLoaded = (Profile ~= nil and Player:IsDescendantOf(PLAYERS))
	local UnserData = DataService.UnserializedData[UserID]
	
	if (IsLoaded == false and Player:IsDescendantOf(PLAYERS)) == true then
		Player:Kick("Error Code 201: Player data could not be loaded. If error persists, email Roblox or DM a developer.")
	end

	Profile:ListenToRelease(function()
		OnProfileRelease(Player)
	end)
	
	
	----------------------- 
	local SavedBaseData = Profile.Data.BaseData 
	local DeserializedBaseData = BaseData.fromSerialization(SavedBaseData)
	UnserData.BaseData = DeserializedBaseData
	local SkinName = DataService.UnserializedData[UserID].BaseData.Skin or "Default" 
	local PlayerBase = SetupPlayerCanvasInWorkspace(Player, Profile, SkinName)
	UnserData.Canvas = Canvas.new(PlayerBase.PrimaryPart)
	UnserData.ProfileStatusChanged = Signal.new()
	Profile.Data.ProfileStatus = Enums.Profile_Status.Safe
	self.Janitors[UserID] = Janitor.new()
	
	for name, value in pairs(Profile.Data.PlayerData) do
		if type(value) == "table" then 
			continue 
		end
		
		local Property = RemoteProperty.new(value)
		Player:SetAttribute(name, value)
		UnserData[name] = Property
		
		local function PropertyChanged(newValue)
			Player:SetAttribute(name, newValue)
		end
		
		self.Janitors[UserID]:Add(Property)
		self.Janitors[UserID]:Add(Property.Changed:Connect(PropertyChanged))
	end
	
	self.Janitors[UserID]:Add(UnserData.ProfileStatusChanged)
	self.Janitors[UserID]:Add(PlayerBase)
	-----------------------

	return Profile
end

function DataService:OnPlayerLeave(Player: Player)
	local UserID = Player.UserId
	local Profile = DataService.Players[UserID]
	
	if Profile.Data.ProfileStatus ~= Enums.Profile_Status.Safe then
		
	end
	
	local ProfileBaseData = DataService.UnserializedData[UserID].BaseData 
	local SerializedBaseData = ProfileBaseData:Serialize()
	Profile.Data.BaseData = SerializedBaseData
	table.remove(BaseParts, Player:GetAttribute("CanvasPositionInTable"))
	
	for name, child in pairs(DataService.UnserializedData[UserID]) do
	--	if child._isRemoteProperty ~= nil then
	--		Profile.Data.PlayerData[name] = child:Get()
	--	end
	end
	
	Profile:Release()
	self.Janitors[UserID]:Destroy()
	DataService.Players[UserID] = nil
end

function DataService:GetPlayerProfile(Player: Player)
	local UserID = Player.UserId
	
	if (self.Players[UserID] ~= nil) then
		return self.Players[UserID]
	else
		repeat task.wait() until self.Players[UserID] ~= nil
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
			Counter += task.wait()
		until self.Players[UserID] ~= nil or Counter >= 4
		
		if Counter >= 4 then 
			return
		end
	end
	
	return self.Players[UserID].Data
end

function DataService:GetUnserializedPlayerData(Player: Player)
	return DataService.UnserializedData[Player.UserId]
end

function DataService:SetProfileStatus(Player: Player, EnumStatus: string)
	local UserID = Player.UserId
	local Profile = DataService.Players[UserID]
	local UnserData = DataService.UnserializedData[UserID]
	
	if Profile.Data.ProfileStatus ~= Enums.Profile_Status[EnumStatus] then
		Profile.Data.ProfileStatus = Enums.Profile_Status[EnumStatus]
		UnserData.ProfileStatusChanged:Fire(Enums.Profile_Status[EnumStatus])
	end
end

function DataService:ForceSavePlayer(Player: Player)
	
end


--------------------------------------------------------
-- DataService Methods [Canvas]


--------------------------------------------------------
-- DataService Methods [Buildings]


--------------------------------------------------------
function DataService.Client:GetPlayerData(Player: Player)
	return self.Server:GetPlayerData(Player) -- this is a visual copy, so we should extract any data the client doesn't need
end

function DataService.Client:GetUnserializedPlayerData(Player: Player)
	return self.Server:GetUnserializedPlayerData(Player) 
end


--------------------------------------------------------
function DataService:KnitInit()
	
end


function DataService:KnitStart()
	BuildingService = Knit.GetService("BuildingService")
	DataService.Connections["PlayerJoin"] = PLAYERS.PlayerAdded:Connect(OnPlayerJoin)
	DataService.Connections["PlayerLeave"] = PLAYERS.PlayerRemoving:Connect(OnPlayerLeave)
	DataService.Connections['Autosave'] = RUN_SERVICE.Heartbeat:Connect(Autosave)
	DataService.Connections["ServerCrash"] = game:BindToClose(OnGameCrash)
	
	local Players = PLAYERS:GetPlayers()

	for _, player in ipairs(Players) do
		if DataService.Players[player.UserId] == nil then 
			OnPlayerJoin(player)
		end
	end
end


--------------------------------------------------------
return DataService