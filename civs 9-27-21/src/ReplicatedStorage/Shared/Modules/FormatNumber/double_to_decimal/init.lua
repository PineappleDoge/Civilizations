-- Google's double conversion port by @Blockzez on Roblox.
-- Supports both grisu3 and fallback to BigNum implemention.
-- https://github.com/google/double-conversion
-- https://www.cs.tufts.edu/~nr/cs257/archive/florian-loitsch/printf.pdf
-- FormatNumber modification - I originally made this for International 3
local CACHED_POWERS = require(script.cached_powers)
local RECIPROCAL_LOG2_10 = 0.30102999566398114 -- 1 / math.log2(10)
local DOUBLE_EPSILON = 2 ^ -53
local UINT32_T_MAX = 0xFFFFFFFF

local function add_uint64_t(x0, x1, y0, y1)
	x0 += y0
	if x0 > UINT32_T_MAX then
		x0 -= UINT32_T_MAX + 1
		x1 += 1
	end
	if y1 then
		x1 += y1
		if x1 > UINT32_T_MAX then
			x1 -= UINT32_T_MAX + 1
		end
	elseif x1 == UINT32_T_MAX + 1 then
		x1 = 0
	end
	return x0, x1
end

local function sub_uint64_t(x0, x1, y0, y1)
	x0 -= y0
	if x0 < 0 then
		x0 += UINT32_T_MAX + 1
		x1 -= 1
	end
	if y1 then
		x1 -= y1
		if x1 < 0 then
			x1 += UINT32_T_MAX + 1
		end
	elseif x1 == -1 then
		x1 = UINT32_T_MAX + 1
	end
	return x0, x1
end

local function sal_uint64_t(x0, x1, y)
	if y < 0 then
		return
			bit32.rshift(x1, -32 - y) + bit32.lshift(x0, y),
			bit32.lshift(x1, y)
	end
	return
		bit32.lshift(x0, y),
		bit32.rshift(x0, 32 - y) + bit32.lshift(x1, y)
end

local function mult_uint32_t(x, y)
	local a, b, c, d =
		bit32.rshift(x, 16),
		bit32.band(x, 0xFFFF),
		bit32.rshift(y, 16),
		bit32.band(y, 0xFFFF)
	local s0, s1 = add_uint64_t(a * d, 0, b * c)
	return add_uint64_t(b * d, a * c, sal_uint64_t(s0, s1, 16))
end

local function mult_uint64_t(x0, x1, y0, y1)
	local x1y0_0, x1y0_1 = mult_uint32_t(x1, y0)
	return add_uint64_t(
		0, (add_uint64_t(
			x1y0_0, x1y0_1,
			mult_uint32_t(x0, y1)
			)),
		mult_uint32_t(x0, y0)
	)
end

local function compare_uint64_t(x0, x1, y0, y1)
	return
		x1 == y1 and (x0 == y0 and 0 or x0 < y0 and -1 or 1) or
		(x1 < y1 and -1 or 1)
end

local function mult_uint128_em(x0, x1, y0, y1)
	-- as per double-conversion/diy-fp.h:
	-- Simply "emulates" a 128 bit multiplication.
	-- However: the resulting number only contains 64 bits. The least
	-- significant 64 bits are only used for rounding the most significant 64
	-- bits.
	local x0y1_0, x0y1_1 = mult_uint32_t(x0, y1)
	local x1y0_0, x1y0_1 = mult_uint32_t(x1, y0)
	
	local tmp =
		select(2, add_uint64_t(
			0x80000000, 0, add_uint64_t(
				x0y1_0, 0, add_uint64_t(
					x1y0_0, 0, select(2, mult_uint32_t(x0, y0))
				)
			)
		))
	
	local tmp0, tmp1 = add_uint64_t(tmp, 0, add_uint64_t(x0y1_1, 0, x1y0_1))
	return add_uint64_t(
		tmp0, tmp1,
		mult_uint32_t(x1, y1)
	)
end

-- PowersOfTenCache::GetCachedPowerForBinaryExponentRange
-- this port doesn't have the max_exponent argument
local function cached_power_bin_expt_range(min_exponent)
	-- 348 = cached power offset = -1 * the first decimal_exponent
	return table.unpack(CACHED_POWERS[
		bit32.rshift(348 + math.ceil((min_exponent + 63) * RECIPROCAL_LOG2_10) - 1, 3) + 2
	], nil, 4)
