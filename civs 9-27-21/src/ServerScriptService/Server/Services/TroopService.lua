-------------------------------------------------------------------------
-- S1RGames / TroopService
-- Add a description here
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage

-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local TroopService = Knit.CreateService{
	Name = "ServiceTemplate", Client = {}
}

local DataService = nil
local AttackService = nil

local TroopsPlaced = {}
local TroopDataModule = require(REPLICATED_SERVICE.Shared.Systems.TroopData)

-------------------------------------------------------------------------
-- Private Functions

function Check(Player, OwnedTroops, Troop, Canvas, Position)
	-- // Data checks / inventory checks / position checks here.
	local Results = {}
	local Minimum, Maximum = Canvas.DEMO_CANVAS.Position +(Vector3.new(Canvas.DEMO_CANVAS.Size.X*.5,Canvas.DEMO_CANVAS.Size.Y*.5,Canvas.DEMO_CANVAS.Size.Z*.5)*-1) , Canvas.DEMO_CANVAS.Position + Vector3.new(Canvas.DEMO_CANVAS.Size.X*.5,Canvas.DEMO_CANVAS.Size.Y*.5,Canvas.DEMO_CANVAS.Size.Z*.5)

	Results.PositionCheck = (Position.X >= Minimum.X and Position.X <= Maximum.X and Position.Z >= Minimum.Z and Position.Z <= Maximum.Z)
	Results.Owned = OwnedTroops[Troop]
	Results.MaxSpawned = TroopsPlaced[Player.UserId][Troop] ~= nil and TroopsPlaced[Player.UserId][Troop] < OwnedTroops[Troop].MaximumPlaced
	
	--// Loop through canvas buildings to make sure they aren't close
	for _,v in pairs(Canvas.Buildings) do
		if v.PrimaryPart ~= nil and (v.PrimaryPart.Position - Position).Magnitude < 10 then
			return false
		end
	end
	
	-- // Loop through the results to make sure all are true.
	for _,v in pairs(Results) do
		if v ~= true then
			return false
		end
	end

	return true
end

function SpawnEffects(TroopModel)
	spawn(function()
		-- // Do any spawn particles here, any spawn stuff as such.
	end)
end

function RemoveTroopPlaced(Player, Troop, Reset)
	if Reset then
		TroopsPlaced[Player.UserId] = {}
		return
	end
	-- // remove one troop here below v

end

-------------------------------------------------------------------------
-- ServiceTemplate Properties
TroopService.Prefix = "[ServiceTemplate]:"
TroopService.Connections = {}


-------------------------------------------------------------------------
-- ServiceTemplate Functions
function TroopService:UpgradeTroop(Player: Player, Packet)
	local ProfileData = DataService:GetPlayerData(Player)
	local BaseData = DataService:GetUnserializedPlayerData(Player).BaseData
	local OwnedTroops = BaseData.Troops
	local TroopData = TroopDataModule:GetTroopData({TroopType = Packet.Type, Level = Packet.Level})
	if OwnedTroops[Packet.TroopId] == nil then return false end

end

function TroopService:BuyTroop(Player: Player, Packet)
	
	-- // Data
	local ProfileData = DataService:GetPlayerData(Player)
	local BaseData = DataService:GetUnserializedPlayerData(Player).BaseData
	local TroopData = TroopDataModule:GetTroopData({TroopType = Packet.Type, Level = Packet.Level})
	
	-- // Troop data
	local OwnedTroops = BaseData.Troops
	if OwnedTroops[Packet.TroopId] == nil then 
		OwnedTroops[Packet.TroopId] = {}
		OwnedTroops[Packet.TroopId].MaximumPlaced = 0
		OwnedTroops[Packet.TroopId].TroopLevel = 1
	end
	
	local AmountOwned = OwnedTroops[Packet.TroopId].MaximumPlaced
	local TroopLevel = OwnedTroops[Packet.TroopId].TroopLevel
	
	local CurrencyType = TroopData.Overall.CostType
	local OwnedCurrency = DataService:GetUnserializedPlayerData(Player)[CurrencyType]:Get()
	
	local TroopCost
	
	if AmountOwned >= 1 then
		TroopCost = TroopData.Overall.Levels["-_"..TroopLevel].Training_Cost * AmountOwned
	else
		TroopCost = TroopData.Overall.Levels["-_"..TroopLevel].Training_Cost
	end

	local RemainingCurrency = OwnedCurrency - TroopCost
	local Results = {}

	if RemainingCurrency >= 0 then
		DataService:GetUnserializedPlayerData(Player)[CurrencyType]:Set(RemainingCurrency)
		OwnedTroops[Packet.TroopId].MaximumPlaced += 1
		Results.Passed = true
	else
		Results.Passed = false
	end

	return Results
end

function TroopService:PlaceTroop(Player: Player, Packet)
	if TroopsPlaced[Player.UserId] == nil then TroopsPlaced[Player.UserId] = {} end

	local ProfileData = DataService:GetPlayerData(Player)
	local BaseData = DataService:GetUnserializedPlayerData(Player).BaseData
	local Troops = BaseData.Troops
	local PlacementPosition = Packet.PlacementPosition
	local TroopData = TroopDataModule:GetTroopData({TroopType = Packet.Type, Level = Packet.Level})
	local Base = workspace["CanvasPart" .. Player.UserId]

	-- // Quick check to make sure ofc.
	if not Check(Player, Troops,Packet.TroopId, Base, PlacementPosition) then return false end
	table.insert(TroopsPlaced[Player.UserId], Packet.TroopId)

	local TroopClone = Knit.Assets.Troops[Packet.TroopName]:Clone()

	-- // X level info 
	TroopClone:SetAttribute("MaxHealth", TroopData.Level.HP)
	TroopClone:SetAttribute("Heath", TroopClone:GetAttribute("MaxHealth"))
	TroopClone:SetAttribute("Range", TroopData.Level.Range)

	-- // Type info
	TroopClone:SetAttribute("PreferredTarget", TroopData.Overall.PreferredTarget)
	TroopClone:SetAttribute("AttackType", TroopData.Overall.AttackType)
	TroopClone:SetAttribute("AttackSpeed", TroopData.Overall.AttackSpeed)
	TroopClone:SetAttribute("MovementSpeed", TroopData.Overall.MovementSpeed)
	TroopClone:SetAttribute("Houseing_Space", TroopData.Overall.Houseing_Space)
	TroopClone:SetAttribute("Barracks_Level_Required", TroopData.Overall.Barracks_Level_Required)

	TroopClone.Parent = Base:FindFirstChild("Troops")
	TroopClone:SetPrimaryPartCFrame(PlacementPosition + Vector3.new(0,1,0))
	SpawnEffects(TroopClone)

	AttackService:Attack(Player, Player, TroopClone)
	return true
end


-------------------------------------------------------------------------
-- ServiceTemplate Functions [Knit Start/Init]
function TroopService:KnitInit()

end

function TroopService:KnitStart()
	DataService = Knit.GetService("DataService")
	AttackService = Knit.GetService("AttackService")
end

-------------------------------------------------------------------------
-- ServiceTemplate Functions [Client]
function TroopService.Client:PlaceTroop(Player: Player, Packet)	
	return self.Server:PlaceTroop(Player, Packet)
end

function TroopService.Client:BuyTroop(Player: Player, Packet)	
	return self.Server:BuyTroop(Player, Packet)
end

function TroopService.Client:UpgradeTroop(Player: Player, Packet)	
	return self.Server:UpgradeTroop(Player, Packet)
end

-------------------------------------------------------------------------
-- ServiceTemplate Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return TroopService