local Results = {}
Results.array = {}

for i, v in pairs(script:GetChildren()) do
	local module = require(v)
	Results["Level_" .. v.Name] = module
	table.insert(Results, i, module)
	table.insert(Results.array, i, module)
end

return Results