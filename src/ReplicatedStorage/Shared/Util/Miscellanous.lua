function ClearSpaces(str): string
	return str:gsub(" ", "")
end

function GetModelData(Model)
	local Str = Model.Name
	local StrTbl = string.split(Str, " Level")

	return {
		Name = StrTbl[1];
		Level = ClearSpaces(StrTbl[2])
	}
end

function makeEnum(enumName, members)
	local enum = {}

	for _, memberName in ipairs(members) do
		enum[memberName] = memberName
	end

	return setmetatable(enum, {
		__index = function(_, k)
			error(string.format("%s is not in %s!", k, enumName), 2)
		end,
		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", enumName), 2)
		end,
	})
end

local Assets do
	local knit = require(game:GetService("ReplicatedStorage").Shared.Knit)
	Assets = knit.Shared.Assets
end

function CreateAssetCopy(assetName): Model
	local modelRef = Assets:FindFirstChild(assetName)
	local visualClone = nil;

	assert(modelRef, string.format("Tried to copy an invalid asset name: %q", tostring(assetName)))

	visualClone = modelRef:Clone()
	visualClone.Parent = workspace

	return visualClone
end

return {
	GetModelData = GetModelData;
	ClearSpaces = ClearSpaces;
	MakeEnum = makeEnum;
	CreateAssetCopy = CreateAssetCopy
}