end
-- PowersOfTenCache::GetCachedPowerForDecimalExponent
local function cached_power_for_decimal_expt(expt)
	return table.unpack(CACHED_POWERS[bit32.rshift(expt + 348, 3) + 1], nil, 4)
end
-- AsNormalizedDiyFp
local function as_normalized_diy_fp(val)
	local sigt, expt = math.frexp(val)
	local sigt1, sigt0 = math.modf(sigt * 0x100000000)
	return sigt0 * 0x100000000, sigt1, expt - 64
end
local function as_diy_fp(val)
	local sigt, expt = math.frexp(val)
	if expt < -1021 then
		-- subnormal numbers
		sigt *= 2 ^ (expt + 1021)
		expt = -1021
	end
	local sigt1, sigt0 = math.modf(sigt * 0x200000)
	return sigt0 * 0x100000000, sigt1, expt + 52
end
-- DiyFp::Normalize
local function normalize(sigt0, sigt1, expt)
	-- as per double-conversion/diy-fp.h:
	-- This method is mainly called for normalizing boundaries. In general,
	-- boundaries need to be shifted by 10 bits, and we optimize for this case.
	while bit32.band(sigt1, 0xFFC00000) == 0 do
		sigt0, sigt1 = sal_uint64_t(sigt0, sigt1, 10)
		expt -= 10
	end
	-- MSB of signficant
	while bit32.band(sigt1, 0x80000000) == 0 do
		sigt0, sigt1 = sal_uint64_t(sigt0, sigt1, 1)
		expt -= 1
	end
	return sigt0, sigt1, expt
end
-- Double::NormalizedBoundaries
local function normalized_boundaries(sigt0, sigt1, expt)
	local tmp_sigt0, tmp_sigt1 =
		add_uint64_t(1, 0, sal_uint64_t(sigt0, sigt1, 1))
	local m_plus_sigt0, m_plus_sigt1, m_plus_expt = normalize(
		-- (sigt << 1) + 1
		tmp_sigt0, tmp_sigt1,
		expt - 1
	)
	local m_minus_sigt0, m_minus_sigt1, m_minus_expt
	if sigt0 == 0 and sigt1 == 0 then
		tmp_sigt0, tmp_sigt1 = sal_uint64_t(sigt0, sigt1, 2)
		m_minus_sigt0, m_minus_sigt1 =
			sub_uint64_t(tmp_sigt0, tmp_sigt1, 1)
		m_minus_expt = expt - 2
	else
		tmp_sigt0, tmp_sigt1 = sal_uint64_t(sigt0, sigt1, 1)
		m_minus_sigt0, m_minus_sigt1 =
			sub_uint64_t(tmp_sigt0, tmp_sigt1, 1)
		m_minus_expt = expt - 1
	end
	m_minus_sigt0, m_minus_sigt1 = sal_uint64_t(
		m_minus_sigt0, m_minus_sigt1, m_minus_expt - m_plus_expt
	)
	return
		m_minus_sigt0, m_minus_sigt1,
		-- minus exponent is assigned to, it's the same as the plus exponent
		m_plus_expt,
	
		m_plus_sigt0, m_plus_sigt1, m_plus_expt
end

