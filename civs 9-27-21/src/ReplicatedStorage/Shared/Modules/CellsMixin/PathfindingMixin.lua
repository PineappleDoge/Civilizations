--[[
	UnsuspectingSawblade 2021-07-17 16:34:28
	Seperate module for organization reasons

	PathfindingMixin:PathTo(startPos: Vector2, goalPos: Vector2, avoidObstacles: boolean): false or {Travel: function, Distance: number}
]]

local PathfindingService = game:GetService("PathfindingService")

local PathfindingMixin = {}

local AGENT_PARAMETERS = {
	AgentRadius = 1,
	AgentHeight = 1,
	-- UnsuspectingSawblade 2021-07-27 15:17:25 Pathing gets wacky if this isn't true
	AgentCanJump = true
}
local Path: Path = PathfindingService:CreatePath(AGENT_PARAMETERS)

local AVOID_OBSTACLES_SANDBOX_POSITION = Vector3.new(750, 0, 750)

local avoidObstaclesBaseplate = Instance.new("Part")
avoidObstaclesBaseplate.Name = "AvoidObstaclesBaseplate"
avoidObstaclesBaseplate.Locked = true
avoidObstaclesBaseplate.Anchored = true
avoidObstaclesBaseplate.CanCollide = true
avoidObstaclesBaseplate.Size = Vector3.new(512, 64, 512)
avoidObstaclesBaseplate.Position = AVOID_OBSTACLES_SANDBOX_POSITION
avoidObstaclesBaseplate.Parent = workspace

local function MakeTraversableWaypoints(waypoints)
	local totalDistance: Number = 0
	local lastWaypoint: PathWaypoint
	local dominantWaypoints = {}

	for _, waypoint: PathWaypoint in ipairs(waypoints) do
		if lastWaypoint then
			totalDistance += (lastWaypoint.Position - waypoint.Position).Magnitude
		end

		dominantWaypoints[#dominantWaypoints+1] = {
			Position = waypoint.Position,
			Distance = totalDistance
		}

		lastWaypoint = waypoint
	end

	local function travel(distance: number)
		assert(distance > 0, "Waypoint travel path distance must be above 0.")
		-- UnsuspectingSawblade 2021-08-02 13:57:16 Skips checking if it's going to be the position of the last waypoint
		if distance >= totalDistance then
			return lastWaypoint.Position
		end

		local firstDominantWaypointData: PathWaypoint
		local secondDominantWaypointData: PathWaypoint?
		for _, dominantWaypointData: table in ipairs(dominantWaypoints) do
			if dominantWaypointData.Distance <= distance then
				if firstDominantWaypointData then
					secondDominantWaypointData = dominantWaypointData
				else
					firstDominantWaypointData = dominantWaypointData
				end
			end
			if secondDominantWaypointData then
				break
			end
		end

		local interpolation = distance - firstDominantWaypointData.Distance
		local interpolationDistance = secondDominantWaypointData.Distance - firstDominantWaypointData.Distance
		
		return firstDominantWaypointData.Position:Lerp(
			secondDominantWaypointData.Position,
			interpolation / interpolationDistance
		)
	end

	return travel, totalDistance
end

function PathfindingMixin.Include(self: table)
	for name, func in pairs(PathfindingMixin) do
		if name ~= "Include" and name ~= "Init" then
			self[name] = func
		end
	end

	return self
end

function PathfindingMixin:PathTo(startPos: Vector2, goalPos: Vector2, avoidObstacles: boolean)
	local realPosStart = self:CellPostoRealPos(startPos)
	local realPosGoal = self:CellPostoRealPos(goalPos)

	if avoidObstacles then
		realPosStart = (realPosStart - self.Base.Position) + AVOID_OBSTACLES_SANDBOX_POSITION
		realPosGoal = (realPosGoal - self.Base.Position) + AVOID_OBSTACLES_SANDBOX_POSITION
	end

	Path:ComputeAsync(realPosStart, realPosGoal)

	if Path.Status == Enum.PathStatus.NoPath then
		return false
	else
		local waypoints = Path:GetWaypoints()

		if avoidObstacles then
			for _, waypoint: PathWaypoint in pairs(waypoints) do
				waypoint.Position = (waypoint.Position - AVOID_OBSTACLES_SANDBOX_POSITION) + self.Base.Position
			end
		end

		local travelFunc, distance = MakeTraversableWaypoints(waypoints)
		return {
			Travel = travelFunc,
			Distance = distance,
		}
	end
end

return PathfindingMixin