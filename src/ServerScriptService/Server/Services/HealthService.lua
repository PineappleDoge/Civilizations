--[[
--------------------------------------------------------
-- S1RGames | CanvasService
-- Handles creating/getitng player data on player join, alongside saving it on leave
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////

	:Damage(Object: Player | Model, isATroop_orStructure: string, Damage: number)
		> Deals damage to object.
		>> Object must be Player or structure.
		> isATroop_orStructure define "troop" or "structure"
		
	:Heal(Object: Player | Model, isATroop_orStructure: string, Health: number)
		> Add health to said object.
		>> Object must be Player or structure.
		> isATroop_orStructure define "troop" or "structure"
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]
-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage

-- SHARED MODULES
local Effects = require(REPLICATED_SERVICE.Shared.Modules.Effects)

-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local HealthService = Knit.CreateService{
	Name = "HealthService", Client = {}
}


-------------------------------------------------------------------------
-- Private Functions

-------------------------------------------------------------------------
-- ServiceTemplate Properties
HealthService.Prefix = "[HealthService]:"
HealthService.Connections = {}


-------------------------------------------------------------------------
-- ServiceTemplate Functions
function HealthService:Damage(Object, isATroop_orStructure: string, Damage: number)
	if isATroop_orStructure:lower() ~= ("troop" or "structure") then warn("isATroop_orStructure MUST be TROOP or STRUCTURE. Allows us to check what Object is") return end

	local NewHeath = (Object:GetAttribute("Health") - Damage)
	if NewHeath < 0 then
		NewHeath = 0
	end
	Object:SetAttribute("Health", NewHeath)
	if NewHeath <= 0 then
		if isATroop_orStructure:lower() == "troop" then
			Effects:PlayAnimation({Object}, Object:GetAttribute("Death_AnimationId"))
		elseif isATroop_orStructure:lower() == "structure" then
			if Object:IsA("Model") then
				local Size = Object:GetAttribute("BaseSize")
				if Knit.Assets["RubbleSets"]["Rubble "..Size.."x"..Size] == nil then warn("Rubble "..Size.."x"..Size.. " - Is not valid.") return end

				local RubbleStructure = Knit.Assets["RubbleSets"]["Rubble "..Size.."x"..Size]:Clone()
				for _,Descendant in pairs(Object:GetDescendants()) do
					if Descendant ~= Object.PrimaryPart or Descendant.Name ~= "BuildingBase" and Descendant:IsA("BasePart") then
						Descendant:Destroy()
					end
				end
				RubbleStructure.Parent = Object
				RubbleStructure:SetPrimaryPartCFrame(Object:GetPrimaryPartCFrame())
			end
		end
	end
end

function HealthService:Heal(Object,isATroop_orStructure: string, Health: number)
	if isATroop_orStructure:lower() ~= ("troop" or "structure") then warn("isATroop_orStructure MUST be TROOP or STRUCTURE. Allows us to check what Object is") return end

	local NewHeath = (Object:GetAttribute("Health") + Health)
	if NewHeath > Object:GetAttribute("MaxHealth") then
		NewHeath = Object:GetAttribute("MaxHealth")
	end
	Object:SetAttribute("Health", NewHeath)
end

-------------------------------------------------------------------------
-- ServiceTemplate Functions [Knit Start/Init]
function HealthService:KnitInit()

end

function HealthService:KnitStart()


end


-------------------------------------------------------------------------
-- ServiceTemplate Functions [Client]
function HealthService.Client:DoSomething(Player)

	return self.Server:DoSomething(Player)
end


-------------------------------------------------------------------------
-- ServiceTemplate Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return HealthService