local function round_weed(
	buffer, length,
	distance_too_high_w0, distance_too_high_w1,
	unsafe_interval0, unsafe_interval1,
	rest0, rest1,
	ten_kappa0, ten_kappa1,
	unit0, unit1
)
	
	local small_distance0, small_distance1 =
		sub_uint64_t(
			distance_too_high_w0, distance_too_high_w1, unit0, unit1
		)
	local big_distance0, big_distance1 =
		add_uint64_t(
			distance_too_high_w0, distance_too_high_w1, unit0, unit1
		)
	while compare_uint64_t(rest0, rest1, small_distance0, small_distance1) < 0
		and compare_uint64_t(
			ten_kappa0, ten_kappa1, sub_uint64_t(
				unsafe_interval0, unsafe_interval1,
				rest0, rest1
			)
		) <= 0
	do
		local sd0, sd1 =
			add_uint64_t(rest0, rest1, ten_kappa0, ten_kappa1)
		sd0, sd1 = sub_uint64_t(sd0, sd1, small_distance0, small_distance1)
		if compare_uint64_t(
			small_distance0, small_distance1,
			add_uint64_t(rest0, rest1, ten_kappa0, ten_kappa1)) <= 0
			and compare_uint64_t(sd0, sd1,
				sub_uint64_t(small_distance0, small_distance1,
					rest0, rest1)) > 0 then
			break
		end
		buffer[length] -= 1
		rest0, rest1 =
			add_uint64_t(rest0, rest1, ten_kappa0, ten_kappa1)
	end
	
	if compare_uint64_t(rest0, rest1, big_distance0, big_distance1) < 0
		and compare_uint64_t(
			ten_kappa0, ten_kappa1, sub_uint64_t(
				unsafe_interval0, unsafe_interval1,
				rest0, rest1
			)
		) <= 0
	then
		local sd0, sd1 =
			add_uint64_t(rest0, rest1, ten_kappa0, ten_kappa1)
		sd0, sd1 = sub_uint64_t(sd0, sd1, big_distance0, big_distance1)
		if compare_uint64_t(
			big_distance0, big_distance1,
			add_uint64_t(rest0, rest1, ten_kappa0, ten_kappa1)) > 0
			or compare_uint64_t(sd0, sd1,
				sub_uint64_t(big_distance0, big_distance1,
					rest0, rest1)) < 0
		then
			return false
		end
	end
	
	return compare_uint64_t(rest0, rest1, sal_uint64_t(unit0, unit1, 1)) >= 0
		and compare_uint64_t(
			rest0, rest1,
			sub_uint64_t(
				unsafe_interval0, unsafe_interval1,
				sal_uint64_t(unit0, unit1, 2)
			)
		) <= 0
end

local small_powers_of_ten = { [0] = 0,
	1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000,
	1000000000 }
local function biggest_power_10(val, val_bits)
	local exponent_plus_one_guess =
		bit32.rshift((val_bits + 1) * 1233, 12) + 1
	if val < small_powers_of_ten[exponent_plus_one_guess] then
		exponent_plus_one_guess -= 1
	end
	return
		small_powers_of_ten[exponent_plus_one_guess],
		exponent_plus_one_guess
end

local function digit_gen(
	low_sigt0, low_sigt1, low_expt,
	w_sigt0, w_sigt1, w_expt,
	high_sigt0, high_sigt1, high_expt
)
	local unit0, unit1 = 1, 0
	local too_low_sigt0, too_low_sigt1 = sub_uint64_t(low_sigt0, low_sigt1, unit0)
	local too_high_sigt0, too_high_sigt1 = add_uint64_t(high_sigt0, high_sigt1, unit0)
	
	local unsafe_interval0, unsafe_interval1 =
		sub_uint64_t(
			too_high_sigt0, too_high_sigt1,
			too_low_sigt0, too_low_sigt1
		)
	
	local one0, one1 = sal_uint64_t(1, 0, -w_expt)
	local one_decr0, one_decr1 = sub_uint64_t(one0, one1, 1)
	local frac0, frac1 =
		bit32.band(too_high_sigt0, one_decr0),
		bit32.band(too_high_sigt1, one_decr1)
	local intg = sal_uint64_t(too_high_sigt0, too_high_sigt1, w_expt)
	local divisor, divisor_exponent_plus_one =
		biggest_power_10(intg, 64 + w_expt)
	
	local kappa = divisor_exponent_plus_one
	local length = 0
	
	local buffer = table.create(17)
	while kappa > 0 do
		length += 1
		buffer[length] = math.floor(intg / divisor)
		intg %= divisor
		kappa -= 1
		
		local rest0, rest1 =
			add_uint64_t(frac0, frac1, sal_uint64_t(intg, 0, -w_expt))
		
		if compare_uint64_t(rest0, rest1,
			unsafe_interval0, unsafe_interval1) < 0 then
			local dth0, dth1 = sub_uint64_t(
				too_high_sigt0, too_high_sigt1, w_sigt0, w_sigt1)
			local ten_kappa0, ten_kappa1 = sal_uint64_t(divisor, 0, -w_expt)
			return round_weed(
				buffer, length, dth0, dth1,
				unsafe_interval0, unsafe_interval1,
				rest0, rest1,
				ten_kappa0, ten_kappa1,
				unit0, unit1
			), buffer, length, kappa
		end
		divisor /= 10
	end
	
	while true do
		frac0, frac1 = mult_uint64_t(frac0, frac1, 10, 0)
		unit0, unit1 = mult_uint64_t(unit0, unit1, 10, 0)
		unsafe_interval0, unsafe_interval1 =
			mult_uint64_t(unsafe_interval0, unsafe_interval1, 10, 0)
		
		length += 1
		buffer[length] = sal_uint64_t(frac0, frac1, w_expt)
		frac0, frac1 =
			bit32.band(frac0, one_decr0), bit32.band(frac1, one_decr1)
		kappa -= 1
		if compare_uint64_t(
			frac0, frac1, unsafe_interval0,
			unsafe_interval1) < 0 then
			local dth0, dth1 = mult_uint64_t(
				unit0, unit1,
				sub_uint64_t(
					too_high_sigt0, too_high_sigt1,
					w_sigt0, w_sigt1
				)
			)
			return round_weed(
				buffer, length,
				dth0, dth1,
				unsafe_interval0, unsafe_interval1,
				frac0, frac1,
				one0, one1,
				unit0, unit1
			), buffer, length, kappa
		end
	end
