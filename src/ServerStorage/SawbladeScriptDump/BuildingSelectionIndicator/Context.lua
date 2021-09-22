local Context = {
	PlacingValid = 1,
	PlacingInvalid = 2,
	Selected = 3
}

local ContextColors = {
	[Context.PlacingValid] = Color3.new(0, 1, 1),
	[Context.PlacingInvalid] = Color3.new(1, 0, 0),
	[Context.Selected] = Color3.new(0, 1, 0)
}

Context.Colors = ContextColors

return Context