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

local Animations = {}
-------------------------------------------------------------------------
-- // Services

-------------------------------------------------------------------------
-- // Other variables

-------------------------------------------------------------------------
-- // Private functions

-------------------------------------------------------------------------
-- // Animation functions
function Animations.Play(Players: {}, AnimationID : number, PlayData: {} | nil)
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://"..AnimationID
	for _,Characters in pairs(Players) do
		local Animator = (Characters:FindFirstChildOfClass("Humanoid")):FindFirstChildOfClass("Animator")
		if Animator then
			local Track = Animator:LoadAnimation()
			if PlayData ~= nil then
				
			end
			Track:Play()
		end
	end
end

function Animations.Stop(Players, AnimationID)
	local Id = "rbxassetid://"..AnimationID
	for _,Characters in pairs(Players) do
		local Animator = (Characters:FindFirstChildOfClass("Humanoid")):FindFirstChildOfClass("Animator")
		if Animator then
			local PlayingTracks = Animator:GetPlayingAnimationTracks()
			for _, TrackPlaying in pairs(PlayingTracks) do
				if TrackPlaying.Animation.AnimationId == Id then
					TrackPlaying:Stop()
				end
			end
		end
	end
end

function Animations.Pause(Players : {Players}, AnimationID : number)
	-- // Will add at a later date
end

function Animations.Resume(Players : {Players}, AnimationID : number)
	-- // Will add at a later date
end

return Animations