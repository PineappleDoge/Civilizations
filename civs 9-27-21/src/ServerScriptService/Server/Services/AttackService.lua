--[[
--------------------------------------------------------
-- S1RGames / AttackService
-- Handles troop attacking
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////

	AttackService:Attack(Player: Player, Enemy: Player, Troop : Object of which is ancestor of a Humanoid)
		> Begins attack on the enemy. Player is the player starting the attack, Enemy is the target of the attack.

		
	AttackService:CalculateTarget(Player: Player, Troop : Object of which is ancestor of a Humanoid)
		> Loads BuildingData/Skin to a player's canvas. If CanvasSlot ~= nil, load a specific canvas slot
		
	CanvasService:EnableEditMode(Player: Player)
		> Enables Edit Mode for a player, which allows the player to manage their base
		> Return: Passed: boolean
		
		
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]

-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage
local PLAYERS = game.Players

-------------------------------------------------------------------------
-- SHARED MODULES
local Effects = require(REPLICATED_SERVICE.Shared.Modules.Effects)
-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local AttackService = Knit.CreateService{
	Name = "AttackService", Client = {}
}
local DataService = nil
local PathfindingService = nil
local HealthService = nil

-- // Tables 
local X = 1 -- // Just to save erroring for future refernces, example: PlayerTroop = X - No troop system is set up, so Troop equals X & X is equal to "1"
local AttackingTroops = {}

-------------------------------------------------------------------------
-- Private Functions
function CalculateTarget(Player, Troop)
	local Canvas
	if Player ~= "!GameCreatedCanvas" then
		Canvas = workspace:FindFirstChild("CanvasPart"..Player.UserId)
	else
		Canvas = workspace:FindFirstChild("CanvasPartGameGeneratedCanvas")
	end
	local Buildings = Canvas.Buildings
	local TroopHRP = Troop:FindFirstChild("HumanoidRootPart")

	-- // Here we will store the table information, where we can 
	-- // Score out of 100. (Whole percentage basically, makes it more accurate than just 1-10) 
	local TargetTable = {}

	for _,SingleBuilding in pairs(Buildings:GetChildren()) do
		if Buildings:GetAttribute("StructureHealth")  >= 1 then
			local TargetCFrame = SingleBuilding:GetPivot()
			local TargetPosition = Vector3.new(TargetCFrame.X, TargetCFrame.Y, TargetCFrame.Z)

			local StructureHealth_SCORE = SingleBuilding:GetAttribute("Health") / SingleBuilding:GetAttribute("MaxStructorHealth") * 100 -- // Need to add these contributes*
			local StructureInterestRate_SCORE = SingleBuilding:GetAttribute("StructureInterestRate") * 10-- // Guessing this is based on a scale between 1-10.
			local TroopsDistance_SCORE = (Player:FindFirstChild("HumanoidRootPart").Position - TargetPosition).Magnitude
			if SingleBuilding:GetAttribute("StructureType") == Troop:GetAttribute("PreferredTarget") then
				StructureInterestRate_SCORE = StructureInterestRate_SCORE*1.5
			end
			table.insert(TargetTable, 1, {SingleBuilding = StructureHealth_SCORE + StructureInterestRate_SCORE + TroopsDistance_SCORE})
		end
	end
	table.sort(TargetTable, function(a,b) return a[2] > tonumber(b[2]) end) 
	return TargetTable[1][1]
end

function CreatePlayerFolder(Player, Remove)
	if Remove ~= true then
		if AttackingTroops[Player.UserId] == nil then 
			AttackingTroops[Player.UserId] = {} 
		end
	else 
		if AttackingTroops[Player.UserId] ~= nil then 
			AttackingTroops[Player.UserId] = nil 
		end
	end
	return
end
-------------------------------------------------------------------------
-- ServiceTemplate Properties
AttackService.Prefix = "[AttackService]:"
AttackService.Connections = {}


-------------------------------------------------------------------------
-- AttackService Functions

function AttackService:Attack(Player, Enemy,Troop)
	local Target = CalculateTarget(Enemy)
	local Reached, Error = PathfindingService:MoveToStructure(Player, Troop, Target)
	Reached:Wait()
	if Reached and Troop:FindFirstChild("HumanoidRootPart") ~= nil then
		repeat
			Effects:PlayAnimation({Troop}, Troop:GetAttribute("Attack_AnimationID"))
			HealthService:Damage(Target,"Structure")
			wait(Troop:GetAttribute("Attack_Time"))
		until Troop:FindFirstChild("HumanoidRootPart") == nil or Target:GetAttribute("StructureHealth") <= 1
		if Troop:FindFirstChild("HumanoidRootPart") ~= nil then AttackService:Attack(Player, Enemy,Troop) end -- // So if the Troop is still alive, we can attack again. Quick loop. 
		return
	elseif Troop:FindFirstChild("HumanoidRootPart") ~= nil then -- // Target's been destroyed, by looks of it.
		AttackService:Attack(Player, Enemy,Troop)
		return
	else
		return
	end
end

function AttackService:GetAttackingTroops(Player)
	for PlayersInTable, index in pairs(AttackingTroops) do
		if PlayersInTable == Player.UserId then
			return index
		end
	end
	return nil
end

-------------------------------------------------------------------------
-- ServiceTemplate Functions [Knit Start/Init]
function AttackService:KnitInit()

end

function AttackService:KnitStart()
	DataService = Knit.GetService("DataService")
	PathfindingService = Knit.GetService("PathfindingService")
	HealthService = Knit.GetService("HealthService")
end


-------------------------------------------------------------------------
-- ServiceTemplate Functions [Client]

-------------------------------------------------------------------------
-- ServiceTemplate Runtime Code [Pre-Knit Start/Init]

PLAYERS.PlayerAdded:Connect(function(Player)
	CreatePlayerFolder(Player, false)
end)

PLAYERS.PlayerRemoving:Connect(function(Player)
	CreatePlayerFolder(Player, true)
end)

-------------------------------------------------------------------------
return AttackService