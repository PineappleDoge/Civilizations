--[[
	UnsuspectingSawblade 2021-07-15 16:23:38
	Gets a position in the canvas from a given position on the screen and a given cell size.

	"targetCellSize" should be used for structure sizes while placing

	This functions creates smooth determination of what cell to place the structure at by providing logic if being dragged off the grid
		while snapping
]]

local CELL_SIZE do
	local Knit = require(game:GetService("ReplicatedStorage").Shared.Knit)
	CELL_SIZE = require(Knit.Shared.CONSTANTS).CELL_SIZE
end

local function RayToPlaneIntersection(rayVector, rayPoint, planeNormal, planePoint)
	local diff = rayPoint - planePoint
	local prod1 = diff:Dot(planeNormal)
	local prod2 = rayVector:Dot(planeNormal)
	local prod3 = prod1/prod2
	return rayPoint - (rayVector*prod3)
end

local function GetCanvasSize(part: BasePart)
	return Vector2.new(
		math.floor(part.Size.X / CELL_SIZE),
		math.floor(part.Size.Z / CELL_SIZE)
	)
end

-- UnsuspectingSawblade 2021-07-15 16:11:19 Took some math from this: https://devforum.roblox.com/t/creating-a-furniture-placement-system/205509
local function GetHitCanvasPosition(canvasPart: BasePart, screenPosition: Vector2, targetCellSize: Vector2)
	targetCellSize = targetCellSize or Vector2.new(1, 1)
	local canvasSize: Vector2 = GetCanvasSize(canvasPart)
	local canvasOriginCf = canvasPart.CFrame:ToWorldSpace(CFrame.new(-canvasPart.Size / 2))

	local unitRay: ray = workspace.CurrentCamera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = {canvasPart}
	
	local results = workspace:Raycast(unitRay.Origin, unitRay.Direction * 500, raycastParams)
	local hitPosition = results and results.Position or RayToPlaneIntersection(
		unitRay.Direction,
		unitRay.Origin,
		Vector3.new(0, 1, 0),
		canvasOriginCf.Position
	)

	local clampSize = (canvasSize - Vector2.new(targetCellSize.X, targetCellSize.Y) / 2)

	local localHitPos = canvasOriginCf:PointToObjectSpace(hitPosition)
	local unclampedCanvasPos = Vector2.new(
		math.ceil(localHitPos.X / CELL_SIZE),
		math.ceil(localHitPos.Z / CELL_SIZE)
	)

	return Vector2.new(
		math.round(math.clamp(unclampedCanvasPos.X, 1, clampSize.X)),
		math.round(math.clamp(unclampedCanvasPos.Y, 1, clampSize.Y))
	)
end

return GetHitCanvasPosition