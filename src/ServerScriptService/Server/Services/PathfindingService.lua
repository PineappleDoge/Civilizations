--[[
--------------------------------------------------------
-- S1RGames / PathfindingService
-- Manages pathfinding, finding the fastest route to X location
-------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
--------------------------- START OF DOCUMENTATION ---------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////

	PathfindingService:MoveToStructure(Player: Player, Troop: Model with humanoid descendant, Target: Model, TroopInfo: Dictionary)
		> Begins the entire moving process of the Troop.
		> returns if they movement was successful or not.
		
	PathfindingService:ControlSingleTroopMovement(Troop: Model with humanoid descendant, trueFalse: Boolean)
		> Controls a single troops movement. If trueFalse equals true, said Troop* will begin movement again.
		> Both varaibles are REQUIRED in order to operate the function.
		
	PathfindingService:ControlAllTroopMovement(Player: Player, trueFalse: Boolean)
		> Controls ALL Troops controlled by X player. If trueFalse equals true, said Troop* will begin movement again.
		> Both varaibles are REQUIRED in order to operate the function.
		
	PRIVATE FUNCTIONS
	-----------------

	ReturnPointOnFace(Troop: Model with humanoid descendant, Target: Model)
	> Returns the closest 
	
	CreatePath(Troop: Model with humanoid descendant, Target: Model, TroopInfo: Dictionary)
	> Creates the path for pathfinding. Doesn't find the route* but rather the information of the route, such as minimum radius, if they can Jump.
		
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////
---------------------------- END OF DOCUMENTATION ----------------------------
--\\\\\\\\\\\\\\\\\\\\\\                              ////////////////////////

]]

-------------------------------------------------------------------------
-- Services
local REPLICATED_SERVICE = game.ReplicatedStorage
local PATHFINDING_SERVICE = game:GetService("PathfindingService")
local RUN_SERVICE = game:GetService("RunService")
local PLAYERS = game.Players

-- Other variables
local CanJump = false -- // Disable pathfinding jumping
local MovingPlayerTroops = {} -- // Storing all the active / moving troops in here. Means we can stop all / move all, etc.
local TroopStartTimes = {} -- // If it doesn't reach X location in X amount of seconds, reroute it. It clearly is stuck.

-------------------------------------------------------------------------
-- Knit
local Knit = require(REPLICATED_SERVICE.Shared:WaitForChild("Knit"))
local PathfindingService = Knit.CreateService{
	Name = "PathfindingService", Client = {}
}

-------------------------------------------------------------------------
-- Private Functions

function CreatePath(Troop, Target, TroopInfo) -- // Object = Character/Enemy. MUST have a HRP.
	local ObjectSize = Troop:GetModelSize()
	local Radius = ObjectSize.Z
	if ObjectSize.X >= ObjectSize.Z then Radius = ObjectSize.X end --// Detects which lenght is bigger, so we can get the accurate radius.

	local PathFindingInfo = {Radius + 1 , ObjectSize.Y + .5 , TroopInfo.TroopCanJump, 1} -- // Radius, Minimum Height, Juping, DistanceBetweenPoints
	local Path = PATHFINDING_SERVICE:CreatePath(PathFindingInfo)

	return Path
end

