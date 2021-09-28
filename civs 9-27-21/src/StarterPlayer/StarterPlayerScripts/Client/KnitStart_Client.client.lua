--------------------------------------------------------
-- PineappleDoge1 || KnitStart_Client
-- 5-24-2021 || Prototype Update
-- Starts Knit and other controller dependencies on the client
--------------------------------------------------------
-- Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local PLAYERS = game:GetService("Players")


--------------------------------------------------------
-- Player Things
local Player = PLAYERS.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local PlayerScripts = Player:WaitForChild("PlayerScripts")


--------------------------------------------------------
-- Directories
local Shared = REPLICATED_STORAGE:WaitForChild("Shared")
local Client = PlayerScripts:WaitForChild("Client")
local ClientControllers = Client:WaitForChild("Controllers")


--------------------------------------------------------
-- Functions
local function Knit_Success()
	print("[KnitStart_Client]: Knit Started Successfully")
end

local function Knit_Failure(errorMessage)
	print("[KnitStart_Client]: Knit Start Failed. Details:", errorMessage)
end


--------------------------------------------------------
-- Knit Setup
local Knit = require(Shared:WaitForChild("Knit"))
local SignalThing = require(Knit.Util.Signal).new()
local Conn = nil
Conn = Player:GetAttributeChangedSignal("Loaded"):Connect(function()
	Conn:Disconnect()
	SignalThing:Fire()
	SignalThing:Destroy()
end)

SignalThing:Wait()
Knit.Shared = Shared
Knit.Client = Client
Knit.SharedSystems = Shared:WaitForChild("Systems")
Knit.SharedModules = Shared:WaitForChild("Modules")
Knit.Modules = Client:WaitForChild("Modules")
Knit.Assets = Shared:WaitForChild("Assets")

Knit.AddControllers(ClientControllers)


--------------------------------------------------------
Knit:Start()
	:Then(Knit_Success)
	:Catch(Knit_Failure)

-- UnsuspectingSawblade 2021-08-03 11:48:50 Cmdr set-up
local Cmdr = require(game:GetService("ReplicatedStorage"):WaitForChild("CmdrClient"))
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

-- TODO: I don't know, haven't gotten that far