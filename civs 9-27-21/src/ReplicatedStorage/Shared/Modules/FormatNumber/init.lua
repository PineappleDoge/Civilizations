--[=[
	--- API
	It's broadly based around a subset of ICU's NumberFormatter with many features removed. There are differences (like you're able to define your own suffixes/abbreviations `Notation.compactWithSuffixThousands({ "K", "M", "B", "T", ... })` in this module) but the majority are similar.

	---- NumberFormatter
	The class to format the numbers, located in `FormatNumber.NumberFormatter`.

	----- Methods
	`string` NumberFormatter:Format(number value)
	The number to format, it could be any Luau number. It accounts for negative numbers, infinities, and NaNs. It returns `string` instead of `FormattedNumber` to simplify the implemention of module.

	------ Settings methods
	These are methods that returns NumberFormatter with the specific settings changed. Calling the methods doesn't change the NumberFormatter object itself so you have to use the new variable.

	`NumberFormatter` NumberFormatter:Notation(FormatNumber.Notation notation)
	See Notation.
	`NumberFormatter` NumberFormatter:Precision(FormatNumber.Precision precision)
	See Precision.
	`NumberFormatter` NumberFormatter:RoundingMode(FormatNumber.RoundingMode roundingMode)
	See FormatNumber.RoundingMode enum.
	`NumberFormatter` NumberFormatter:Grouping(FormatNumber.GroupingStrategy strategy)
	See FormatNumber.GroupingStrategy enum.
	`NumberFormatter` NumberFormatter:IntegerWidth(FormatNumber.IntegerWidth strategy)
	See IntegerWidth.
	`NumberFormatter` NumberFormatter:Sign(FormatNumber.SignDisplay style)
	See FormatNumber.SignDisplay enum.

	---- Notation
	These specify how the number is rendered, located in `FormatNumber.Notation`.

	----- Static methods
	`ScientificNotation` Notation.scientific()
	`ScientificNotation` Notation.engineering()
	Scientific notation and the engineering version of it respectively. Uses `E` as the exponent separator but I might add an option to change it in the future.

	`Notation` Notation.compactWithSuffixThousands(array\<string\> suffixTable)
	Basically abbreviations with suffix appended, scaling by every thousands as the suffix changes.

	`Notation` Notation.simple()
	The standard formatting without any scaling. The default.

	----- ScientificNotation (methods)
	`ScientificNotation` ScientificNotation:WithMinExponentDigits(number minExponetDigits)
	The minimum, padding with zeroes if necessary.

	`ScientificNotation` ScientificNotation:WithExponentSignDisplay(FormatNumber.SignDisplay exponentSignDisplay)
	See FormatNumber.SignDisplay enum.

	---- Precision
	These are precision settings and changes to what places/figures the number rounds to, located in `FormatNumber.Precision`. The default is `Precision.integer():WithMinDigits(2)` for abbreviations and `Precision.maxFraction(6)` otherwise.
	Note that for Lua numbers, it rounds the number to certain significant digits depending on the number regardless of what precision you set on the API, compared to `%f` specifier in `string.format`. If you're curious, you can view the source code but it'll be undocumented and it requires knowledge of the IEEE 754 floating point format.

	----- Static methods
	`FractionPrecision` Precision.integer()
	Rounds the number to the nearest integer

	`FractionPrecision` Precision.minFraction(number minFractionDigits)
	`FractionPrecision` Precision.maxFraction(number maxFractionDigits)
	`FractionPrecision` Precision.minMaxFraction(number minFractionDigits, number maxFractionDigits)
	`FractionPrecision` Precision.fixedFraction(number minMaxFractionDigits)
	Rounds the number to a certain fractional digits (or decimal places), min is the minimum fractional (decimal) digits to show, max is the fractional digits (decimal places) to round, fixed refers to both min and max.

	`Precision` Precision.minSignificantDigits(number minSignificantDigits)
	`Precision` Precision.maxSignificantDigits(number maxSignificantDigits)
	`Precision` Precision.minMaxSignificantDigits(number minSignificantDigits, number maxSignificantDigits)
	`Precision` Precision.fixedFraction(number minMaxSignificantDigits)
	Round the number to a certain significant digits; min, max, and fixed are specified above

	`Precision` Precision.unlimited()
	Show all available digits to the full precision.

	----- FractionPrecision (methods)
	These are subclass of `Precision` with more options for the fractional (decimal) digits
	`Precision` FractionPrecision:WithMinDigits(number minSignificantDigits)
	Round to the decimal places specified  by the FractionPrecision object but keep at least the amount of significant digit specified by the argument.

	`Precision` FractionPrecision:WithMaxDigits(number maxSignificantDigits)
	Round to the decimal places specified  by the FractionPrecision object but don't keep any more the amount of significant digit specified by the argument.

	---- IntegerWidth

	----- Static methods
	`IntegerWidth` IntegerWidth.zeroFillTo(number minInt)
	Zero fill numbers at the integer part of the number to guarantee at least certain digit in the integer part of the number.

	----- Methods
	`IntegerWidth` IntegerWidth:TruncateAt(number maxInt)
	Truncates the integer part of the number to certain digits

	---- Enums
	The associated numbers in all these enums are an implementation detail, please do not rely on them so instead of using `0`, use `FormatNumber.SignDisplay.AUTO`.

	----- FormatNumber.GroupingStrategy
	This determines how grouping separator (comma) is inserted - integer part only. There are three options.
	- OFF - no grouping
	- MIN2 - grouping only on 5 digits or above (default for compact notation)
	- ON_ALIGNED - always group the value (default unless it's compact notation)

	MIN2 is the default for abbreviations/compact notation because it just is and is a convention. It's been this way, in all versions of International (though hidden internally before 2.1), starting at ICU 59, and starting at version 2 of the module.

	----- FormatNumber.SignDisplay
	This determines how you display the plus sign (`+`) and the minus sign (`-`):
	- AUTO - Displays the minus sign only if the value is negative (that includes -0 and -NaN) (default)
	- ALWAYS - Displays the plus/minus sign on all values
	- NEVER - Don't display the plus/minus sign
	- EXCEPT_ZERO - Display the plus/minus sign on all values except zero and NaN
	- NEGATIVE - Display the minus sign only if the value is negative but do not display the minus sign on -0 and -NaN

	This doesn't support accounting sign display yet but I might consider it later.

	----- FormatNumber.RoundingMode
	This determines the rounding mode. We currently only have three mode but I might add more if there are uses for others.
	- HALF_EVEN - Round it to the nearest even if it's in the midpoint, round it up if it's above the midpoint and down otherwise (default unless it's compact or scientific/engineering notation)
	- HALF_UP - Round it up if it's in the midpoint or above, down otherwise (most familiar)
	- DOWN - Truncate the values (default for compact and scientific/engineering notation)

	DOWN is the default for compact and scientific/engineering notation because this is actually needed as it'd feel wrong to format 1999 as `2K` instead of `1.9K`.
]=]--

--[=[
	--- LICENSE
	FormatNumber and double conversion Luau port
	BSD 2-Clause Licence
	Copyright 2021 - Blockzez (devforum.roblox.com/u/Blockzez and github.com/Blockzez)
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice, this
	   list of conditions and the following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright notice,
	   this list of conditions and the following disclaimer in the documentation
	   and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	---
	Google's double conversion (ported to Luau by @Blockzez)

	Copyright 2006-2011, the V8 project authors. All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are
	met:

	* Redistributions of source code must retain the above copyright
	notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above
	  copyright notice, this list of conditions and the following
	  disclaimer in the documentation and/or other materials provided
	  with the distribution.
	* Neither the name of Google Inc. nor the names of its
	  contributors may be used to endorse or promote products derived
	  from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
	OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
	LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]=]
local FormatNumber = { }
local NumberFormatter_methods = { }

--
local proxy_data = setmetatable({ }, { __mode = "k" })
local double_to_decimal = require(script.double_to_decimal)
local function to_string_object(self)
	return proxy_data[self].__name
end

-- Notation
do
	local Notation_methods = { }
	local ScientificNotation_methods = { }
	
	function ScientificNotation_methods:WithExponentSignDisplay(disp)
		local proxy_value = proxy_data[self]
		if not proxy_value or proxy_value.__name ~= "ScientificNotation" then
			error("Argument #1 must be a ScientificNotation object", 2)
		end
		if type(disp) ~= "number"
			or disp % 1 ~= 0 or disp < 0 or disp > 4 then
			error("Invalid value for argument #2", 2)
		end
		local object = newproxy(true)
		local object_mt = getmetatable(object)
		proxy_data[object] = object_mt

		object_mt.__index = ScientificNotation_methods
		object_mt.__name = "ScientificNotation"
		object_mt.__tostring = to_string_object
		object_mt.data = {
			type = "scientific",
			minExponentDigits = proxy_value.data.minExponentDigits,
			exponentSignDisplay = disp,
			engineering = proxy_value.data.engineering,
		}

		return object
	end
	
	function ScientificNotation_methods:WithMinExponentDigits(min)
		local proxy_value = proxy_data[self]
		if not proxy_value or proxy_value.__name ~= "ScientificNotation" then
			error("Argument #1 must be a ScientificNotation object", 2)
		end
		if type(min) ~= "number" then
			error("Argument #2 must be a number", 2)
		elseif min < 1 or min > 999 or min % 1 ~= 0 then
			error("Argument #2 must be an integer in range from 1 to (and including) 999", 2)
		end
		local object = newproxy(true)
		local object_mt = getmetatable(object)
		proxy_data[object] = object_mt

		object_mt.__index = ScientificNotation_methods
		object_mt.__name = "ScientificNotation"
		object_mt.__tostring = to_string_object
		object_mt.data = {
			type = "scientific",
			minExponentDigits = min,
			exponentSignDisplay = proxy_value.data.exponentSignDisplay,
			engineering = proxy_value.data.engineering,
		}

		return object
	end

	FormatNumber.Notation = {
		scientific = function()
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = ScientificNotation_methods
			object_mt.__name = "ScientificNotation"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "scientific",
				minExponentDigits = 1,
				exponentSignDisplay = 0,
				engineering = false,
			}

			return object
		end,
		engineering = function()
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = ScientificNotation_methods
			object_mt.__name = "ScientificNotation"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "scientific",
				minExponentDigits = 1,
				exponentSignDisplay = 0,
				engineering = true,
			}

			return object
		end,
		compactWithSuffixThousands = function(suffix_array)
			if type(suffix_array) ~= "table" then
				error("Argument #1 must be a table", 2)
			end
			suffix_array = table.move(suffix_array, 1, #suffix_array, 1, table.create(#suffix_array))
			for i = 1, #suffix_array do
				if type(suffix_array[i]) ~= "string" then
					error(string.format("Invalid value (%s) at index %d in table", type(suffix_array[i]), i), 2)
				end
			end
			
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = Notation_methods
			object_mt.__name = "Notation"
			object_mt.__tostring = to_string_object

			object_mt.data = {
				type = "compact",
				value = suffix_array,
				length = #suffix_array,
			}

			return object
		end,
		simple = function()
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = Notation_methods
			object_mt.__name = "Notation"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type ="simple",
			}

			return object
		end,
	}
end

-- Precision
do
	local Precision_methods = { }
	local FractionPrecision_methods = { }
	
	function FractionPrecision_methods:WithMinDigits(min)
		local proxy_value = proxy_data[self]
		if not proxy_value or proxy_value.__name ~= "FractionPrecision" then
			error("Argument #1 must be a FractionPrecision object", 2)
		end
		if type(min) ~= "number" then
			error("Argument #2 must be a number", 2)
		elseif min < 0 or min > 999 or min % 1 ~= 0 then
			error("Argument #2 must be an integer in range from 0 to (and including) 999", 2)
		end
		local object = newproxy(true)
		local object_mt = getmetatable(object)
		proxy_data[object] = object_mt

		object_mt.__index = Precision_methods
		object_mt.__name = "Precision"
		object_mt.__tostring = to_string_object
		object_mt.data = {
			type = "fracSigt",
			minFractionDigits = proxy_value.data.min,
			maxFractionDigits = proxy_value.data.max,
			maxSignificantDigits = min,
			roundingPriority = "relaxed",
		}

		return object
	end
	
	function FractionPrecision_methods:WithMaxDigits(max)
		local proxy_value = proxy_data[self]
		if not proxy_value or proxy_value.__name ~= "FractionPrecision" then
			error("Argument #1 must be a FractionPrecision object", 2)
		end
		if type(max) ~= "number" then
			error("Argument #2 must be a number", 2)
		elseif max < 0 or max > 999 or max % 1 ~= 0 then
			error("Argument #2 must be an integer in range from 0 to (and including) 999", 2)
		end
		local object = newproxy(true)
		local object_mt = getmetatable(object)
		proxy_data[object] = object_mt

		object_mt.__index = Precision_methods
		object_mt.__name = "Precision"
		object_mt.__tostring = to_string_object
		object_mt.data = {
			type = "fracSigt",
			minFractionDigits = proxy_value.data.min,
			maxFractionDigits = proxy_value.data.max,
			maxSignificantDigits = max,
			roundingPriority = "strict",
		}

		return object
	end
	
	FormatNumber.Precision = {
		integer = function(min)
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = FractionPrecision_methods
			object_mt.__name = "FractionPrecision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "fraction",
				min = 0, max = 0,
			}

			return object
		end,
		minFraction = function(min)
			if type(min) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif min < 0 or min > 999 or min % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = FractionPrecision_methods
			object_mt.__name = "FractionPrecision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "fraction",
				min = min, max = 0,
			}

			return object
		end,
		maxFraction = function(max)
			if type(max) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif max < 0 or max > 999 or max % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = FractionPrecision_methods
			object_mt.__name = "FractionPrecision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "fraction",
				min = 0, max = max,
			}

			return object
		end,
		minMaxFraction = function(min, max)
			if type(min) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif min < 0 or min > 999 or min % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			elseif type(max) ~= "number" then
				error("Argument #2 must be a number", 2)
			elseif max < 0 or max > 999 or max % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			elseif max < min then
				error("Maximum argument must be greater or equal to the minimum argument", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = FractionPrecision_methods
			object_mt.__name = "FractionPrecision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "fraction",
				min = min, max = max,
			}

			return object
		end,
		fixedFraction = function(fixed)
			if type(fixed) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif fixed < 0 or fixed > 999 or fixed % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = FractionPrecision_methods
			object_mt.__name = "FractionPrecision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "fraction",
				min = fixed, max = fixed,
			}

			return object
		end,
		minSignificantDigits = function(min)
			if type(min) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif min < 0 or min > 999 or min % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = Precision_methods
			object_mt.__name = "Precision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "significant",
				min = min, max = 0,
			}

			return object
		end,
		maxSignificantDigits = function(max)
			if type(max) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif max < 0 or max > 999 or max % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = Precision_methods
			object_mt.__name = "Precision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "significant",
				min = 0, max = max,
			}

			return object
		end,
		minMaxSignificantDigits = function(min, max)
			if type(min) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif min < 0 or min > 999 or min % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			elseif type(max) ~= "number" then
				error("Argument #2 must be a number", 2)
			elseif max < 0 or max > 999 or max % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			elseif max < min then
				error("Maximum argument must be greater or equal to the minimum argument", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt
			
			object_mt.__index = Precision_methods
			object_mt.__name = "Precision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "significant",
				min = min, max = max,
			}

			return object
		end,
		fixedSignificantDigits = function(fixed)
			if type(fixed) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif fixed < 0 or fixed > 999 or fixed % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 0 to (and including) 999", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = Precision_methods
			object_mt.__name = "Precision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "significant",
				min = fixed, max = fixed,
			}

			return object
		end,
		unlimited = function()
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = Precision_methods
			object_mt.__name = "Precision"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				type = "unlimited",
			}

			return object
		end,
	}
