note
	description: "[
		Perform arithmetic (+, -, *, //, \\, ^, gcd) on integer numbers 
		with infinite precision. Adapted from VALUE, so not efficient. 
		`out' provides a string represesentation.
		See end of this file for routine
		that needc to be made more efficient.
	]"
	author: "JSO"
	date: "$17 July, 2018$"
	revision: "$0.91$"

class
	BIG_INTEGER

inherit

	COMPARABLE
		redefine
			is_equal,
			default_create,
			out
		end

	NUMERIC
		rename
			quotient as numeric_quotient
		redefine
			is_equal,
			default_create,
			out
		end

create
	make_from_string, make_from_integer, default_create

convert
	make_from_string ({STRING}),
	as_integer64: {INTEGER_64},
	out: {STRING}

feature {NONE} -- constructors

	default_create
			-- create big integer 0
		local
			empty: STRING
		do
			empty := "0"
			item := empty.twin
		ensure then
			item.is_equal ("0")
		end

	make_from_string (s: STRING)
			-- create a big inetger from string `s'
		require
			non_empty: not s.is_empty
			has_correct_format: is_string_int (s)
		do
			item := s.twin
			normalize
		end

	make_from_integer (int: INTEGER_64)
			-- create a big integer from `int'
		local
			ch: CHARACTER
			m, n, d: INTEGER_64
			neg: BOOLEAN
		do
			m := int
			if m = 0 then
				create item.make_from_string ("0")
			elseif m = -9223372036854775808 then
				create item.make_from_string ("-9223372036854775808")
			else
				neg := m < 0
				if neg then
					m := m * -1
				end
				from
					n := m
					create item.make_empty
				until
					n = 0
				loop
					d := n \\ 10;
					n := n // 10;
					ch := to_char (d)
					item.insert_character (ch, 1)
				end
				if neg then
					negate
				end
				normalize
			end
		end

feature -- comparison

	is_string_int (s: STRING): BOOLEAN
			-- Is the given string a representation of big integer?
		require
			non_empty: not s.is_empty
		local
			seenDot: BOOLEAN
			i: INTEGER
		do
				-- valid patterns are: [-]?[0-9]+

			seenDot := false
			result := true
			from
				i := 1
			until
				i > s.count
			loop
				if s.item (i) = '-' then
					if i > 1 then
						result := false
						i := s.count + 1 -- stop looping
					end
				elseif s.item (i) = '.' then
						--					if i = s.count or seenDot then
						--						result := false
						--						i := s.count + 1 -- stop looping
						--					end
						--					seenDot := true
					Result := False
				elseif not s.item (i).is_digit then
					result := false
					i := s.count + 1 -- stop looping
				end
				i := i + 1
			end
		end

	is_equal (other: BIG_INTEGER): BOOLEAN
			-- Is equal to current?
		do
			Result := item_fix.is_equal (other.item_fix)
		end

	is_less alias "<" (other: BIG_INTEGER): BOOLEAN
			-- whether current is less than `other'
		local
			r1i, r2i, d1, d2: INTEGER
			r1, r2: BIG_INTEGER
		do
			r1 := current.clone_me
			r2 := other.clone_me
			if r1.item.item (1) = '-' and r2.item.item (1) /= '-' then
				result := true
			elseif r1.item.item (1) /= '-' and r2.item.item (1) = '-' then
				result := false
			elseif r1.item.item (1) = '-' and r2.item.item (1) = '-' then
				r1.negate
				r2.negate
				result := r2 < r1
			else
				r1.align_decimal (r2)
				r1.align_whole (r2)
				result := false
				from
					r1i := 1
					r2i := 1
				until
					r1i > r1.item.count or r2i > r2.item.count
				loop
					d1 := to_digit (r1.item.item (r1i))
					d2 := to_digit (r2.item.item (r2i))
					if d1 < d2 then
						result := true
						r1i := r1.item.count + 1 -- stop looping
					elseif d1 > d2 then
						result := false
						r1i := r1.item.count + 1 -- stop looping
					end
					r1i := r1i + 1
					r2i := r2i + 1
				end
			end
		end

feature -- operations

	plus alias "+" (other: BIG_INTEGER): BIG_INTEGER
			-- adds current to `other'
		local
			res, empty: STRING
			carry, r1i, r2i, d1, d2, d: INTEGER
			ch: CHARACTER
			r1, r2: BIG_INTEGER
		do
			r1 := current.clone_me
			r2 := other.clone_me
			if r1.item.item (1) = '-' and r2.item.item (1) /= '-' then
				create result
				r1.negate
				result := (r2 - r1).clone_me
			elseif r1.item.item (1) /= '-' and r2.item.item (1) = '-' then
				create result
				r2.negate
				result := (r1 - r2).clone_me
			elseif r1.item.item (1) = '-' and r2.item.item (1) = '-' then
				create result
				r1.negate
				r2.negate
				result := (r1 + r2).clone_me
				result.negate
			else
				r1.align_decimal (r2)
				r1.align_whole (r2)
				empty := ""
				res := empty.twin
				from
					r1i := r1.item.count
					r2i := r2.item.count
				until
					r1i < 1 or r2i < 1
				loop
					ch := '0'
					if r1.item.item (r1i) /= '.' and r2.item.item (r2i) /= '.' then
						d1 := to_digit (r1.item.item (r1i))
						d2 := to_digit (r2.item.item (r2i))
						d := carry + d1 + d2
						if d >= 10 then
							carry := d // 10
							d := d - 10
						else
							carry := 0
						end
						ch := to_char (d)
					elseif r1.item.item (r1i) = '.' and r2.item.item (r2i) = '.' then
						ch := '.'
					end
					res.insert_character (ch, 1)
					r1i := r1i - 1
					r2i := r2i - 1
				end
				if carry > 0 then
					res.insert_character (to_char (carry), 1)
				end
				create result.make_from_string (res)
			end
		end

	minus alias "-" (other: BIG_INTEGER): BIG_INTEGER
			-- subtracts other from current and returns a new object
		local
			res, empty: STRING
			r1, r2: BIG_INTEGER
			r1i, r2i, d1, d2, dp, i, j: INTEGER
			ch: CHARACTER
		do
			r1 := current.clone_me
			r2 := other.clone_me
			if r1.item.item (1) = '-' and r2.item.item (1) /= '-' then
				create result
				r1.negate
				result := (r1 + r2).clone_me
				result.negate
			elseif r1.item.item (1) /= '-' and r2.item.item (1) = '-' then
				create result
				r2.negate
				result := (r1 + r2).clone_me
			elseif r1.item.item (1) = '-' and r2.item.item (1) = '-' then
				create result
				r2.negate
				result := (r1 + r2).clone_me
			else
					-- ensure r1 >= r2
				if r1 < r2 then
					result := (r2 - r1).clone_me
					result.negate
				else
					r1.align_decimal (r2)
					r1.align_whole (r2)
					empty := ""
					res := empty.twin
					from
						r1i := r1.item.count
						r2i := r2.item.count
					until
						r1i < 1 or r2i < 1
					loop
						ch := '0'
						if r1.item.item (r1i) /= '.' and r2.item.item (r2i) /= '.' then
							d1 := to_digit (r1.item.item (r1i))
							d2 := to_digit (r2.item.item (r2i))

								-- do we need to borrow?
							if d1 < d2 then
								from
									i := r1i - 1
								until
									i < 1
								loop
									if r1.item.item (i) /= '.' then
										dp := to_digit (r1.item.item (i))
										if dp > 0 then
											r1.item.put (to_char (dp - 1), i)
											from
												j := i + 1
											until
												j > r1i - 1
											loop
												if r1.item.item (j) /= '.' then
													r1.item.put (to_char (to_digit (r1.item.item (j)) + 9), j)
												end
												j := j + 1
											end
											d1 := d1 + 10
											i := 0 -- stop looping
										end
									end
									i := i - 1
								end
							end
							ch := to_char (d1 - d2)
						elseif r1.item.item (r1i) = '.' and r2.item.item (r2i) = '.' then
							ch := '.'
						end
						res.insert_character (ch, 1)
						r1i := r1i - 1
						r2i := r2i - 1
					end
					create result.make_from_string (res)
				end
			end
		end

	product alias "*" (other: BIG_INTEGER): BIG_INTEGER
			-- multiplies current by other and returns a new object
		local
			r1, r2, tr1, tr2, tr: BIG_INTEGER
			r1DotPos, r2DotPos, precision, r1i, r2i, carry, d1, d2, d, diff, i: INTEGER
			res, cRes, tmp, empty: STRING
		do
			r1 := current.clone_me
			r2 := other.clone_me
			if r1.item.item (1) = '-' and r2.item.item (1) /= '-' then
				create result
				r1.negate
				result := (r1 * r2).clone_me
				result.negate
			elseif r1.item.item (1) /= '-' and r2.item.item (1) = '-' then
				create result
				r2.negate
				result := (r1 * r2).clone_me
				result.negate
			elseif r1.item.item (1) = '-' and r2.item.item (1) = '-' then
				create result
				r1.negate
				r2.negate
				result := (r1 * r2).clone_me
			else
					-- remove decimal points, if any, and remember the sum of the number of digits after the decimal for both numbers
				r1DotPos := r1.item.index_of ('.', 1)
				r2DotPos := r2.item.index_of ('.', 1)
				precision := 0
				if r1DotPos > 0 then
					precision := precision + r1.item.count - r1DotPos
					r1.item.remove (r1DotPos)
				end
				if r2DotPos > 0 then
					precision := precision + r2.item.count - r2DotPos
					r2.item.remove (r2DotPos)
				end

					-- perform the actual multiplication
				empty := ""
				res := empty.twin
				from
					r2i := r2.item.count
				until
					r2i < 1
				loop
					cRes := empty.twin
					carry := 0
					from
						r1i := r1.item.count
					until
						r1i < 1
					loop
						d1 := to_digit (r1.item.item (r1i))
						d2 := to_digit (r2.item.item (r2i))
						d := carry + d1 * d2;
						if d >= 10 then
							carry := d // 10
							d := d \\ 10
						else
							carry := 0
						end
						cRes.insert_character (to_char (d), 1)
						r1i := r1i - 1
					end
					if carry > 0 then
						cRes.insert_character (to_char (carry), 1)
					end
					if res.count = 0 then
						res := cRes.twin
					else
						create tmp.make_filled ('0', r2.item.count - r2i)
						cRes.append (tmp)
						create tr1.make_from_string (cRes)
						create tr2.make_from_string (res)
						tr := tr1 + tr2
						res := tr.item.twin
					end
					r2i := r2i - 1
				end

					-- put back the decimal point
				if precision > 0 then
					if precision > res.count then
						diff := precision - res.count
						from
							i := 1
						until
							i > diff
						loop
							res.insert_character ('0', 1)
							i := i + 1
						end
					end
					res.insert_character ('.', res.count - precision + 1)
				end
				create result.make_from_string (res)
			end
		end

	square: BIG_INTEGER
		do
			Result := Current * Current
		end

	power alias "^" (other: INTEGER): BIG_INTEGER
		require
			other >= 0 -- TODO: maybe remove this and return a RATIONAL instead
		do
			if other = 0 then
				Result := one
			else
				Result := Current
				across
					1 |..| (other - 1) as i
				loop
					Result := Result * Current
				end
			end
		end

	numeric_quotient (other: BIG_INTEGER): BIG_INTEGER
			-- needed for inheritance from NUMERIC
			-- does not have a precondition
			-- use quotient instead
		do
			create Result.make_from_string (real_division (other).out) -- precise_out_to (0))
		end

	quotient  alias "//", divide (other: BIG_INTEGER): BIG_INTEGER
		require
			denominator_non_zero: other /~ zero
		do
			create Result.make_from_string (real_division (other).out) -- precise_out_to (0))
		end

	remainder alias "\\" (other: BIG_INTEGER): BIG_INTEGER
			-- Return the result of `Current' mod `other'
		do
				-- TODO: seems not to work properly with negative integers
			Result := Current - ((Current // other) * other)
		end

		--	mod (other: INT): INT
		--		local
		--			r: INT
		--		do
		--			r := Current \\ other
		--			if r < zero then
		--				Result := r + other
		--			else
		--				Result := r
		--			end
		--		end

	gcd (other: BIG_INTEGER): BIG_INTEGER
			-- Return the positive greatest common divisor of `Current' and `other'
		local
			a, b: BIG_INTEGER
		do
			a := absolute
			b := other.absolute
			if b ~ zero then
				Result := a
			elseif a ~ zero then
				Result := b
			elseif a > b then
				Result := b.gcd (a \\ b)
			else
				Result := gcd (b \\ a)
			end
		end

	opposite alias "-": BIG_INTEGER
			-- unary minus
		do
			create result.make_from_string (item)
			result.negate
		end

	identity alias "+": BIG_INTEGER
			-- unary plus
		do
			create result.make_from_string (item)
		end

	zero: BIG_INTEGER
			-- neutral element for "+" and "-"
		do
			create result.make_from_string ("0")
		end

	one: BIG_INTEGER
			-- neutral element for "*" and "/"
		do
			create result.make_from_string ("1")
		end

	divisible (other: BIG_INTEGER): BOOLEAN
			-- may current object be divided by `other'?
		do
			result := not other.is_equal (zero)
		end

	exponentiable (other: NUMERIC): BOOLEAN
			-- may current object be elevated to the power `other'?
		do
			result := false
		end

	is_natural: BOOLEAN
		do
			result := is_integer and current >= zero
		end

	is_natural1: BOOLEAN
		do
			result := is_integer and current >= one
		end

	is_integer: BOOLEAN
			-- Is string representation `item' an int?
		do
			result := item.index_of ('.', 1) = 0
		end

	negate
			-- negates the number
		local
			tmp: STRING
		do
			if item.item (1) = '-' then
				tmp := item.substring (2, item.count)
				item := tmp.twin
			else
				item.insert_character ('-', 1)
			end
		end

	absolute: BIG_INTEGER
		do
			if Current >= Current.zero then
				Result := Current.clone_me
			else
				Result := opposite.clone_me
			end
		ensure
			Result >= Result.zero
		end

feature -- Conversion

	as_integer64: INTEGER_64
			-- represent as a integer 64
		require
			out.is_integer_64
		do
			Result := out.to_integer_64
		end

feature -- printing

	out: STRING
		do
			Result := item.twin
		end

feature {BIG_INTEGER} -- private fields

	item: STRING
			-- string representation



	clone_me: BIG_INTEGER
		local
			l_s: STRING
		do
			create l_s.make_from_string (item)
			create Result.make_from_string (item.twin)
		end

feature {BIG_INTEGER} -- private methods

	item_fix: STRING
			-- Fix for negative zero
		do
			if item ~ "-0" then
				Result := "0"
			else
				Result := item
			end
		end

	is_valid_string (s: STRING): BOOLEAN
			-- check if the given string is of the correct format
		require
			non_void: s /= void
			non_empty: not s.is_empty
		local
			seenDot: BOOLEAN
			i: INTEGER
		do
				-- valid patterns are: [-]?[0-9]+.[0-9]+ or .[0-9]+ or [-]?[0-9]+

			seenDot := false
			result := true
			from
				i := 1
			until
				i > s.count
			loop
				if s.item (i) = '-' then
					if i > 1 then
						result := false
						i := s.count + 1 -- stop looping
					end
				elseif s.item (i) = '.' then
					if i = s.count or seenDot then
						result := false
						i := s.count + 1 -- stop looping
					end
					seenDot := true
				elseif not s.item (i).is_digit then
					result := false
					i := s.count + 1 -- stop looping
				end
				i := i + 1
			end
		end

	normalize
			-- standardizes the format of the number
		require
			non_empty: not item.is_empty
		local
			i, insPos, dotPos, firstNonZeroPos, lastNonZeroPos: INTEGER
			seenMinus, prependZero, hasDot: BOOLEAN
			whole, fraction, empty, tmp, zeroStr: STRING
		do
			empty := ""
			zeroStr := "0"
			seenMinus := false
			prependZero := false
			from
				i := 1
			until
				i > item.count
			loop
				if item.item (i) = '-' then
					seenMinus := true
				elseif item.item (i) = '.' then
					if i = 1 or seenMinus then
						prependZero := true
					end
				end
				i := i + 1
			end
			if prependZero then
				insPos := 1
				if seenMinus then
					insPos := 2
				end
				item.insert_character ('0', insPos)
			end
			if (seenMinus) then
				negate
			end
			dotPos := item.index_of ('.', 1)
			if dotPos = 0 then -- no '.' in the string
				hasDot := false
				whole := item.twin
				fraction := empty.twin
			else -- '.' exists in the string
				hasDot := true
				tmp := item.substring (1, dotPos - 1)
				whole := tmp.twin
				tmp := item.substring (dotPos + 1, item.count)
				fraction := tmp.twin
			end
			if not whole.is_empty then
				firstNonZeroPos := whole.count + 1
				from
					i := 1
				until
					i > whole.count
				loop
					if whole.item (i) /= '0' then
						firstNonZeroPos := i
						i := whole.count + 1 -- stop looping
					end
					i := i + 1
				end
				if firstNonZeroPos = whole.count + 1 then
					whole := zeroStr.twin
				else
					tmp := whole.substring (firstNonZeroPos, whole.count)
					whole := tmp.twin
				end
			end
			if not fraction.is_empty then
				lastNonZeroPos := -1
				from
					i := fraction.count
				until
					i < 1
				loop
					if fraction.item (i) /= '0' then
						lastNonZeroPos := i
						i := 0 -- stop looping
					end
					i := i - 1
				end
				if lastNonZeroPos = -1 then
					fraction := empty.twin
				else
					tmp := fraction.substring (1, lastNonZeroPos)
					fraction := tmp.twin
				end
			end
			item := whole.twin
			if hasDot and not fraction.is_empty then
				item.append (".")
				item.append (fraction)
			end
			if seenMinus and not item.is_equal ("0") then
				item.insert_character ('-', 1)
			end
		end

	to_digit (ch: CHARACTER): INTEGER
			-- converts a character to a digit
		local
			chZero: CHARACTER
		do
			chZero := '0'
			result := ch.code - chZero.code
		end

	to_char (d: INTEGER_64): CHARACTER
			-- converts a digit to a character
		local
			chZero: CHARACTER
		do
			chZero := '0'
			result := (chZero.code + d).to_character_8
		end

	align_decimal (other: BIG_INTEGER)
			-- used to align the fractional parts of the given parameters
		local
			myDotPos, otherDotPos, myPrec, otherPrec, numToPad, i: INTEGER
			pad: detachable STRING
		do
			myDotPos := item.index_of ('.', 1)
			otherDotPos := other.item.index_of ('.', 1)
			if myDotPos /= 0 and otherDotPos /= 0 then
				myPrec := item.count - myDotPos
				otherPrec := other.item.count - otherDotPos
				if myPrec /= otherPrec then
					pad := void
					if myPrec < otherPrec then
						pad := item
					else
						pad := other.item
					end
					numToPad := (myPrec - otherPrec).abs
					from
						i := 1
					until
						i > numToPad
					loop
						pad.append_character ('0')
						i := i + 1
					end
				end
			elseif myDotPos /= 0 or otherDotPos /= 0 then
				if myDotPos /= 0 then
					myPrec := item.count - myDotPos
				else
					myPrec := 0
				end
				if otherDotPos /= 0 then
					otherPrec := other.item.count - otherDotPos
				else
					otherPrec := 0
				end
				pad := void
				if myPrec < otherPrec then
					pad := item
				else
					pad := other.item
				end
				numToPad := (myPrec - otherPrec).abs
				pad.append_character ('.')
				from
					i := 1
				until
					i > numToPad
				loop
					pad.append_character ('0')
					i := i + 1
				end
			end
		end

	align_whole (other: BIG_INTEGER)
			-- used to align the integer parts of the given parameters
		local
			myDotPos, otherDotPos, myWholeLength, otherWholeLength, meNegOffset, otherNegOffset, insPos, numToPad, i: INTEGER
			meNeg, otherNeg: BOOLEAN
			pad: detachable STRING
		do
			myDotPos := item.index_of ('.', 1)
			otherDotPos := other.item.index_of ('.', 1)
			meNeg := item.item (1) = '-'
			otherNeg := other.item.item (1) = '-'
			if myDotPos /= 0 then
				if meNeg then
					meNegOffset := 1
				else
					meNegOffset := 0
				end
				myWholeLength := myDotPos - meNegOffset - 1
			else
				myWholeLength := item.count
			end
			if otherDotPos /= 0 then
				if otherNeg then
					otherNegOffset := 1
				else
					otherNegOffset := 0
				end
				otherWholeLength := otherDotPos - otherNegOffset - 1
			else
				otherWholeLength := other.item.count
			end
			if myWholeLength /= otherWholeLength then
				pad := void
				if myWholeLength < otherWholeLength then
					pad := item
				else
					pad := other.item
				end
				insPos := 1
				if pad.item (1) = '-' then
					insPos := insPos + 1
				end
				numToPad := (myWholeLength - otherWholeLength).abs
				from
					i := 1
				until
					i > numToPad
				loop
					pad.insert_character ('0', insPos)
					i := i + 1
				end
			end
		end

		--	quotient_div alias "/", divide (other: INT): INT

feature {RATIONAL}
	default_precision: INTEGER = 0
			-- inherited from VALUE

	real_division (other: BIG_INTEGER): BIG_INTEGER
			-- divides current by other and returns a new object
			-- from VALUE
		local
			r1, r2, tr, diff, x, sum, prod: BIG_INTEGER
			r1DotPos, r2DotPos, r1Precision, r2Precision, r1NumTrailingZeros, r2NumTrailingZeros, scaleFactor, i, startPos, r1i, d: INTEGER
			s, res, empty: STRING
			pad: detachable STRING
			stopLoop: BOOLEAN
			ch: CHARACTER
			final: STRING
		do
			r1 := current.clone_me
			r2 := other.clone_me
			if r1.is_equal (zero) then
				result := zero
			elseif r1.item.item (1) = '-' and r2.item.item (1) /= '-' then
				create result
				r1.negate
				result := (r1 // r2).clone_me
				result.negate
			elseif r1.item.item (1) /= '-' and r2.item.item (1) = '-' then
				create result
				r2.negate
				result := (r1 // r2).clone_me
				result.negate
			elseif r1.item.item (1) = '-' and r2.item.item (1) = '-' then
				create result
				r1.negate
				r2.negate
				result := (r1 // r2).clone_me
			else
					-- remove decimal points by scaling both r1 and r2
				r1DotPos := r1.item.index_of ('.', 1)
				r2DotPos := r2.item.index_of ('.', 1)
				r1Precision := 0
				r2Precision := 0
				if r1DotPos > 0 then
					r1Precision := r1.item.count - r1DotPos;
					r1.item.remove (r1DotPos)
					r1.normalize
				end
				if r2DotPos > 0 then
					r2Precision := r2.item.count - r2DotPos;
					r2.item.remove (r2DotPos)
					r2.normalize
				end
				pad := void
				if r1Precision > r2Precision then
					pad := r2.item
				elseif r2Precision > r1Precision then
					pad := r1.item
				end
				if pad /= void then
					create s.make_filled ('0', (r1Precision - r2Precision).abs)
					pad.append (s)
				end

					-- adjust r1 to produce the required precision, if necessary
				r1NumTrailingZeros := 0
				r2NumTrailingZeros := 0
				scaleFactor := 0
				from
					i := r1.item.count
				until
					i < 1
				loop
					if r1.item.item (i) = '0' then
						r1NumTrailingZeros := r1NumTrailingZeros + 1
					else
						i := 0 -- stop looping
					end
					i := i - 1
				end
				from
					i := r2.item.count
				until
					i < 1
				loop
					if r2.item.item (i) = '0' then
						r2NumTrailingZeros := r2NumTrailingZeros + 1
					else
						i := 0 -- stop looping
					end
					i := i - 1
				end
				if r1NumTrailingZeros < r2NumTrailingZeros then
					create s.make_filled ('0', r2NumTrailingZeros - r1NumTrailingZeros)
					r1.item.append (s)
					scaleFactor := scaleFactor + r2NumTrailingZeros - r1NumTrailingZeros
					r1NumTrailingZeros := r2NumTrailingZeros
				end
				if r1NumTrailingZeros - r2NumTrailingZeros < default_precision + 1 then
					scaleFactor := scaleFactor + default_precision + 1 - (r1NumTrailingZeros - r2NumTrailingZeros);
					create s.make_filled ('0', default_precision + 1 - (r1NumTrailingZeros - r2NumTrailingZeros))
					r1.item.append (s)
				end

					-- ensure r1 >= r2; if this is not the case, multiply r1 by a sufficient power of 10, and then at the end divide by the same power
				if r1 < r2 then
					scaleFactor := scaleFactor + r2.item.count - r1.item.count + 1;
					create s.make_filled ('0', r2.item.count - r1.item.count + 1)
					r1.item.append (s)
				end
				if r1.item.count - r2.item.count < default_precision then
					scaleFactor := scaleFactor + default_precision - (r1.item.count - r2.item.count)
					create s.make_filled ('0', default_precision - (r1.item.count - r2.item.count))
					r1.item.append (s)
				end

					-- perform actual division (long division)
				startPos := r2.item.count + 1
				if r1.item.count > r2.item.count then
					from
						stopLoop := false
					until
						startPos > r1.item.count or stopLoop
					loop
						s := r1.item.substring (1, startPos - 1)
						create tr.make_from_string (s)
						if tr >= r2 then
							stopLoop := true
						else
							startPos := startPos + 1
						end
					end
				end
				empty := ""
				res := empty.twin
				create diff
				from
					r1i := startPos - 1
				until
					r1i > r1.item.count
				loop
					if r1i = startPos - 1 then
						create x.make_from_string (r1.item.substring (1, r1i))
					else
						diff.item.insert_character (r1.item.item (r1i), diff.item.count + 1)
						create x
						x := diff.clone_me
					end
					d := 0
					create sum
					from
						stopLoop := false
					until
						stopLoop
					loop -- executes at most 9 times
						sum := sum + r2
						if sum > x then
							stopLoop := true
						else
							d := d + 1
						end
					end
					ch := to_char (d)
					res.insert_character (ch, res.count + 1)
					create prod
					create s.make_filled (ch, 1)
					create tr.make_from_string (s)
					prod := tr * r2
					diff := x - prod
					r1i := r1i + 1
				end

					-- put back the decimal point
				if scaleFactor > 0 then
					if scaleFactor > res.count then
						create s.make_filled ('0', scaleFactor - res.count)
						res.insert_string (s, 1)
					end
					res.insert_character ('.', res.count - scaleFactor + 1)
				end

					--				create result.make_value_from_string (res)

					-- jso addition
					--				if res.tail (2)[1] ~ '.' then
					--					 final := res.head (res.count - 2)
					--				elseif res.tail (1)[1] ~ '.' then
					--					final := res.head (res.count - 1)
					--				else
					--					final := res
					--				end

				final := res.split ('.') [1]
				If final.is_empty then
					final := "0"
				end
				create result.make_from_string (final)
			end
		end


invariant
	default_precision = 0
	is_integer

note
	copyright: "Copyright (c) SEL, York University"
	license:   "MIT"
	todo: "[
			integer division \\ is veru ineficient. Fpr js algorithm see:
			www.javascripter.net/math/calculators/100digitbigintcalculator.htm
			and {TEST_INT_JSO}t51.
			To generate large random numbers:
			python3
			import random
			random.getrandbits(128) -- 128 bits
]"
end