function ControlMovingTroopsTable(Player, Troop, Remove)
	-- // Just a quick check to make sure they s a table called player.
	if MovingPlayerTroops[Player.Name] == nil then MovingPlayerTroops[Player.Name] = {} end

	for _Name,nextTable in pairs(MovingPlayerTroops) do	
		-- // Adding / removing from the table depending on the "Remove" variable
		if _Name == Player.Name then
			if Remove then
				for CurrentIndex, TroopObject in pairs(nextTable) do
					if TroopObject == Troop then
						table.remove(nextTable, nextTable[CurrentIndex])
					end
				end
			else
				for CurrentIndex, TroopObject in pairs(nextTable) do
					if TroopObject ~= Troop then -- // As we'll be doing this on each position, no need to add the troop multiple times.
						table.insert(nextTable, #nextTable+1,  Troop)
					end
				end
			end
		end
	end
end

function ReturnPointOnFace(Troop, Target)

	-- // TroopInfo, allows  us to compare with Target info.
	local TroopInfo = Troop.HumanoidRootPart:GetPivot()
	local TroopLookVector = TroopInfo.LookVector
	local TroopPosition = Vector3.new(TroopInfo.X, TroopInfo.Y, TroopInfo.Z)

	-- // TargetInfo
	local TargetCFrame = Target:GetPivot()
	local TargetLookVector = TargetCFrame.LookVector
	local TargetPosition = Vector3.new(TargetCFrame.X, TargetCFrame.Y, TargetCFrame.Z)
	local TargetSize = Target:GetExtentsSize()

	-- // Offset info, so rotation on model doesn't matter.
	local DefaultLookVector = {-0, -0, -1}
	local Offset = Vector3.new(DefaultLookVector[1]-TargetLookVector[1], DefaultLookVector[2]-TargetLookVector[2], DefaultLookVector[3]-TargetLookVector[3])

	local FaceAXIS = {
		Front = {CFrame.new(-TargetSize.X/2, -TargetSize.Y/2, -TargetSize.Z/2), CFrame.new(TargetSize.X/2, -TargetSize.Y/2, -TargetSize.Z/2)},
		Back = {CFrame.new(-TargetSize.X/2, -TargetSize.Y/2, TargetSize.Z/2) ,CFrame.new(TargetSize.X/2, -TargetSize.Y/2, TargetSize.Z/2)},
		Left = {CFrame.new(-TargetSize.X/2, -TargetSize.Y/2, -TargetSize.Z/2), CFrame.new(-TargetSize.X/2, -TargetSize.Y/2, TargetSize.Z/2)},
		Right = {CFrame.new(TargetSize.X/2, -TargetSize.Y/2, TargetSize.Z/2), CFrame.new(TargetSize.X/2, -TargetSize.Y/2, -TargetSize.Z/2)},
	}

	print(FaceAXIS.Front[2])

	local function GetFace()

		local XYZ = {0, 0, 0}
		XYZ[1] = TroopLookVector.X-Offset[1]
		XYZ[2] = TroopLookVector.Y-Offset[2]
		XYZ[3] = TroopLookVector.Z-Offset[3]

		local Largest = {
			["Index"] = -1;
			["Amount"] = 0;
		}

		for Index, Value in pairs(XYZ) do
			if math.abs(Value) > math.abs(Largest.Amount) then
				Largest["Amount"] = Value
				Largest["Index"] = Index
			end 
		end

		-- Assign proper angle.
		if Largest.Index == 1 then
			if Largest.Amount > 0 then
				return "Left"
			else
				return "Right"
			end
		elseif Largest.Index == 2 then
			if Largest.Amount > 0 then
				return "Front"
			else
				return "Back"
			end
		end
		wait()

		return "Front"
	end

	local ClosestFace = GetFace()
	local SelectedFaceLeft, SelectedFaceRight = (TargetCFrame * FaceAXIS[ClosestFace[1]]), (TargetCFrame * FaceAXIS[ClosestFace[2]])
	local RandomPoint = Vector3.new(math.random(SelectedFaceLeft.X, SelectedFaceRight.X), 0, math.random(SelectedFaceLeft.Z, SelectedFaceRight.Z))
	return RandomPoint
end

-------------------------------------------------------------------------
-- PathfindingService Properties
PathfindingService.Prefix = "[PathfindingService]:"
PathfindingService.Connections = {}

-------------------------------------------------------------------------
-- PathfindingService Functions

function PathfindingService:MoveToStructure(Player, Troop, Target, TroopInfo) 
	local Path = CreatePath(Troop, Target, TroopInfo)
	local PathPosition = ReturnPointOnFace(Target)
	local TroopHumanoid = Troop.Humanoid
	local Points = {}
	local PointsPassed

	-- // Here we can check if the Troop or Target has been destroyed. Will add move to this in the future, currently no system set up to call a destroyed stucture.
	local function CheckActives()
		if Troop == nil then
			return false
		elseif Target == nil then
			return false
		else
			return true
		end
	end

	local function DetectRaycastJumps()
		if TroopInfo.TroopCanJump == true then
			local Point1 = Points[PointsPassed].Position
			local Point2 = Points[Point1+1].Position
			local CentrePosition = (Point1 + Point2)/2
			local Result = workspace:Raycast(CentrePosition, Vector3.new(0,-25,0)) -- // 25 studs is a good enough distance, right?
			if (Result and Point2.Y - Result.Position.Y >= TroopHumanoid.hipHeight) or (Point1.Y - Point2.Y >= TroopHumanoid.hipHeight) then
				TroopHumanoid.Jump = true
			end
		end
	end

	local function ProceedToTarget(destinationObject)
		if CheckActives() then
			Path:ComputeAsync(Troop.HumanoidRootPart.Position, PathPosition)
			PointsPassed = {}
			ControlMovingTroopsTable(Player, Troop)
			if Path.Status == Enum.PathStatus.Success then
				Points = Path:GetWaypoints()
				PointsPassed = 1
				if Points[PointsPassed].Action == Enum.PathWaypointAction.Jump and CanJump then
					TroopHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
				TroopHumanoid:MoveTo(Points[PointsPassed].Position)
				DetectRaycastJumps()
			else
				TroopHumanoid:MoveTo(Troop.HumanoidRootPart.Position)
				ControlMovingTroopsTable(Player, Troop, true)
			end
		end
	end

	local function TargetPathBlocked(BlockedPoint)
		if BlockedPoint > PointsPassed then
			ProceedToTarget(Target)
		end
	end

	local function PointReached(CurrentPoint)
		if CurrentPoint and PointsPassed < #Points and CheckActives() then
			PointsPassed += 1
			TroopHumanoid:MoveTo(Points[PointsPassed].Position)
		elseif not CheckActives() or CurrentPoint and PointsPassed >= #Points then
			ControlMovingTroopsTable(Player, Troop, true)
			if CheckActives() ~= false then
				return true, "Reached"
			else
				return false, "FailedToReach"
			end
		end
	end

	Path.Blocked:Connect(TargetPathBlocked)
	TroopHumanoid.MoveToFinished:Connect(PointReached)
end

function PathfindingService:ControlSingleTroopMovement(Troop, trueFalse)
	if typeof(trueFalse) ~= "boolean" then error("trueFalse isn't a boolean.") return false, "trueFalse isn't a boolean." end
	if Troop ~= nil then
		if Troop:FindFirstChild("HumanoidRootPart") ~= nil then
			Troop:FindFirstChild("HumanoidRootPart").Anchored = trueFalse
			return true
		else
			return false, "No HRP"
		end
	else
		return false, "Troop is nil."
	end
end

function PathfindingService:ControlAllTroopMovement(Player, trueFalse)
	if typeof(trueFalse) ~= "boolean" then error("trueFalse isn't a boolean.") return false, "trueFalse is nil / isn't a boolean" end	
	for _, PlayerNames in pairs(MovingPlayerTroops) do
		if PlayerNames == Player.Name then
			for _,Troops in pairs(MovingPlayerTroops[PlayerNames]) do
				if Troops:FindFirstChild("HumanoidRootPart") ~= nil then
					Troops:FindFirstChild("HumanoidRootPart").Anchored = trueFalse
				end
			end
		end
	end
	return true
end

-------------------------------------------------------------------------
-- PathfindingService Functions [Knit Start/Init]
function PathfindingService:KnitInit()

end

-------------------------------------------------------------------------
-- ServiceTemplate Functions [Client]
function PathfindingService.Client:DoSomething(Player)
	return self.Server:DoSomething(Player)
end


-------------------------------------------------------------------------
-- ServiceTemplate Runtime Code [Pre-Knit Start/Init]


-------------------------------------------------------------------------
return PathfindingService