end

-- Integer width
do
	local IntegerWidth_methods = { }
	
	function IntegerWidth_methods:TruncateAt(max)
		local proxy_value = proxy_data[self]
		if not proxy_value or proxy_value.__name ~= "IntegerWidth" then
			error("Argument #1 must be a IntegerWidth object", 2)
		end
		if max == -1 then
			max = nil
		elseif type(max) ~= "number" then
			error("Argument #2 must be a number", 2)
		elseif max < 1 or max > 999 or max % 1 ~= 0 then
			error("Argument #2 must be an integer in range from 1 to (and including) 999", 2)
		elseif max < proxy_value.data.zeroFillTo then
			error("Argument must be greater or equal to the zeroFillTo setting", 2)
		end
		local object = newproxy(true)
		local object_mt = getmetatable(object)
		proxy_data[object] = object_mt

		object_mt.__index = IntegerWidth_methods
		object_mt.__name = "IntegerWidth"
		object_mt.__tostring = to_string_object
		object_mt.data = {
			zeroFillTo = proxy_value.data.zeroFillTo,
			truncateAt = max,
		}

		return object
	end

	FormatNumber.IntegerWidth = {
		zeroFillTo = function(min)
			if type(min) ~= "number" then
				error("Argument #1 must be a number", 2)
			elseif min < 1 or min > 999 or min % 1 ~= 0 then
				error("Argument #1 must be an integer in range from 1 to (and including) 999", 2)
			end
			local object = newproxy(true)
			local object_mt = getmetatable(object)
			proxy_data[object] = object_mt

			object_mt.__index = IntegerWidth_methods
			object_mt.__name = "IntegerWidth"
			object_mt.__tostring = to_string_object
			object_mt.data = {
				zeroFillTo = min,
				truncateAt = nil,
			}

			return object
		end,
	}
