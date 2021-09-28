-------------------------------------------------------------------------
--[[
	3gData / Matchmaking Services
	
	Places player in live matches. Currently supports Versus.
	
]]
-------------------------------------------------------------------------
-- Services
local MemoryStoreService = game:GetService("MemoryStoreService")
local RS = game:GetService("ReplicatedStorage")
local HTTP = game:GetService("HttpService")
local Players = game:GetService("Players")
local TPS = game:GetService("TeleportService")
local LocalizationService = game:GetService("LocalizationService")

-------------------------------------------------------------------------
-- Knit
local Knit = require(RS.Shared:WaitForChild("Knit"))
local MatchmakingService = Knit.CreateService{
	Name = "MatchmakingService", Client = {}
}
-------------------------------------------------------------------------
-- Private Functions

function CopyArray(arr)
	local Copy = {}
	for i,v in pairs(arr) do
		Copy[i] = v
	end
	return Copy
end

-------------------------------------------------------------------------
-- MatchmakingService Properties
MatchmakingService.Prefix = "[MatchmakingService]:"
MatchmakingService.Connections = {}


-------------------------------------------------------------------------
-- MatchmakingService Functions

function MatchmakingService:TransferS(...)
	local args = (...)
	local gameMode = args.gameMode
	local ToTransfer = args.Transfer
	
	local Reserved = TPS:ReserveServer(7575997909)
	
	local PlayersToTeleport = {}
	for i,v in pairs(ToTransfer) do
		table.insert(PlayersToTeleport,v.Player)
	end

	if gameMode == "VersusTestRounds" then
		table.foreach(PlayersToTeleport,warn)
		TPS:TeleportToPrivateServer(7575997909,Reserved,PlayersToTeleport,nil,args)
	end
end

function MatchmakingService:ProcessMatch(Player,ArgsOriginal)
	local Args = CopyArray(ArgsOriginal)
	local gameMode = Args.gameMode
	local regionPreference = Args.Region
	local ToTransfer = Args.Transfer
	local FriendOpponent = Args.FriendOpponent
	local Queue = MemoryStoreService:GetQueue("Match:"..gameMode)
	
	for i,v in pairs(Args.Transfer) do
		Args.Transfer[i] = {Player = v, Team = "A"}
	end
	
	
	if not Queue:ReadAsync(5,false,0) then
		Queue:AddAsync({Region = "GB",Members = {"FrankSonatra"}},10)
	end

	local Region = regionPreference or LocalizationService:GetCountryRegionForPlayerAsync(game.Players['3gData'])
	local Tries = 5
	local ToCheck = 100
	local Found = false
	local Data,SerialCode = Queue:ReadAsync(ToCheck,false,0) 

	if not FriendOpponent then
		for i = 1,Tries,1 do
			for i,v in pairs(Data) do
				if v.Region == Region then
						local MembersTeamTwo = v.Members
						for i,v in pairs(MembersTeamTwo) do
							table.insert(Args.Transfer,{Player = v, Team = "B"})
						end
						self:TransferS(Args)
						Found = true
					break
				end
			end
			if Found then
				break
			end
			task.wait(3)
			Data = Queue:ReadAsync(ToCheck,false,0)
		end
	else
		Args.Transfer = {Player,FriendOpponent}
		self:TransferS(Args)
	end
end

-------------------------------------------------------------------------
-- MatchmakingService Functions [Client]
function MatchmakingService.Client:ProcessMatch(...)
	self.Server:ProcessMatch(...)
end

-------------------------------------------------------------------------
-- MatchmakingService Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return MatchmakingService