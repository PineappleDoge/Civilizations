local Assets do
	local knit = require(game:GetService("ReplicatedStorage").Shared.Knit)
	Assets = knit.Shared.Assets
end

local function CreateAssetCopy(assetName)
	local modelRef = Assets:FindFirstChild(assetName)
	local visualClone = nil;
	
	assert(modelRef, string.format("Tried to copy an invalid asset name: %q", tostring(assetName)))
	
	visualClone = modelRef:Clone()
	visualClone.Parent = workspace
	
	return visualClone
end

return CreateAssetCopy

