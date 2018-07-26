note
	description: "A class for big rationals, using INT (big integers)."
	author: "JSO and AB"
	date: "$Date$"
	revision: "$Revision$"

class
	RATIONAL

inherit
	ANY
		undefine
			is_equal
		redefine
			out
		end

	COMPARABLE
		undefine
			out
		redefine
			is_equal, is_less
		end

	NUMERIC
		undefine
			is_equal, out
		end

create
	make, make_from_ints, make_from_string

convert
	make_from_string ({STRING})

feature {RATIONAL} -- Internal attributes

	p, q: BIG_INTEGER -- numerator and denominator

feature {NONE} -- Initialization

	make (a_p, a_q: INTEGER_64)
			-- Initialization for `Current'.
		require
			a_p /= 0 or a_q /= 0
		do
			create p.make_from_integer (a_p)
			create q.make_from_integer (a_q)
			canonicalize
		end

	make_from_ints (a_p, a_q: BIG_INTEGER)
		require
			a_p /~ a_p.zero or a_q /~ a_q.zero
		do
			p := a_p
			q := a_q
			canonicalize
		end

	make_from_string (s: STRING)
		require
			has_correct_format: string_is_rational (s)
		local
			p_q: like get_p_q
			i: INTEGER -- index of '.'
			p_, q_: STRING
		do
			if string_is_fraction (s) then
				p_q := get_p_q (s)
				make_from_ints (p_q.a_p, p_q.a_q)
			else
				check string_is_float (s) end

				i := s.index_of ('.', 1) -- index of '.'

				create p_.make_from_string (s)
				p_.remove (i)
				check p_.index_of ('.', 1) = 0 end

				q_ := "1"
				across
					1 |..| (s.count - i) as i_
				loop
					q_.append_character ('0')
				end

				make_from_ints (p_, q_)
			end
		end

feature -- Operations

	product alias "*", multiply (other: like Current): like Current
			-- Return the result of multiplying `Current' by `other'
		do
			create Result.make_from_ints (p * other.p, q * other.q)
		end

	plus alias "+", add (other: like Current): like Current
			-- Return the result of adding `Current' to `other'
		do
			create Result.make_from_ints ((p * other.q) + (q * other.p), q * other.q)
		end

	opposite alias "-", negate: like Current
		do
			create Result.make_from_ints (-p, q)
		end

	minus alias "-", subtract (other: like Current): like Current
		do
			Result := Current + (-other)
		end

	reciprocal: like Current
			-- Return 1 / `Current'
		do
			create Result.make_from_ints (q, p)
		end

	quotient alias "/", divide alias "//" (other: like Current): like Current
			-- Return the result of dividing `Curent' by `other'
		do
			Result := Current * other.reciprocal
		end

	one: like Current
			-- Neutral element for "*" and "/"
		do
			create Result.make (1, 1)
		end

	zero: like Current
			-- Neutral element for "+" and "-"
		do
			create Result.make (0, 1)
		end

	identity alias "+": like Current
			-- Unary plus
		do
			create Result.make_from_ints (p, q)
		end

	abs, absolute: like Current
			-- Absolute value of `Current'
		do
			if Current >= zero then
				Result := identity
			else
				Result := opposite
			end
		end

	square: RATIONAL
		do
			Result := Current * Current
		end

	power alias "^" (other: INTEGER): RATIONAL
		do
			if other = 0 then
				Result := one
			else

				Result := Current
				across
					1 |..| (other.abs - 1) as i
				loop
					Result := Result * Current
				end

				if other < 0 then
					Result := Result.reciprocal
				end
			end
		end

feature -- rounding
	v_divide (other: BIG_INTEGER): VALUE
		local
			v1, v2: VALUE
		do
			create v1.make_from_string (p)
			create v2.make_from_string (other.out)
			Result := (v1 / v2)
		end

	real_divide_round_to (other: BIG_INTEGER; digits: INTEGER): STRING
		do
			Result := v_divide (other).round_to (digits).precise_out
		end



	round_to (digits: INTEGER): STRING
		do
--			Result := p.real_divide_round_to (q, digits)
			Result := real_divide_round_to(q, digits)
		end

	as_real: REAL_64
		require
			is_valid_real_64
		do
			Result := p.real_division (q).out.to_real_64
		end

feature -- Queries

	out: STRING
		do
			if q ~ q.one then
				Result := p.out
			else
				Result := p.out + "/" + q.out
			end
		end

	is_canonical: BOOLEAN
		do
			Result := p.gcd (q) ~ p.one
		end

	is_equal (other: like Current): BOOLEAN
			-- Is `other' value equal to current
		do
			Result := p * other.q ~ q * other.p
		end

	is_less alias "<" (other: like Current): BOOLEAN
			-- Is current object less than `other'?
		do
			Result := p * other.q < q * other.p
		end

	divisible (other: like Current): BOOLEAN
			-- May current object be divided by `other'?
		do
			Result := True
		end

	exponentiable (other: NUMERIC): BOOLEAN
			-- May current object be elevated to the power `other'?
		do
			Result := False
		end

	int_zero: BIG_INTEGER
		do
			Result := "0"
		end

	string_is_fraction (s: STRING): BOOLEAN
			-- Does `s' represent a valid and well-defined fraction?
			-- It must contain at most one '/', which separates the numerator
			-- from the denominator (no whitespace allowed). Also, either
			-- the numerator or denominator must be non-zero. Further, if '/'
			-- is present, what comes before and after it must be valid INTs.
			-- If `s' doesn't contain a '/', a denominator of 1 is assumed.
		local
			i: INTEGER -- index of '/'
			p_s, q_s: STRING
			i1, i2: BIG_INTEGER
		do
			i := s.index_of ('/', 1)
			i1 := "0"

			if i > 0 then
				if s.last_index_of ('/', s.count) = i and then s.count >= 3 then
					p_s := s.substring (1, i - 1)
					q_s := s.substring (i + 1, s.count)
					if i1.is_string_int (p_s) and i1.is_string_int (q_s) then
						i1 := p_s
						i2 := q_s

						Result := not (i1 ~ i1.zero and i2 ~ i2.zero)
					end
				end
			else
				Result := (not s.is_empty) and then i1.is_string_int (s)
			end
			if i2 ~ int_zero then
				Result := False
			end
		end

	string_is_float (s: STRING): BOOLEAN
			-- Does `s' represent a valid and well-defined decimal number
			-- with potentially a floating point? This function was copied
			-- from `{INT}.ensureValid', which came from mathmodels' VALUE.
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

	string_is_rational (s: STRING): BOOLEAN
			-- Doe `s' represent a fraction or a decimal with a floating
			-- point?
		do
			Result := string_is_fraction (s) or else string_is_float (s)
		end

	is_valid_real_64: BOOLEAN
		do
			Result := p.out.is_integer_64 and then
					q.out.is_integer_64 and then
					p.real_division (q).out.is_integer_64
		end

feature -- Internal queries

	get_p_q (s: STRING): TUPLE [a_p, a_q: like s]
			-- Returns the numerator and denominator parsed from `s'.
		require
			string_is_rational (s)
		local
			i: INTEGER -- index of '/'
		do
			i := s.index_of ('/', 1)
			create Result

			if i > 0 then
				Result.a_p := s.substring (1, i - 1)
				Result.a_q := s.substring (i + 1, s.count)
			else
				Result.a_p := s
				Result.a_q := "1"
			end
		end

feature -- Commands

	canonicalize
			-- Canonicalize the current rational by dividing its numerator
			-- and denominator by their GCD.
		local
			g: BIG_INTEGER
		do
			g := p.gcd (q)
			p := p.divide (g)
			q := q.divide (g)
		end

invariant
	well_defined: not (p ~ p.zero and q ~ q.zero)
end
