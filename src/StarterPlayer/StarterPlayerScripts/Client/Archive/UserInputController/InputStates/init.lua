local InputStates = {}
InputStates.GetInputStates = function()
	for _, module in ipairs(script:GetChildren()) do
		local child = require(module)
		local name = module.Name
		InputStates[name] = child
	end
end

InputStates.GetInputStates()

return InputStates