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

local Sounds = {}
-------------------------------------------------------------------------
-- // Services
local PLAYERS = game:GetService("Players")

-------------------------------------------------------------------------
-- // Other variables
local SuitableSoundEffectNames = {
	"Chorus",
	"Compressor",
	"Distortion",
	"Echo",
	"Equalizer",
	"Flange",
	"Pitch",
	"Reverb",
	"Tremolo"
}

-------------------------------------------------------------------------
-- // Private functions

-------------------------------------------------------------------------
-- // Effects functions
-- Animations
function Sounds:Play(Players, AnimationID, PlayData)

end

function Sounds:Pause(Players, AnimationID, PlayData)

end

return Sounds