end

-- Enums
FormatNumber.RoundingMode = {
	HALF_EVEN = 0,
	HALF_UP = 1,
	DOWN = 2,
}

FormatNumber.GroupingStrategy = {
	OFF = 0,
	MIN2 = 1,
	AUTO = 2,
}

FormatNumber.SignDisplay = {
	AUTO = 0,
	ALWAYS = 1,
	NEVER = 2,
	EXCEPT_ZERO = 3,
	NEGATIVE = 4,
}

-- Implementation
local function round_fmt(fmt, fmt_n, intg_i, prec, rounding_mode)
	if fmt_n == 0 then
		return 0, 0, false
	end
	if prec.type ~= "unlimited" then
		local ro_i, midpoint_cmp, is_even
		if prec.type == "fracSigt" then
			local frac_i = prec.maxFractionDigits
			local sigt_i = prec.maxSignificantDigits
			if not frac_i then
				ro_i = sigt_i
			elseif prec.roundingPriority == "strict" then
				ro_i = math.min(intg_i + frac_i, sigt_i)
			elseif prec.roundingPriority == "relaxed" then
				ro_i = math.max(intg_i + frac_i, sigt_i)
			end
		elseif not prec.max then
			return fmt_n, intg_i, false
		elseif prec.type == "fraction" then
			ro_i = intg_i + prec.max
		elseif prec.type == "significant" then
			ro_i = prec.max
		end

		if ro_i and ro_i < 1 then
			return 0, 0, false
		elseif ro_i and ro_i < fmt_n then
			fmt_n = ro_i
			midpoint_cmp = fmt[ro_i + 1] == 0 and -2
				or fmt[ro_i + 1] == 5 and (ro_i == fmt_n and 0 or 1)
				or fmt[ro_i + 1] > 5 and 1 or -1
			is_even = (fmt[ro_i] or 0) % 2 == 0
		else
			midpoint_cmp = -2
		end

		local incr
		if rounding_mode == 1 then
			incr = midpoint_cmp >= 0
		elseif rounding_mode == 0 then
			incr = midpoint_cmp > 0 or
				midpoint_cmp == 0 and not is_even
		end
		if incr then
			for ro_i1 = fmt_n, 0, -1 do
				if ro_i1 == 0 then
					fmt[1] = 1
					fmt_n = 1
					intg_i += 1
					return fmt_n, intg_i, true
				else
					local c = (fmt[ro_i1] or 0) + 1
					if c == 10 then
						fmt[ro_i1] = nil
						fmt_n -= 1
					else
						fmt[ro_i1] = c
						break
					end
				end
			end
		end
		
		-- trailing zero
		while fmt[fmt_n] == 0 do
			fmt_n -= 1
		end
	end

	return fmt_n, intg_i, false
