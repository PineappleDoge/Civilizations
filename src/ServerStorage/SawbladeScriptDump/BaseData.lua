--[[
	UnsuspectingSawblade 2021-07-13 12:10:42

	BaseData.new(): BaseData
	BaseData.fromSerialization(data: table): BaseData

	BaseData.Changed -> Signal
	BaseData.Janitor -> Janitor

	BaseData:PlaceStructure(structureData: StructureData, position: Vector2): boolean
	BaseData:MoveStructure(structureData: StructureData, position: Vector2): boolean
	BaseData:RemoveStructure(structureData: StructureData): void

	BaseData:Destroy(): void

	-- from CellsMixin
	BaseData:IsLocationOccupied(position: Vector2, size: Vector2): boolean
	BaseData:GetCell(position: Vector2): table|nil
	BaseData:SetObjectLocation(object: table, position: Vector2): Void
	BaseData:ClearObjectLocation(object: table): Void
]]
local CellsMixin, StructureData, Janitor, Signal do
	local Knit = require(game:GetService("ReplicatedStorage").Shared.Knit)
	CellsMixin = require(Knit.Shared.Modules.CellsMixin)
	StructureData = require(Knit.Shared.Modules.StructureData)
	Janitor = require(Knit.Shared.Modules.Janitor)
	Signal = require(Knit.Util.Signal)
end

local BaseData = {}
BaseData.__index = BaseData
CellsMixin.Include(BaseData)


function BaseData.new()
	local self = setmetatable(CellsMixin.Init({
		Structures = {},
		Janitor = Janitor.new(),
		Changed = Signal.new()
	}), BaseData)

	self.Janitor:Add(self.Changed)

	return self
end

function BaseData.fromSerialization(data: data)
	local self = BaseData.new()

	for _structureId, serializedData in pairs(data) do
		local position = Vector2.new(serializedData.Position.X, serializedData.Position.Y)
		local structureData = StructureData.fromSerialization(serializedData.Structure)
		self.Structures[structureData] = true
		self:SetObjectLocation(structureData, position)
	end

	return self
end

function BaseData:_Changed()
	self.Changed:Fire()
end

function BaseData:PlaceStructure(structureData: table, position: Vector2)
	if self:IsLocationOccupied(position, structureData.Size) then
		return false
	end
	-- UnsuspectingSawblade 2021-07-13 12:29:11 Occupation check is complete, place structure down
	self.Structures[structureData] = true
	self:SetObjectLocation(structureData, position)

	self:_Changed()
end

function BaseData:MoveStructure(structureData: table, position: Vector2)
	if self:IsLocationOccupied(position, structureData.Size) then
		return false
	end
	-- UnsuspectingSawblade 2021-07-13 12:29:11 Occupation check is complete, place structure down
	self:ClearObjectLocation(structureData)
	self:SetObjectLocation(structureData, position)

	self:_Changed()
end

function BaseData:RemoveStructure(structureData: data)
	self:ClearObjectLocation(structureData)
	self.Structures[structureData] = nil

	self:_Changed()
end

function BaseData:Serialize()
	local serializedData = {}
	for structureData, _ in pairs(self.Structures) do
		local position = self:GetObjectPosition(structureData)
		serializedData[structureData.Id] = {
			Position = {X = position.X, Y = position.Y},
			Structure = structureData:Serialize()
		}
	end
	return serializedData
end

function BaseData:Destroy()
	self.Janitor:Destroy()
end


return BaseData