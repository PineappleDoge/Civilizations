local CONSTANTS = {
	CELL_SIZE = 4
}

local STUDIO_CONSTANTS = {
	UNIT_DEBUG_MODE = true
}

if game:GetService("RunService"):IsStudio() then
	for constantName, value in pairs(STUDIO_CONSTANTS) do
		CONSTANTS[constantName] = value
	end
end

return CONSTANTS