end
local function format_numberformatter(self, is_negt, fmt, fmt_n, intg_i)
	local ret
	local resolved = self.resolved
	local disp_sign
	local is_zero
	
	-- compile formatter
	if not resolved then
		resolved = {
			notation = nil,
			precision = nil,
			roundingMode = nil,
			groupingStrategy = nil,
			integerWidth = nil,
			signDisplay = nil,
		}
		
		local ll = self.data
		while ll do
			if not resolved[ll.key] then
				resolved[ll.key] = ll.value
			end
			ll = ll.parent
		end
		
		-- defaults
		if not resolved.notation then
			resolved.notation = { type = "simple" }
		end
		if not resolved.precision then
			resolved.precision =
				resolved.notation.type == "compact" and {
					type = "fracSigt",
					minFractionDigits = 0,
					maxFractionDigits = 0,
					maxSignificantDigits = 2,
					roundingPriority = "relaxed",
				}
				or {
					type = "fraction",
					min = 0, max = 6,
				}
		end
		if not resolved.roundingMode then
			resolved.roundingMode = resolved.notation.type == "simple" and 0 or 2
		end
		if not resolved.groupingStrategy then
			-- compact notation use MIN2 by default
			resolved.groupingStrategy = resolved.notation.type == "compact" and 1 or 2
		end
		if not resolved.integerWidth then
			resolved.integerWidth = {
				zeroFillTo = 1,
				truncateAt = nil,
			}
		end
		if not resolved.signDisplay then
			resolved.signDisplay = 0
		end
		
		self.resolved = resolved
	end
	
	-- Infinity and NaN
	if fmt == "nan" then
		ret = "NaN"
		-- Internationally set to true
		is_zero = true
	elseif fmt == "inf" then
		ret = "∞"
		is_zero = false
	else
		local intg, frac, expt
		local expt_i = 0
		local rescale
		local prec = resolved.precision
		local notation = resolved.notation
		local intg_w, min_frac_w
		
		-- exponent
		if notation.type ~= "simple" and fmt_n ~= 0 then
			expt_i = intg_i - 1
			
			if notation.engineering then
				intg_i = expt_i % 3 + 1
				expt_i = math.floor(expt_i / 3) * 3
			elseif notation.type == "compact" then
				intg_i = expt_i % 3 + 1
				expt_i = math.floor(expt_i / 3)
				
				if expt_i > notation.length then
					intg_i += 3 * (expt_i - notation.length)
					expt_i = notation.length
				elseif expt_i < 0 then
					intg_i += 3 * expt_i
					expt_i = 0
				end
			else
				intg_i = 1
			end
		end
		
		fmt_n, intg_i, rescale = round_fmt(
			fmt, fmt_n, intg_i, prec, resolved.roundingMode)
		
		if rescale and (notation.type ~= "compact" or expt_i ~= notation.length) then
			expt_i += notation.engineering and 3 or 1
			intg_i = 1
		end
		
		if notation.type == "scientific" then
			local is_expt_negt = expt_i < 0
			if is_expt_negt then
				expt = string.format("%d", -expt_i)
			else
				expt = string.format("%d", expt_i)
			end
			
			expt = string.rep("0", notation.minExponentDigits - #expt) .. expt
			
			if (notation.exponentSignDisplay == 0
				or notation.exponentSignDisplay == 4) and is_expt_negt
				or notation.exponentSignDisplay == 2
				or notation.exponentSignDisplay == 3 and expt_i ~= 0
			then
				expt = (is_expt_negt and "-" or "+") .. expt
			end
			
			expt = "E" .. expt
		elseif notation.type == "compact" and expt_i ~= 0 then
			expt = notation.value[expt_i]
		else
			expt = ""
		end
		
		is_zero = fmt_n == 0
		
		for i = 1, fmt_n do
			fmt[i] += 0x30
		end
		
		-- integer
		if fmt then
			intg = string.char(table.unpack(fmt, nil, math.min(intg_i, fmt_n)))
				.. string.rep("0", intg_i - fmt_n)
		else
			intg = ""
		end
		
		if resolved.integerWidth.truncateAt then
			intg = string.gsub(string.sub(intg, -resolved.integerWidth.truncateAt), "^0+", "")
		end
		intg = string.rep("0", resolved.integerWidth.zeroFillTo - #intg) .. intg
		intg_w = #intg
		
		if resolved.groupingStrategy ~= 0
			and intg_w > 5 - resolved.groupingStrategy then
			intg = string.reverse((string.gsub(
				string.reverse(intg), "(...)", "%1,", (intg_w - 1) / 3)))
		end
		
		-- fraction
		if prec.type == "fraction" then
			min_frac_w = prec.min
		elseif prec.type == "fracSigt" then
			min_frac_w = prec.minFractionDigits
		elseif prec.type == "significant" then
			min_frac_w = math.max(prec.min - intg_w, 0)
		else
			min_frac_w = 0
		end
		
		if fmt_n ~= 0 then
			frac = string.rep("0", -intg_i)
				.. string.char(table.unpack(fmt, math.max(intg_i + 1, 1), fmt_n))
		else
			frac = ""
		end
		frac ..= string.rep("0", min_frac_w - #frac)

		if frac ~= "" then
			frac = "." .. frac
		end
		
		ret = intg .. frac .. expt
	end
	
	local raw_sign = resolved.signDisplay
	if raw_sign == 1 then
		disp_sign = true
	elseif raw_sign == 2 then
		disp_sign = false
	elseif raw_sign == 3 then
		-- despite 'except zero'
		-- it also includes numbers that round to zero
		-- and NaN
		disp_sign = not is_zero
	elseif raw_sign == 4 then
		-- do not display signed zero
		-- nor numbers that round to signed zero
		-- nor signed NaN
		disp_sign = is_negt and not is_zero
	else
		disp_sign = is_negt
	end
	
	if disp_sign then
		ret = (is_negt and "-" or "+") .. ret
	end
	
	return ret
end

-- The object
local function NumberFormatter_with_setting(setting, typ)
	local type_enum = type(typ) == "number"
	local is_instance_table
	
	if typ == "Notation" then
		is_instance_table = {
			["Notation"] = true,
			["ScientificNotation"] = true,
		}
	elseif typ == "Precision" then
		is_instance_table = {
			["Precision"] = true,
			["FractionPrecision"] = true,
		}
	elseif typ == "IntegerWidth" then
		is_instance_table = { ["IntegerWidth"] = true }
	end
	
	return function(self, value)
		local proxy_value = proxy_data[self]
		if not proxy_value or proxy_value.__name ~= "NumberFormatter" then
			error("Argument #1 must be a NumberFormatter object", 2)
		end
		if type_enum then
			if type(value) ~= "number"
				or value % 1 ~= 0 or value < 0 or value > typ then
				error("Invalid value for argument #2", 2)
			end
		else
			local proxy_setting = proxy_data[value]
			if not (proxy_setting and is_instance_table[proxy_setting.__name]) then
				error("Argument #2 must be a " .. typ .. " object", 2)
			end
			value = proxy_setting.data
		end
		local object = newproxy(true)
		local object_mt = getmetatable(object)
		proxy_data[object] = object_mt

		object_mt.__index = NumberFormatter_methods
		object_mt.__name = "NumberFormatter"
		object_mt.__tostring = to_string_object
		object_mt.resolved = nil
		object_mt.data = {
			key = setting,
			value = value,
			parent = proxy_value.data,
		}

		return object
	end
end

NumberFormatter_methods.Notation = NumberFormatter_with_setting("notation", "Notation")
NumberFormatter_methods.Precision = NumberFormatter_with_setting("precision", "Precision")
NumberFormatter_methods.RoundingMode = NumberFormatter_with_setting("roundingMode", 2)
NumberFormatter_methods.Grouping = NumberFormatter_with_setting("groupingStrategy", 2)
NumberFormatter_methods.IntegerWidth = NumberFormatter_with_setting("integerWidth", "IntegerWidth")
NumberFormatter_methods.Sign = NumberFormatter_with_setting("signDisplay", 3)

function NumberFormatter_methods:Format(value)
	local proxy_value = proxy_data[self]
	if not proxy_value or proxy_value.__name ~= "NumberFormatter" then
		error("Argument #1 must be a NumberFormatter object", 2)
	end
	if type(value) ~= "number" then
		error("Argument #2 must be a number", 2)
	end
	local is_negt, fmt, fmt_n, intg_i
	if value == 0 then
		is_negt = math.atan2(value, -1) < 0
		fmt, fmt_n, intg_i = nil, 0, 0
	elseif value ~= value then
		-- Sign bit detection for NaN
		-- NaN payload ignored
		is_negt = string.byte(string.pack(">d", value)) >= 0x80
		fmt = "nan"
	elseif value == math.huge then
		is_negt = false
		fmt = "inf"
	elseif value == -math.huge then
		is_negt = true
		fmt = "inf"
	elseif value % 1 == 0 and math.abs(value) < 0x40000000000008 then
		-- optimisation
		if value < 0 then
			is_negt = true
			value = -value
		end
		if value < 10 then
			fmt, fmt_n, intg_i = { value }, 1, 1
		else
			local int_str = string.format("%d", value)
			fmt = { string.byte(int_str, nil, -1) }
			intg_i = #fmt
			for i = intg_i, 1, -1 do
				if not fmt_n and fmt[i] ~= 0x30 then
					fmt_n = i
				end
				fmt[i] -= 0x30
			end
		end
	else
		is_negt = value < 0
		fmt, fmt_n, intg_i = double_to_decimal(math.abs(value))
	end
	
	return format_numberformatter(proxy_value, is_negt, fmt, fmt_n, intg_i)
end

FormatNumber.NumberFormatter = {
	with = function()
		local object = newproxy(true)
		local object_mt = getmetatable(object)
		proxy_data[object] = object_mt

		object_mt.__index = NumberFormatter_methods
		object_mt.__name = "NumberFormatter"
		object_mt.__tostring = to_string_object
		object_mt.resolved = nil
		object_mt.data = nil

		return object
	end,
}

--

return FormatNumber