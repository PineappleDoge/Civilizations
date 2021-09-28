--[[
--------------------------------------------------------
-- S1RGames | Effects
-- Module for multiple effects from sounds to Animations.
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////


		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
]]

local Effects = {}

-------------------------------------------------------------------------
-- // Modules
local Sounds = require(script.Sounds)
local Animations = require(script.Animations)

-------------------------------------------------------------------------
-- // Other variables
local DefaultSoundValues = {
	Looped = false,
	PlayTime = "Full"
}
-------------------------------------------------------------------------
-- // Private functions
function VerifyINT(ID: number): boolean -- Used for stuff such as IDs, to make sure they are just the number IDs
	local Characters = string.split(tostring(ID), "")
	for _,v in pairs(Characters) do
		if not v:match("%d+") then
			return false
		end
	end

	return true
end

function VerifyHumanoids(HumanoidAncestors: {}): boolean
	for _,PotentialHumanoids in pairs(HumanoidAncestors) do
		if PotentialHumanoids:FindFirstChildOfClass("Humanoid") == nil then
			return false
		end
	end
	return true
end

function AnimationParametersCheck(HumanoidAncestors: {}, AnimationID: number): boolean
	if HumanoidAncestors == nil or AnimationID == nil then warn("HumanoidAncestor, or AnimationID (or both) are nil. Please make sure ALL of them are correct") return false end
	if VerifyHumanoids(HumanoidAncestors) then
		local AnimationIDType = VerifyINT(AnimationID)
		if AnimationIDType then
			return true
		else 
			warn("AnimationID MUST be a NUMERIC Value. Other characters detected")
			return false
		end
	else 
		warn("PlayAnimation requires ALL HumanoidAncestor to have a 'Humanoid' as a child. Animation:"..tostring(AnimationID).." has not been played.")
		return false
	end
end

-------------------------------------------------------------------------
-- // Effects functions
-- Animations

function Effects:PlayAnimation(HumanoidAncestors: {}, AnimationID: number, ExtraInfo: {})
	if ExtraInfo == nil then warn("WARNING - ExtraInfo on animation ".. AnimationID .." IS NIL. This WILL use DEFAULT Data.")
		if AnimationParametersCheck(HumanoidAncestors, AnimationID) then
			Animations:Play(HumanoidAncestors, AnimationID, nil)
		end
	end
end

function Effects:StopAnimations(HumanoidAncestors: {}, AnimationID: number)
	if AnimationParametersCheck(HumanoidAncestors, AnimationID) then
		Animations:Stop(HumanoidAncestors, AnimationID)
	end
end

function Effects:PauseAnimations(HumanoidAncestors: {}, AnimationID: number)
	if AnimationParametersCheck(HumanoidAncestors, AnimationID) then
		Animations:Pause(HumanoidAncestors, AnimationID)
	end
end

function Effects:ResumeAnimations(HumanoidAncestors: {Players}, AnimationID: number)
	if AnimationParametersCheck(HumanoidAncestors, AnimationID) then
		Animations:Resume(HumanoidAncestors, AnimationID)
	end
end
-- Sounds

function Effects:PlaySound(SoundID: number, Looped: BoolValue, PlayTime: number|BoolValue)
	
end

-- Sounds

-- UI

-- Particles


return Effects