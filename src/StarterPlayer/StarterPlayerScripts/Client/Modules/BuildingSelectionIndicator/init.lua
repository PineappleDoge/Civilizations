--[[
	UnsuspectingSawblade 2021-07-15 10:01:47

	BuildingSelectionIndicator.Context -> SelectionContexts

	BuildingSelectionIndicator.new() -> BuildingSelectionIndicator
	BuildingSelectionIndicator:Select(model: Model, context: SelectionContext) -> void
	BuildingSelectionIndicator:Destroy() -> void
]]

local RunService = game:GetService("RunService")

local Knit = require(game:GetService("ReplicatedStorage").Shared.Knit)
local Janitor = require(Knit.Util.Janitor)

-- UnsuspectingSawblade 2021-07-14 18:18:26 By parenting attachments to terrain, we don't have to deal with issues related to switching an attachment's parent 
local Terrain = workspace.Terrain

local SelectionContext = require(script.Context)

local SELECTION_VISUAL_HEIGHT = 10

local BuildingSelectionIndicator = {}
BuildingSelectionIndicator.__index = BuildingSelectionIndicator

BuildingSelectionIndicator.Context = SelectionContext


function BuildingSelectionIndicator.new()
	local self = setmetatable({
		Janitor = Janitor.new(),
		BaseJanitor = Janitor.new(),
		Attachments = {
			Base = {},
			Top = {}
		},
		Beams = {},
		BeamColor = Color3.new()
	}, BuildingSelectionIndicator)

	self.Janitor:Add(self.BaseJanitor)

	for i = 1, 4 do
		local attachmentBase: Attachment = Instance.new("Attachment")
		self.Janitor:Add(attachmentBase)
		attachmentBase.Name = string.format("SelectorBaseAttachment%s", i)
		attachmentBase.Parent = Terrain

		local attachmentTop: Attachment = Instance.new("Attachment")
		self.Janitor:Add(attachmentTop)
		attachmentTop.Name = string.format("SelectorTopAttachment%s", i)
		attachmentTop.Parent = Terrain

		local beam: Beam = Instance.new("Beam")
		self.Janitor:Add(beam)
		beam.Name = string.format("SelectorBeam%s", i)
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})

		beam.Attachment0 = attachmentBase
		beam.Attachment1 = attachmentTop
		beam.Parent = Terrain

		self.Attachments.Base[i] = attachmentBase
		self.Attachments.Top[i] = attachmentTop
		self.Beams[i] = beam
	end

	local colorShift = 0
	self.Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		colorShift += dt * 9
		local h, s, v = self.BeamColor:ToHSV()
		local selectionColor = Color3.fromHSV(h, math.clamp(s - (0.25 * math.sin(colorShift) + 0.5), 0, 1), v)
		for i = 1, 4 do
			self.Beams[i].Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, selectionColor),
				ColorSequenceKeypoint.new(1, selectionColor)
			})
		end
	end))

	return self
end

function BuildingSelectionIndicator:_SetBase(buildingBasePart: BasePart)
	self.BaseJanitor:Cleanup()

	local directions = {
		Vector3.new(1, -1, 0),
		Vector3.new(-1, -1, 0),
		Vector3.new(0, -1, 1),
		Vector3.new(0, -1, -1),
	}

	local function updateAttachments()
		local halfBaseSize = buildingBasePart.Size / 2
		local baseCFrame = buildingBasePart.CFrame

		for i = 1, 4 do
			local direction = directions[i]

			local angle = CFrame.Angles(0, i <= 2 and math.rad(90) or 0, math.rad(90))

			self.Attachments.Base[i].WorldCFrame = baseCFrame:ToWorldSpace(CFrame.new(halfBaseSize * direction)) * angle
			self.Attachments.Top[i].WorldCFrame = 
				baseCFrame:ToWorldSpace(CFrame.new(halfBaseSize * direction + Vector3.new(0, SELECTION_VISUAL_HEIGHT, 0)))
				* angle

			-- UnsuspectingSawblade 2021-07-14 18:23:20 TODO: Beam widths
			local beam: Beam = self.Beams[i]
			local width = i <= 2 and halfBaseSize.X * 2 or halfBaseSize.Z * 2
			beam.Width0 = width
			beam.Width1 = width
		end
	end

	updateAttachments()
	self.BaseJanitor:Add(buildingBasePart.Changed:Connect(updateAttachments))

end

function BuildingSelectionIndicator:Select(model: Model, context: number)
	local contextColor = SelectionContext.Colors[context] or SelectionContext.Colors[1]
	self.BeamColor = contextColor
	self:_SetBase(model:FindFirstChild("BuildingBase"))
end

function BuildingSelectionIndicator:Destroy()
	self.Janitor:Destroy()
end


return BuildingSelectionIndicator