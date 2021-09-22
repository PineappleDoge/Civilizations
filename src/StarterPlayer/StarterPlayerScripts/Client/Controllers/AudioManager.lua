-------------------------------------------------------------------------
-- PineappleDoge / SoundController
-- Add a description here
-------------------------------------------------------------------------
-- Services
local TWEEN_SERVICE = game:GetService("TweenService")
local SOUND_SERVICE = game:GetService("SoundService")
local REPLICATED_SERVICE = game.ReplicatedStorage


-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local Signal = require(Knit.Util.Signal)
local SoundController = Knit.CreateController{
	Name = "SoundController"
}

local SettingsController = nil


-------------------------------------------------------------------------
-- Private Functions
function MutedSFXChanged(newValue)
	
end

function MutedMusicChanged(newValue)
	
end

function VolumeChanged(newValue)
	
end


-------------------------------------------------------------------------
-- SoundController Properties
SoundController.Prefix = "[SoundController]:"
SoundController.Settings = {
	Volume = 20;
	MutedSFX = false;
	MutedMusic = false;
}
SoundController.Songs = {}
SoundController.Sounds = {}
SoundController.Connections = {}
SoundController.SettingsEvents = {}
SoundController.CurrentSong = nil
SoundController.CurrentSound = nil


-------------------------------------------------------------------------
-- SoundController Functions
function SoundController:Initialize()
	for i, v in pairs(self.Settings) do
		local funcName = i .. "Changed"
		local func = getfenv()[funcName]
		self.Settings[i] = SettingsController:GetSetting(i)
		self.Connections[i .. "Changed"] = SettingsController.SettingsEvents[i]:Connect(func)
	end
end

function SoundController:PlaySound(sound: string | number)
	if self.Settings["MutedSFX"] == true then return end -- Don't play
	-- Converting value to SoundID
	local soundID = ("rbxassetid://%s")
	local songType = type(sound)

	if songType == "number" then
		soundID = string.format(soundID, sound)
	elseif songType == "string" then
		if string.match(string.lower(tostring(sound)), "rbxassetid://") then
			soundID = sound
		end
	end

	local SongInstance = Instance.new("Sound")
	SongInstance.SoundId = soundID
	SongInstance.Volume = 0.5 / self.Settings.Volume 
	SOUND_SERVICE:PlayLocalSound(SongInstance)
end

function SoundController:PlaySong(song: string | number, fade: boolean)
	if self.Settings["MutedMusic"] == true then return end -- Don't play
	
	if self.Songs[song] ~= nil then
		if SoundController.CurrentSong ~= nil then
			if fade == true then
				local Goal = {Volume = 0}
				local TI = TweenInfo.new(1, Enum.EasingStyle.Linear)
				local Tween = TWEEN_SERVICE:Create(self.CurrentSong, TI, Goal)
				Tween:Play()
				Tween.Completed:Wait()
				Tween:Destroy()
			end
			
			self.CurrentSong:Stop()
		end
		
		SOUND_SERVICE:PlayLocalSound(self.Songs[song])
		self.CurrentSong = self.Songs[song]
	else
		-- Converting value to SoundID
		local soundID = ("rbxassetid://%s")
		local songType = type(song)
		
		if songType == "number" then
			soundID = string.format(soundID, song)
		elseif songType == "string" then
			if string.match(string.lower(tostring(song)), "rbxassetid://") then
				soundID = song
			end
		end
		
		local SongInstance = Instance.new("Sound")
		SongInstance.SoundId = soundID
		SongInstance.Looped = true
		SongInstance.Volume = 0.5
		self.CurrentSong = SongInstance
		SOUND_SERVICE:PlayLocalSound(SongInstance)
	end
end

task.defer(function()
	-- SoundController:PlaySong()
end)


-------------------------------------------------------------------------
-- SoundController Functions [Knit Start/Init]
function SoundController:KnitInit()

end

function SoundController:KnitStart()
	SettingsController = Knit.GetController("SettingsController")
	self:Initialize()
end


-------------------------------------------------------------------------
-- SoundController Runtime Code [Pre-Knit Start/Init]
-- print(SoundController.Prefix, "has been initialized")


-------------------------------------------------------------------------
return SoundController