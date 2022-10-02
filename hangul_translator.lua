local function wrapped_gsub(inp, pattern, repl)
	inp = string.gsub(inp, "([aeiouw])" .. pattern .. "$", "%1" .. repl)
	inp = string.gsub(inp, "([aeiouw])" .. pattern .. "([^aeiouw])", "%1" .. repl .."%2")
	return inp
end

local function rightbound_gsub(inp, pattern, repl)
	inp = string.gsub(inp, pattern .. "$", repl)
	inp = string.gsub(inp, pattern .. "'", repl .. "'")
	inp = string.gsub(inp, pattern .. "([^aeiouw])", repl .. "%1")
	return inp
end

local function ascii_to_jamo(inp)
	log.info(inp)
	if inp == "" then return "" end

	inp = string.gsub(inp, " ", "'")
    inp = string.gsub(inp, "wa", "oa")
    inp = string.gsub(inp, "w[eo]", "ue")
    inp = string.gsub(inp, "f", "x")
    inp = string.gsub(inp, "r", "l")

    -- double final consonants
    inp = wrapped_gsub(inp,"gs", "ᆪ")
    inp = wrapped_gsub(inp, "nj", "ᆬ")
    inp = wrapped_gsub(inp, "nh", "ᆭ")
    inp = wrapped_gsub(inp, "lg", "ᆰ")
    inp = wrapped_gsub(inp, "lm", "ᆱ")
    inp = wrapped_gsub(inp, "lb", "ᆲ")
    inp = wrapped_gsub(inp, "ls", "ᆳ")
    inp = wrapped_gsub(inp, "lt", "ᆴ")
    inp = wrapped_gsub(inp, "lp", "ᆵ")
    inp = wrapped_gsub(inp, "lh", "ᆶ")
    inp = wrapped_gsub(inp, "bs", "ᆹ")

    -- tense and lax consonant pairs
    inp = rightbound_gsub(inp, "G", "ᆩ")
    inp = string.gsub(inp, "G", "ᄁ")
    inp = wrapped_gsub(inp, "g", "ᆨ")
    inp = string.gsub(inp, "g", "ᄀ")

    inp = rightbound_gsub(inp, "S", "ᆻ")
    inp = string.gsub(inp, "S", "ᄊ")
    inp = wrapped_gsub(inp, "s", "ᆺ")
    inp = string.gsub(inp, "s", "ᄉ")

    inp = string.gsub(inp, "B", "ᄈ")
    inp = wrapped_gsub(inp, "b", "ᆸ")
    inp = string.gsub(inp, "b", "ᄇ")

    inp = string.gsub(inp, "D", "ᄄ")
    inp = wrapped_gsub(inp, "d", "ᆮ")
    inp = string.gsub(inp, "d", "ᄃ")

    inp = string.gsub(inp, "J", "ᄍ")
    inp = wrapped_gsub(inp, "j", "ᆽ")
    inp = string.gsub(inp, "j", "ᄌ")

    -- Rest of the consonants
    inp = wrapped_gsub(inp, "l", "ᆯ")
    inp = string.gsub(inp, "l", "ᄅ")

    inp = wrapped_gsub(inp, "m", "ᆷ")
    inp = string.gsub(inp, "m", "ᄆ")

    inp = wrapped_gsub(inp, "h", "ᇂ")
    inp = string.gsub(inp, "h", "ᄒ")

    inp = wrapped_gsub(inp, "n", "ᆫ")
    inp = string.gsub(inp, "n", "ᄂ")

    inp = wrapped_gsub(inp, "c", "ᆾ")
    inp = string.gsub(inp, "c", "ᄎ")

    inp = wrapped_gsub(inp, "p", "ᇁ")
    inp = string.gsub(inp, "p", "ᄑ")

    inp = wrapped_gsub(inp, "t", "ᇀ")
    inp = string.gsub(inp, "t", "ᄐ")

    inp = wrapped_gsub(inp, "k", "ᆿ")
    inp = string.gsub(inp, "k", "ᄏ")

	inp = string.gsub(inp, "([^aeiouw])x", "%1ᄋ")
	inp = string.gsub(inp, "x([aeiouw])", "ᄋ%1")
	inp = string.gsub(inp, "x", "ᆼ")

    inp = string.gsub(inp, "iai", "ᅤ")
    inp = string.gsub(inp, "iei", "ᅨ")
    inp = string.gsub(inp, "uei", "ᅰ")
    inp = string.gsub(inp, "oai", "ᅫ")
    inp = string.gsub(inp, "ai", "ᅢ")
    inp = string.gsub(inp, "ei", "ᅦ")
    inp = string.gsub(inp, "ia", "ᅣ")
    inp = string.gsub(inp, "ie", "ᅧ")
    inp = string.gsub(inp, "io", "ᅭ")
    inp = string.gsub(inp, "iu", "ᅲ")
    inp = string.gsub(inp, "ue", "ᅯ")
    inp = string.gsub(inp, "ui", "ᅱ")
    inp = string.gsub(inp, "wi", "ᅴ")
    inp = string.gsub(inp, "oa", "ᅪ")
    inp = string.gsub(inp, "o", "ᅩ")
    inp = string.gsub(inp, "e", "ᅥ")
    inp = string.gsub(inp, "a", "ᅡ")
    inp = string.gsub(inp, "i", "ᅵ")
    inp = string.gsub(inp, "u", "ᅮ")
    inp = string.gsub(inp, "w", "ᅳ")

	inp = string.gsub(inp, "'", "")
	log.info(inp)
	return inp