end

local function grisu3(val)
	local w_sigt0, w_sigt1, w_expt = as_normalized_diy_fp(val)
	local
		boundary_minus_sigt0, boundary_minus_sigt1, boundary_minus_expt,
		boundary_plus_sigt0, boundary_plus_sigt1, boundary_plus_expt =
		normalized_boundaries(as_diy_fp(val))
	
	-- per double-conversion/fast-dtoa.cc:
	-- cached power of ten: 10^-k
	local ten_mk_sigt0, ten_mk_sigt1, ten_mk_expt, mk
		= cached_power_bin_expt_range(-60 - (w_expt + 64))
	
	-- exponent = w_expt + 64
	local scaled_w_sigt0, scaled_w_sigt1 =
		mult_uint128_em(w_sigt0, w_sigt1, ten_mk_sigt0, ten_mk_sigt1)
	
	local scaled_boundary_minus_sigt0, scaled_boundary_minus_sigt1 =
		mult_uint128_em(
			boundary_minus_sigt0, boundary_minus_sigt1,
			ten_mk_sigt0, ten_mk_sigt1
		)
	
	local scaled_boundary_plus_sigt0, scaled_boundary_plus_sigt1 =
		mult_uint128_em(
			boundary_plus_sigt0, boundary_plus_sigt1,
			ten_mk_sigt0, ten_mk_sigt1
		)
	
	local result, buffer, length, kappa = digit_gen(
		scaled_boundary_minus_sigt0, scaled_boundary_minus_sigt1,
		boundary_minus_expt + ten_mk_expt + 64,
		
		scaled_w_sigt0, scaled_w_sigt1, w_expt + ten_mk_expt + 64,
		scaled_boundary_plus_sigt0, scaled_boundary_plus_sigt1,
		
		boundary_plus_expt + ten_mk_expt + 64
	)
	
	if result then
		return buffer, length, -mk + kappa
	end
	-- fallback
	return nil
end

-- bignum dtoa
local function bignum_sal(bnum, disp)
	local local_shift = disp % 28
	bnum.expt += (disp - local_shift) / 28
	
	local c = 0
	for i, v in ipairs(bnum) do
		bnum[i], c =
			bit32.band(c + bit32.lshift(v, local_shift), 0xFFFFFFF),
			bit32.rshift(v, 28 - local_shift)
	end
	if c ~= 0 then
		table.insert(bnum, c)
	end
end

