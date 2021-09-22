--------------------------------------------------------
-- PineappleDoge1 | Script Name
-- Date | Update Version
-- Description of what Controller does
--------------------------------------------------------
-- Services
local PLAYERS = game:GetService("Players")
local RUN_SERVICE = game:GetService("RunService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")


--------------------------------------------------------
-- Player Things
local Player = PLAYERS.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")


--------------------------------------------------------
-- Directories
local Shared = REPLICATED_STORAGE:WaitForChild("Shared")
local Client = PlayerScripts:WaitForChild("Client")
local ClientControllers = Client:WaitForChild("Controllers")


--------------------------------------------------------
-- Knit Setup
local Knit = require(Shared:WaitForChild("Knit"))
local Signal = require(Knit.Util.Signal)
local Canvas = require(Knit.Modules.Canvas)
local DataController = Knit.CreateController{
	Name = "DataController"
}

local DataService = nil;


--------------------------------------------------------
-- Private Functions
function TableComp(a,b) --algorithm is O(n log n), due to table growth.
	if #a ~= #b then return false end -- early out

	local t1, t2 = {}, {} -- temp tables

	for k,v in pairs(a) do -- copy all values into keys for constant time lookups
		t1[k] = (t1[k] or 0) + 1 -- make sure we track how many times we see each value.
	end

	for k,v in pairs(b) do
		t2[k] = (t2[k] or 0) + 1
	end
	
	for k,v in pairs(t1) do -- go over every element
		if v ~= t2[k] then return false end -- if the number of times that element was seen don't match...
	end
	
	return true
end


--------------------------------------------------------
-- DataController Properties
DataController.Data = nil
DataController.Prefix = "[DataController]:"
DataController.Connections = {}
DataController.DataLoaded = Signal.new()
DataController.IsDataLoaded = false


--------------------------------------------------------
-- DataController Methods
function DataController:Initialize()
	local DataCopy = DataService:GetPlayerData() 
	local UnserializedCopy = DataService:GetUnserializedPlayerData()
	
	DataCopy.Canvas = Canvas.new(workspace:WaitForChild("CanvasPart" .. Player.UserId, 30).PrimaryPart)
	self.Data = DataCopy
	self.UnserializedData = UnserializedCopy
	self.IsDataLoaded = true
	self.DataLoaded:Fire(self.Data)
	print(("%s Data Successfully Loaded for %s."):format(self.Prefix, game.Players.LocalPlayer.Name))
end

function DataController:GetPlayerData()
	if self.IsDataLoaded == true then
		return self.Data
	end
	
	return self.DataLoaded:Wait()
end

function DataController:GetNewestData()
	self.Data = DataService:GetPlayerData() or self.Data
	self.Data.Canvas = Canvas.new(workspace:WaitForChild("CanvasPart" .. Player.UserId, 30).PrimaryPart)
	return self.Data
end

function DataController:GetNewestUnserializedData()
	self.UnserializedData = DataService:GetUnserializedPlayerData() or self.UnserializedData
	return self.UnserializedData
end


--------------------------------------------------------
-- Runtime Code + Knit Methods
function DataController:KnitStart()
	DataService = Knit.GetService("DataService")
	self:Initialize()
end


--------------------------------------------------------
return DataController