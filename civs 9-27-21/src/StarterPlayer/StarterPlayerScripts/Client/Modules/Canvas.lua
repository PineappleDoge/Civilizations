local UserInputService = game:GetService("UserInputService")
local Knit = require(game:GetService("ReplicatedStorage").Shared.Knit)

local GetHitCanvasPosition, CellsMixin, CELL_SIZE do
	GetHitCanvasPosition = require(Knit.Modules.GetHitCanvasPosition)
	CellsMixin = require(Knit.Shared.Modules.CellsMixin)
	local CONSTANTS = require(Knit.Shared.CONSTANTS)
	CELL_SIZE = CONSTANTS.CELL_SIZE
end

local Canvas = {}
Canvas.__index = Canvas
CellsMixin.Include(Canvas)

function Canvas.new(basePart)
	local self = setmetatable(CellsMixin.Init({
		Base = basePart
	}), Canvas)

	return self
end

function Canvas:GetHitPosition(size)
	-- UnsuspectingSawblade 2021-07-15 15:51:32 TODO: Get a better way to get the mouse position. Maybe use some sort of controller for dragging them?
	-- PineappleDoge 7-16-21: What better way is there?
	-- PineappleDoge 7-16-21: Never mind, need a better way for mobile support
	Knit.Start():Await()
	local UserInputManager = Knit.Controllers['UserInputManager']
	local mouseScreenPos = UserInputService:GetMouseLocation()
	
	if UserInputService.MouseEnabled == false and UserInputService.TouchEnabled == true then 
		mouseScreenPos = Vector2.new(UserInputManager.Touch.TouchPos.X, UserInputManager.Touch.TouchPos.Y)
	end
	
	return GetHitCanvasPosition(self.Base, mouseScreenPos, size)
end

function Canvas:CellPositionToWorldPosition(pos: Vector2, placingPart: BasePart?)
	local offset = (placingPart and (placingPart.Size * Vector3.new(0.5, -0.5, 0.5)) or Vector3.new(0, 0, 0))
	- (CELL_SIZE * Vector3.new(1, 0, 1))

	local base: BasePart = self.Base
	local baseOriginCf: CFrame = base.CFrame:ToWorldSpace(CFrame.new(base.Size  * Vector3.new(-0.5, 1, -0.5))) -- (-0.5, 1, -0.5)
	local expandedPos: Vector3 = Vector3.new(pos.X, 0, pos.Y) * CELL_SIZE

	return baseOriginCf:PointToWorldSpace(expandedPos + offset) -- expandedPos + offset
end

function Canvas:AddStructure(structureModel: Model, position: Vector2)
	
end

function Canvas:Destroy()
	
end


return Canvas