local function bignum_clamp(bnum)
	while bnum[#bnum] == 0 do
		table.remove(bnum)
	end
end

local function bignum_align(bnum, other)
	local zero_digits = bnum.expt - other.expt
	for i = 1, zero_digits do
		table.insert(bnum, 1, 0)
	end
	bnum.expt -= math.max(zero_digits, 0)
end

local function bignum_assign_uint64_t(bnum, x0, x1)
	bnum[1], bnum[2], bnum[3] =
		bit32.band(x0, 0xFFFFFFF),
		bit32.rshift(x0, 28) + bit32.lshift(bit32.band(x1, 0xFFFFFF), 4),
		bit32.rshift(x1, 24)
	bignum_clamp(bnum)
end

local function bignum_square(bnum)
	local accumulator0, accumulator1 = 0, 0
	local bnum_n = #bnum
	for i = 1, bnum_n do
		bnum[bnum_n + i] = bnum[i]
	end
	for i = 1, bnum_n do
		local bnum_index0 = i
		local bnum_index1 = 1
		while bnum_index0 > 0 do
			accumulator0, accumulator1 = add_uint64_t(
				accumulator0, accumulator1,
				mult_uint32_t(bnum[bnum_n + bnum_index0],
					bnum[bnum_n + bnum_index1])
			)
			bnum_index0 -= 1
			bnum_index1 += 1
		end
		
		bnum[i] = bit32.band(accumulator0, 0xFFFFFFF)
		accumulator0, accumulator1 = sal_uint64_t(
			accumulator0, accumulator1, -28)
	end
	for i = bnum_n + 1, bnum_n * 2 do
		local bnum_index0 = bnum_n
		local bnum_index1 = i - bnum_index0 + 1
		while bnum_index1 <= bnum_n do
			accumulator0, accumulator1 = add_uint64_t(
				accumulator0, accumulator1,
				mult_uint32_t(bnum[bnum_n + bnum_index0],
					bnum[bnum_n + bnum_index1])
			)
			bnum_index0 -= 1
			bnum_index1 += 1
		end
		bnum[i] = bit32.band(accumulator0, 0xFFFFFFF)
		accumulator0, accumulator1 = sal_uint64_t(
			accumulator0, accumulator1, -28)
	end
	
	bnum.expt *= 2
	bignum_clamp(bnum)
end

local function bignum_add(bnum, other)
	bignum_align(bnum, other)

	local offset = other.expt - bnum.expt
	local carry = 0
	local other_n = #other
	local i = 1
	while i <= other_n or carry ~= 0 do
		local diff = (bnum[i + offset] or 0) + (other[i] or 0) + carry
		bnum[i + offset] = bit32.band(diff, 0xFFFFFFF)
		carry = bit32.rshift(diff, 28)
		i += 1
	end

	bignum_clamp(bnum)
end

local function bignum_sub(bnum, other)
	bignum_align(bnum, other)
	
	local offset = other.expt - bnum.expt
	local carry = 0
	local other_n = #other
	local i = 1
	while i <= other_n or carry ~= 0 do
		local diff = bnum[i + offset] - (other[i] or 0) - carry
		bnum[i + offset] = bit32.band(diff, 0xFFFFFFF)
		carry = bit32.rshift(diff, 31)
		i += 1
	end
	
	bignum_clamp(bnum)
end

local function bignum_sub_times(bnum, other, factor)
	if factor < 3 then
		for i = 1, factor do
			bignum_sub(bnum, other)
		end
		return
	end
	local burrow = 0
	local expt_diff = other.expt - bnum.expt
	local other_n = #other
	for i = 1, other_n do
		local prod0, prod1 = mult_uint32_t(factor, other[i])
		local rem0, rem1 = add_uint64_t(prod0, prod1, burrow)
		local diff = bnum[i + expt_diff] - bit32.band(rem0, 0xFFFFFFF)
		bnum[i + expt_diff] = bit32.band(diff, 0xFFFFFFF)
		burrow = add_uint64_t(bit32.rshift(diff, 31), 0, sal_uint64_t(rem0, rem1, -28))
	end
	for i = other_n + expt_diff + 1, #bnum do
		if burrow == 0 then
			return
		end
		local diff = bnum[i] - burrow
		bnum[i] = bit32.band(diff, 0xFFFFFFF)
		burrow = bit32.rshift(diff, 31)
	end
	bignum_clamp(bnum)
end

local function bignum_mult_uint32_t(bnum, factor)
	local c0, c1 = 0, 0
	for i, bigit in ipairs(bnum) do
		local prod0, prod1 = add_uint64_t(c0, c1, mult_uint32_t(factor, bigit))
		bnum[i] = bit32.band(prod0, 0xFFFFFFF)
		c0, c1 = sal_uint64_t(prod0, prod1, -28)
	end
	while c0 ~= 0 or c1 ~= 0 do
		table.insert(bnum, bit32.band(c0, 0xFFFFFFF))
		c0, c1 = sal_uint64_t(c0, c1, -28)
	end
end

local function bignum_mult_uint64_t(bnum, factor0, factor1)
	local c0, c1 = 0, 0
	for i, bigit in ipairs(bnum) do
		local prod_lo0, prod_lo1 = mult_uint32_t(factor0, bigit)
		local prod_hi0, prod_hi1 = mult_uint32_t(factor1, bigit)
		local tmp0, tmp1 = add_uint64_t(bit32.band(c0, 0xFFFFFFF), 0, prod_lo0, prod_lo1)
		bnum[i] = bit32.band(tmp0, 0xFFFFFFF)
		c0, c1 = sal_uint64_t(c0, c1, -28)
		c0, c1 = add_uint64_t(c0, c1, sal_uint64_t(tmp0, tmp1, -28))
		c0, c1 = add_uint64_t(c0, c1, sal_uint64_t(prod_hi0, prod_hi1, 4))
	end
	while c0 ~= 0 or c1 ~= 0 do
		table.insert(bnum, bit32.band(c0, 0xFFFFFFF))
		c0, c1 = sal_uint64_t(c0, c1, -28)
	end
end

local function bignum_from_power(base, pow_expt)
	if pow_expt == 0 then
		return { expt = 0, 1 }
	end
	local shifts = 0
	while bit32.band(base, 1) == 0 do
		base = bit32.rshift(base, 1)
		shifts += 1
	end
	local bit_size = 0
	local tmp_base = base
	while tmp_base ~= 0 do
		tmp_base = bit32.rshift(tmp_base, 1)
		bit_size += 1
	end
	local final_size = bit_size * pow_expt
	local ret = table.create(final_size / 28 + 2)
	ret.expt = 0
	
	-- Left to Right exponentiation
	local mask = 1
	while pow_expt >= mask do
		mask *= 2
	end
	
	-- As per double-conversion/bignum
	-- The mask is now pointing to the bit above the most significant 1-bit of
	-- power_exponent.
	-- Get rid of first 1-bit
	mask = bit32.rshift(mask, 2)
	local this_val0, this_val1 = base, 0
	
	local delayed_mult = false
	while mask ~= 0 and this_val1 == 0 do
		this_val0, this_val1 = mult_uint64_t(
			this_val0, this_val1, this_val0, this_val1)
		if bit32.band(pow_expt, mask) ~= 0 then
			local base_bits_mask0, base_bits_mask1 = sal_uint64_t(1, 0, 64 - bit_size)
			base_bits_mask0, base_bits_mask1 = sub_uint64_t(base_bits_mask0, base_bits_mask1, 1)
			if bit32.band(this_val0, bit32.bnot(base_bits_mask0)) == 0 and bit32.band(this_val1, bit32.bnot(base_bits_mask1)) == 0 then
				this_val0, this_val1 = mult_uint64_t(this_val0, this_val1, base, 0)
			else
				delayed_mult = true
			end
		end
		mask = bit32.rshift(mask, 1)
	end
	
	bignum_assign_uint64_t(ret, this_val0, this_val1)
	if delayed_mult then
		bignum_mult_uint32_t(ret, base)
	end
	
	while mask ~= 0 do
		bignum_square(ret)
		if bit32.band(pow_expt, mask) ~= 0 then
			bignum_mult_uint32_t(ret, base)
		end
		mask = bit32.rshift(mask, 1)
	end
	
	bignum_sal(ret, shifts * pow_expt)
	return ret
end

local function bignum_compare(a, b)
	local len_a, len_b = #a + a.expt, #b + b.expt
	if len_a < len_b then
		return -1
	elseif len_a > len_b then
		return 1
	end
	for i = len_a, math.min(a.expt, b.expt) + 1, -1 do
		local a_i, b_i = a[i] or 0, b[i] or 0
		if a_i < b_i then
			return -1
		elseif a_i > b_i then
			return 1
		end
	end
	return 0
end

local function bignum_plus_compare(a, b, c)
	local len_a, len_b, len_c = #a + a.expt, #b + b.expt, #c + c.expt
	if len_a < len_b then
		len_a, len_b = len_b, len_a
		a, b = b, a
	end
	if len_a + 1 < len_c then
		return -1
	end
	if len_a > len_c then
		return 1
	end
	if a.expt >= len_b and len_a < len_c then
		return -1
	end
	
	local burrow = 0
	local min_expt = math.min(a.expt, b.expt, c.expt)
	for i = len_c, min_expt + 1, -1 do
		local chunk_a = a[i - a.expt] or 0
		local chunk_b = b[i - b.expt] or 0
		local chunk_c = c[i - c.expt] or 0
		local sum = chunk_a + chunk_b
		if sum > chunk_c + burrow then
			return 1
		else
			burrow = chunk_c + burrow - sum
			if burrow > 1 then
				return -1
			end
			burrow = bit32.lshift(burrow, 28)
		end
	end
	if burrow == 0 then
		return 0
	end
	return -1
end

local function bignum_divmod(bnum, other)
	local len, len_other = #bnum + bnum.expt, #other + other.expt
	if len < len_other then
		return 0
	end
	
	bignum_align(bnum, other)
	
	local bnum_n = #bnum
	local ret = 0
	while len > len_other do
		ret += bnum[bnum_n]
		bignum_sub_times(bnum, other, bnum[bnum_n])
		bnum_n = #bnum
		len = bnum_n + bnum.expt
	end
	
	local this_i = bnum[bnum_n]
	local other_i = other[#other]
	
	if not other[2] then
		-- shortcut for easy and common case
		-- (actually truncate divison but I doubt negative will be
		-- one of the input)
		local quotient = math.floor(this_i / other_i)
		bnum[bnum_n] = this_i - other_i * quotient
		bignum_clamp(bnum)
		return ret + quotient
	end

	-- (actually truncate divison but I doubt negative will be one of the input)
	local div_est = math.floor(this_i / (other_i + 1))
	ret += div_est
	bignum_sub_times(bnum, other, div_est)
	
	if other_i * (div_est + 1) > this_i then
		return ret
	end
	
	while bignum_compare(other, bnum) <= 0 do
		bignum_sub(bnum, other)
		ret += 1
	end
	return ret
end

local function normalized_exponent(sigt0, sigt1, expt)
	while bit32.band(sigt1, 0x100000) == 0 do
		sigt0, sigt1 = sal_uint64_t(sigt0, sigt1, 1)
		expt -= 1
	end
	return expt
end

local function estimate_power(norm_expt)
	return math.ceil((norm_expt + 52) * RECIPROCAL_LOG2_10 - 1e-10)
end

local function initial_scaled_start_values_positive_exponent(
	sigt0, sigt1, expt, estimated_power)
	local expt_div_28 = expt / 28
	local numerator = table.create(expt_div_28 + 2)
	numerator.expt = 0
	bignum_assign_uint64_t(numerator, sigt0, sigt1)
	bignum_sal(numerator, expt + 1)
	local denominator = bignum_from_power(10, estimated_power)
	bignum_sal(denominator, 1)
	
	local delta_plus = table.create(expt_div_28)
	delta_plus.expt = 0
	delta_plus[1] = 1
	bignum_sal(delta_plus, expt)
	local delta_minus = { expt = delta_plus.expt, table.unpack(delta_plus) }
	
	return numerator, denominator, delta_minus, delta_plus
end

local function initial_scaled_start_values_negative_exponent_positive_power(
	sigt0, sigt1, expt, estimated_power)
	local numerator = { expt = 0, nil, nil, nil }
	bignum_assign_uint64_t(numerator, sigt0, sigt1)
	bignum_sal(numerator, 1)
	
	local denominator = bignum_from_power(10, estimated_power)
	bignum_sal(denominator, -expt + 1)

	local delta_plus = { expt = 0, 1 }
	local delta_minus = { expt = 0, 1 }

	return numerator, denominator, delta_minus, delta_plus
end

local function initial_scaled_start_values_negative_exponent_negative_power(
	sigt0, sigt1, expt, estimated_power)
	local pow10 = bignum_from_power(10, -estimated_power)
	
	local delta_plus = { expt = pow10.expt, table.unpack(pow10) }
	local delta_minus = { expt = pow10.expt, table.unpack(pow10) }
	
	bignum_mult_uint64_t(pow10, sigt0, sigt1)
	bignum_sal(pow10, 1)
	
	local denominator = { expt = 0, 1 }
	bignum_sal(denominator, -expt + 1)
	
	return pow10, denominator, delta_minus, delta_plus
end

local function initial_scaled_start_values(
	sigt0, sigt1, expt, lower_boundary_is_closer, estimated_power)
	local numerator, denominator, delta_minus, delta_plus
	if expt >= 0 then
		numerator, denominator, delta_minus, delta_plus =
			initial_scaled_start_values_positive_exponent(
				sigt0, sigt1, expt, estimated_power)
	elseif estimated_power >= 0 then
		numerator, denominator, delta_minus, delta_plus =
			initial_scaled_start_values_negative_exponent_positive_power(
				sigt0, sigt1, expt, estimated_power)
	else
		numerator, denominator, delta_minus, delta_plus =
			initial_scaled_start_values_negative_exponent_negative_power(
				sigt0, sigt1, expt, estimated_power)
	end
	if lower_boundary_is_closer then
		bignum_sal(denominator, 1)
		bignum_sal(numerator, 1)
		bignum_sal(delta_plus, 1)
	end
	return numerator, denominator, delta_minus, delta_plus
end

local function fixup_mult_10(
	estimated_power, is_even,
	numerator, denominator, delta_minus, delta_plus)
	local in_range = bignum_plus_compare(numerator, delta_plus, denominator)
		>= (is_even and 0 or 1)
	
	if in_range then
		return estimated_power + 1, numerator, denominator, delta_minus, delta_plus
	end
	bignum_mult_uint32_t(numerator, 10)
	bignum_mult_uint32_t(delta_minus, 10)
	bignum_mult_uint32_t(delta_plus, 10)
	return estimated_power, numerator, denominator, delta_minus, delta_plus
end

local function digit_gen_bignum(
	is_even, intg_i, numerator, denominator, delta_minus, delta_plus)
	-- Tiny optimisation where delta_plus and delta_minus is reused if
	-- they're the same
	if bignum_compare(delta_minus, delta_plus) == 0 then
		delta_plus = delta_minus
	end
	local buffer = table.create(17)
	local buffer_n = 0
	
	while true do
		buffer_n += 1
		buffer[buffer_n] = bignum_divmod(numerator, denominator)
		
		local in_delta_room_minus, in_delta_room_plus =
			bignum_compare(numerator, delta_minus)
				<= (is_even and 0 or -1),
			bignum_plus_compare(numerator, delta_plus, denominator)
				>= (is_even and 0 or 1)
		
		if not in_delta_room_minus and not in_delta_room_plus then
			bignum_mult_uint32_t(numerator, 10)
			bignum_mult_uint32_t(delta_minus, 10)
			if delta_minus ~= delta_plus then
				bignum_mult_uint32_t(delta_plus, 10)
			end
		elseif in_delta_room_minus and in_delta_room_plus then
			local cmp = bignum_plus_compare(numerator, numerator, denominator)
			if cmp >= 0 or cmp == 0 and buffer[buffer_n] % 2 ~= 0 then
				buffer[buffer_n] += 1
			end
			break
		elseif in_delta_room_minus then
			break
		elseif in_delta_room_plus then
			buffer[buffer_n] += 1
			break
		end
	end
	return buffer, buffer_n, intg_i - buffer_n
end

local function bignum_dtoa(val)
	local sigt0, sigt1, expt = as_diy_fp(val)
	expt -= 105
	local lower_boundary_is_closer = sigt0 == 0 and sigt1 == 0
	
	local is_even = bit32.band(sigt0, 1) == 0
	local norm_expt = normalized_exponent(sigt0, sigt1, expt)
	-- estimated_power might be too low by 1.
	local estimated_power = estimate_power(norm_expt)
	
	return digit_gen_bignum(
		is_even,
		fixup_mult_10(
			estimated_power, is_even,
			initial_scaled_start_values(sigt0, sigt1, expt,
				lower_boundary_is_closer, estimated_power)
		)
	)
end
--

-- argument 1 must be finite and > 0
return function(val)
	local dec, length, expt = grisu3(val)
	if not dec then
		-- fallback
		dec, length, expt = bignum_dtoa(val)
	end
	return dec, length, length + expt
end