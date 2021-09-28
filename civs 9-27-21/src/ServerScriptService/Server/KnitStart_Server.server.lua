--------------------------------------------------------
-- PineappleDoge1 || KnitStart_Server
-- 5-24-2021 || Prototype Update
-- Starts Knit and other controller dependencies on the server
--------------------------------------------------------
-- Services
local SERVER_SCRIPT_SERVICE= game:GetService("ServerScriptService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local SERVER_STORAGE = game:GetService("ServerStorage")


--------------------------------------------------------
-- Directories
local Shared = REPLICATED_STORAGE:WaitForChild("Shared")
local Server = SERVER_SCRIPT_SERVICE:WaitForChild("Server")
local ServerServices = Server:WaitForChild("Services")


--------------------------------------------------------
-- Functions
local function Knit_Success()
	print("[KnitStart_Server]: Knit Started Successfully")
end

local function Knit_Failure(errorMessage)
	print("[KnitStart_Server]: Knit Start Failed. Details:", errorMessage)
end


--------------------------------------------------------
-- Knit Setup
local Knit = require(Shared:WaitForChild("Knit"))
Knit.Shared = Shared
Knit.Server = Server
Knit.SharedSystems =Shared:WaitForChild("Systems")
Knit.SharedModules = Shared:WaitForChild("Modules")
Knit.Modules = Server:WaitForChild("Modules")
Knit.Assets = Shared:WaitForChild("Assets")

Knit.AddServices(ServerServices)


--------------------------------------------------------
Knit:Start()
	:Then(Knit_Success)
	:Catch(Knit_Failure)

-- UnsuspectingSawblade 2021-08-03 11:47:39 Cmdr set-up
local Cmdr = require(Knit.Server.Cmdr.Cmdr)
Cmdr:RegisterTypesIn(Knit.Server.Cmdr.Types)
Cmdr:RegisterCommandsIn(Knit.Server.Cmdr.Commands)

-- TODO: I don't know, haven't gotten that far