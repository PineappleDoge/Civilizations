--[[
	UnsuspectingSawblade 2021-07-15 11:06:44

	CellsMixin.Include(self: table)
	CellsMixin.Init(self: table)

	CellsMixin:IsLocationOccupied(position: Vector2, size: Vector2): boolean
	CellsMixin:GetCell(position: Vector2): table|nil
	CellsMixin:SetObjectLocation(object: table, position: Vector2): Void
	CellsMixin:ClearObjectLocation(object: table): Void
]]

local CELL_SIZE do
	local Knit = require(game:GetService("ReplicatedStorage").Shared.Knit)
	CELL_SIZE = require(Knit.Shared.CONSTANTS).CELL_SIZE
end

local CellsMixin = {}

function CellsMixin.Include(self: table)
	for name, func in pairs(CellsMixin) do
		if name ~= "Include" and name ~= "Init" then
			self[name] = func
		end
	end

	return self
end

function CellsMixin.Init(self: table)

	self.Cells = {}
	self.ObjectPositions = {}

	return self
end

function CellsMixin:IsLocationOccupied(position: Vector2, size: Vector2)
	size = size or Vector2.new(1, 1)
	-- UnsuspectingSawblade 2021-07-13 12:28:39 Assume position is the top left of a structure
	for x = 1, size.X do
		for y = 1, size.Y do
			local occupiedCheckPos = Vector2.new(x, y) - Vector2.new(1, 1) + position

			-- UnsuspectingSawblade 2021-07-13 12:28:20 Cell is occupied, cannot place
			if self:GetCell(occupiedCheckPos) then
				return false
			end
		end
	end

	return true
end

function CellsMixin:GetCell(position: Vector2)
	return self.Cells[tostring(position)]
end

function CellsMixin:SetObjectLocation(object: table, position: Vector2)
	self.ObjectPositions[object] = position

	for x = 1, object.Size.X do
		for y = 1, object.Size.Y do
			local cellPos = Vector2.new(x, y) - Vector2.new(1, 1) + position
			self.Cells[tostring(cellPos)] = object
		end
	end
end

function CellsMixin:ClearObjectLocation(object: table)
	local position = self.ObjectPositions[object]

	for x = 1, object.Size.X do
		for y = 1, object.Size.Y do
			local cellPos = Vector2.new(x, y) - Vector2.new(1, 1) + position
			self.Cells[tostring(cellPos)] = nil
		end
	end

	self.ObjectPositions[object] = nil
end

function CellsMixin:CellPosToRealPos(position: Vector2)
	assert(self.Base, "CellsMixin requires a base to work with real pos.")
	
	local baseCf: CFrame = self.Base.CFrame
	local baseSize: Vector3 = self.Base.Size

	local realObjectPos: Vector3 = Vector3.new(
		position.X * CELL_SIZE,
		baseSize.Y / 2,
		position.Y * CELL_SIZE
	)
	local realWorldPos = baseCf:PointToWorldSpace(realObjectPos)

	return realWorldPos
end

function CellsMixin:RealPosToCellPos(position: Vector3)
	assert(self.Base, "CellsMixin requires a base to work with real pos.")
	local localHitPos = self.Base.CFrame:PointToObjectSpace(position)
	local canvasPos = Vector2.new(
		math.ceil(localHitPos.X / CELL_SIZE),
		math.ceil(localHitPos.Z / CELL_SIZE)
	)

	-- UnsuspectingSawblade 2021-08-02 14:24:43 TODO: Clamp the position to stay within the Canvas

	return canvasPos
end

function CellsMixin:GetObjectPosition(object: table)
	return self.ObjectPositions[object]
end

-- UnsuspectingSawblade 2021-08-02 14:42:10 Currently accounts for closest center
function CellsMixin:GetClosestObjects(position: Vector2, amountOfObjects: number, flags: table?)
	local objectDistances = {}

	for object, objectPosition: Vector2 in pairs(self.Objects) do
		objectDistances[object] = (position - objectPosition).Magnitude
	end

	-- UnsuspectingSawblade 2021-08-02 14:44:01 Likely unoptimized
	local closestObjects = {}
	for i = 1, amountOfObjects do
		local closestDistance = math.huge
		local closestObject = false
		for object, distance in pairs(objectDistances) do
			if distance < closestDistance then
				closestDistance = distance
				closestObject = object
			end
		end
		
		if closestObject then
			closestObjects[i] = closestObject
			objectDistances[closestObject] = nil
		else
			break
		end
	end

	return closestObjects
end

return CellsMixin