end

-- assumes inp has only a single Unicode character
local function is_lpart_jamo(c)
	return 0x1100 <= c and c <= 0x1112
end

-- assumes inp has only a single Unicode character
local function is_vpart_jamo(c)
	return 0x1161 <= c and c <= 0x1175
end

-- assumes inp has only a single Unicode character
local function is_tpart_jamo(c)
    return 0x11A8 <= c and c <= 0x11C2
end

local function jamos_to_hangul(inp)
	local SBase = 0xAC00
	local LBase = 0x1100
	local VBase = 0x1161
	local TBase = 0x11A7
	local LCount = 19
	local VCount = 21
	local TCount = 28
	local NCount = 588    -- VCount * TCount
	local SCount = 11172  -- LCount * NCount

	local l_state = 0
	local v_state = 1
	local t_state = 2

	local part_state = l_state
	local LVIndex = 0

	local hangul = ""

	for _, part in utf8.codes(inp) do
	    print(part)
		if part_state == l_state then -- lpart state
			if is_lpart_jamo(part) then
				LVIndex = (part - LBase) * NCount
				part_state = v_state
			else
				hangul = hangul .. utf8.char(part)
			end
		elseif part_state == v_state then -- vpart state
			if is_vpart_jamo(part) then
				LVIndex = LVIndex + (part - VBase) * TCount
				part_state = t_state
			else
				prev_lpart = LVIndex // NCount + LBase
				if is_lpart_jamo(part) then
					hangul = hangul .. utf8.char(prev_lpart)
					LVIndex = (part - LBase) * NCount
				else
					hangul = hangul .. utf8.char(prev_lpart, part)
					part_state = l_state
				end
			end
		elseif part_state == 2 then -- tpart state
			local s = 0
			local append_hangul = ""
			if is_tpart_jamo(part) then
				TIndex = part - TBase
				s = SBase + LVIndex + TIndex
				part_state = l_state
			elseif is_lpart_jamo(part) then
				s = SBase + LVIndex
				LVIndex = (part - LBase) * NCount
				part_state = v_state
			else
				s = SBase + LVIndex
			append_hangul = utf8.char(part)
				part_state = l_state
			end
			print(s)
			hangul = hangul .. utf8.char(s) .. append_hangul
		end
	end

	if part_state == v_state then
		prev_lpart = LVIndex // NCount + LBase
		hangul = hangul .. utf8.char(prev_lpart)
	elseif part_state == t_state then
		s = SBase + LVIndex
		hangul = hangul .. utf8.char(s)
	end

	return hangul
end

local function translator(inp, seg)
	local hangul = jamos_to_hangul(ascii_to_jamo(inp))
	local cand = Candidate("placeholder", seg.start, seg._end, hangul, "")
	cand.preedit = hangul
	yield(cand)
end

return translator
