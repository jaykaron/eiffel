note
	description: "Summary description for {DECIMAL_WRAPPER}."
	author: "JSO and DC"
	date: "$Date$"
	revision: "$Revision$"

class
	DECIMAL

inherit

	COMPARABLE
		redefine
			is_equal,
			default_create,
			out
		end

	NUMERIC
		redefine
			is_equal,
			default_create,
			out
		end

create
	make_from_string,
	make_from_decimal,
	make_from_int,
	default_create,
	make_from_string_ctx,
	make_with_precision

convert
	make_from_string ({STRING}),
	as_double: {REAL_64}

feature {DECIMAL} -- private fields

	item: STRING

	default_precision: INTEGER = 36
		-- the minimum accuracy of division results;
		-- division results will be accurate to AT LEAST this many digits.

	default_rounding: INTEGER = 4
		-- Use half-round-up rounding

	epsilon: STRING = "0.000000000000001"
		-- for root computation

	decimal_char: CHARACTER = '.'

	exponent_char: CHARACTER = 'E'

	ma_decimal_ctx: MA_DECIMAL_CONTEXT

	ma_decimal: MA_DECIMAL

	make_from_decimal (decimal: MA_DECIMAL)
			-- create DECIMAL_WRAPPER from MA_DECIMAL
		do
			create ma_decimal.make_copy (decimal)
			ma_decimal_ctx := ma_decimal.shared_decimal_context
			item := decimal_2_value_string
		end

	decimal_ctx_for_value: MA_DECIMAL_CONTEXT
			-- create MA_DECIMAL_CONTEXT configured according to VALUE
		do
			create result.make (default_precision, default_rounding)
		end

	decimal_setup (s: STRING; dv: INTEGER): MA_DECIMAL
			-- create new MA_DECIMAL object from value "s" with precision "dv"
		require
			non_void: s /= void
			non_empty: not s.is_empty
			has_correct_format: ensureValid (s)
		do
			ma_decimal_ctx := decimal_ctx_for_value
			ma_decimal_ctx.set_digits (dv)
			create result.make_from_string_ctx (s, ma_decimal_ctx)
			result.set_shared_decimal_context (ma_decimal_ctx) -- This seems dangerous
		end

	clone_me: DECIMAL
		local
			l_s: STRING
		do
			create l_s.make_from_string (item)
			create result.make_from_decimal (ma_decimal)
		end

	decimal_2_value_string: STRING
			-- converts scientific_notation to value.precise_out
			-- *should be deprecated once MA_DECIMAL allows precise string representation
		local
			str_list: LIST [STRING]
			coefficient_list: LIST [STRING]
			decimal_left: STRING
			decimal_right: STRING
			coefficients: STRING
			zero_pad: STRING
			l_exponent: STRING
			int_exponent: INTEGER
			decimal_count: INTEGER
			index: INTEGER
		do
			if ma_decimal.is_zero then
				result := "0"
			else
				str_list := ma_decimal.to_scientific_string.split (exponent_char)
				coefficients := str_list [1]
				create result.make_empty
				if str_list.count > 1 then
					l_exponent := str_list [2]
					int_exponent := l_exponent.to_integer
					coefficient_list := coefficients.split (decimal_char)
					if coefficient_list.count > 1 then
						decimal_count := coefficient_list [2].count
					else
						decimal_count := 0
					end
					if int_exponent.abs >= decimal_count then
						result.append (coefficient_list [1])
						if decimal_count > 0 then
							result.append (coefficient_list [2])
						end
						create zero_pad.make_empty
						if int_exponent > 0 then
							zero_pad.make_filled ('0', int_exponent - decimal_count)
							result.append (zero_pad)
						else
							zero_pad.make_filled ('0', int_exponent.abs - 1)
							result.prepend (zero_pad)
							result.prepend ("0.")
						end
					else
						if int_exponent = 0 then
							result := coefficients
						else
							decimal_left := coefficient_list [2].substring (1, int_exponent)
							decimal_right := coefficient_list [2].substring (int_exponent, decimal_count)
							result.append (coefficient_list [1])
							result.append (decimal_left)
							result.append (create {STRING}.make_filled (decimal_char, 1))
							result.append (decimal_right)
						end
					end
				else
					coefficient_list := coefficients.split (decimal_char) -- to_scientific_string from MA_DECIMAL is not always accurate
					if coefficient_list.count > 1 and then zero.is_equal (create {DECIMAL}.make_from_string (coefficient_list [2])) then
						result := coefficient_list [1]
					else
						result := coefficients
					end
				end
				if result.has (decimal_char) then -- remove unnecessary zeros at the end (if decimal exists)
					from
						index := result.count
					until
						not (result.at (index) ~ '0')
					loop
						index := index - 1
						result := result.substring (1, index)
					end
				end
			end
		end

	value_precise_out: STRING
			-- Precise string representation of object
		do
			result := item.twin
		end

	value_out: STRING
			-- String representation of object upto 2 decimal places
		do
			result := precise_out_to (2)
		end

	ensureValid (s: STRING): BOOLEAN
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
				elseif s.item (i) = decimal_char then
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

	integer_exp (val: DECIMAL; power: INTEGER): DECIMAL
		-- recursively calculate 'val' to positive integer power 'power'
		-- Fast exponentiation
		local
			square: DECIMAL
		do
			if power = 0 then
				result := "1"
			else
				square := val * val
				result := integer_exp(square, power // 2)
				if power \\ 2 = 1 then
					result := result * val
				end
			end
		end

	real_exp (val: DECIMAL; power: DECIMAL): DECIMAL
		-- recursively calculate 'val' to real power 'power'
		-- Fast exponentiation until power < 1. Then binary search on fractional exponent
		local
			temp: DECIMAL
			low: DECIMAL
			high: DECIMAL
			mid: DECIMAL
			l_root: DECIMAL
			acc: DECIMAL
			two: DECIMAL
		do
			two := create {DECIMAL}.make_from_string("2.0")
			if power >= one then
				temp := real_exp (val, power / two)
				result := temp * temp
			else
				from
					low := zero
					high := one
					l_root := val.root
					acc := l_root
					mid := high / two;
				until
					((mid - power).absolute <= epsilon)
				loop
					l_root := l_root.root
					if mid <= power then
						low := mid
						acc := acc * l_root
					else
						high := mid
						acc := acc * (one / l_root)
					end
					mid := (low + high) / two
				end
				result := acc
			end
		end

feature {NONE} -- constructors

	make_from_string_ctx (value_string: STRING; ctx: MA_DECIMAL_CONTEXT)
			-- Make a new decimal from `value_string' relative to `ctx'
		do
			create ma_decimal.make_from_string_ctx (value_string, ctx)
			ma_decimal_ctx := ctx
			item := decimal_2_value_string
		end

		make_with_precision (a_value: STRING; a_precision: INTEGER)
				-- Make a new decimal from `a_value' with `a_precision
			local

--				l_ma_decimal: MA_DECIMAL
				l_ma_decimal_ctx: MA_DECIMAL_CONTEXT
			do
				create l_ma_decimal_ctx.make (a_precision, 4)
					-- rounding 4
				create ma_decimal.make_from_string_ctx (a_value, l_ma_decimal_ctx)
				ma_decimal_ctx := l_ma_decimal_ctx
				item := decimal_2_value_string
			end

	default_create
			-- create an empty object (it's equivalent to 0)
		local
			empty: STRING
		do
			empty := "0"
			item := empty.twin
			ma_decimal := decimal_setup (item, default_precision + 1)
		ensure then
			item.is_equal ("0")
		end

	make_from_string (s: STRING)
			-- create an object from string 's'
		require
			non_void: s /= void
			non_empty: not s.is_empty
			has_correct_format: ensureValid (s)
		local
			precision: INTEGER
			value: LIST [STRING]
		do
			value := s.split (exponent_char)
			precision := value [1].count
			if precision < (default_precision + value [1].split (decimal_char) [1].count) then
				precision := default_precision + value [1].split (decimal_char) [1].count
			end
			ma_decimal := decimal_setup (s.twin, precision)
			item := decimal_2_value_string
		end

	make_from_int (int: INTEGER)
			-- create a MONEY_VALUE object from integer `m'
		do
			item := int.out
			ma_decimal_ctx := decimal_ctx_for_value
			ma_decimal_ctx.set_digits (item.count + default_precision)
			create ma_decimal.make_from_integer (int)
				--		ma_decimal.set_shared_decimal_context (ma_decimal_ctx)	-- this seems dangerous
		end

feature -- comparison

	is_equal (other: DECIMAL): BOOLEAN
			-- check whether other is equal to current or not
		do
			Result := ma_decimal.is_equal (other.ma_decimal)
		end

	is_less alias "<" (other: DECIMAL): BOOLEAN
			-- whether current is less than other
		do
			Result := ma_decimal < other.ma_decimal
		end

feature -- operations

	zero: DECIMAL
			-- neutral element for "+" and "-"
		do
			create result.make_from_string ("0")
		end

	one: DECIMAL
			-- neutral element for "*" and "/"
		do
			create result.make_from_string ("1")
		end

	divisible (other: DECIMAL): BOOLEAN
			-- may current object be divided by `other'?
		do
			result := not other.is_equal (zero)
		end

	exponentiable (other: DECIMAL): BOOLEAN
			-- may current object be elevated to the power `other'?
		do
			result := true
		end

	plus alias "+", add (other: DECIMAL): DECIMAL
			-- adds current to other and returns a new object
		local
			l_decimal: MA_DECIMAL
		do
			l_decimal := current.ma_decimal + other.ma_decimal
			create result.make_from_decimal (l_decimal)
		end

	minus alias "-", subtract (other: DECIMAL): DECIMAL
			-- subtracts other from current and returns a new object
		local
			l_decimal: MA_DECIMAL
		do
			l_decimal := current.ma_decimal - other.ma_decimal
			create result.make_from_decimal (l_decimal)
		end

	product alias "*", multiply (other: DECIMAL): DECIMAL
			-- multiplies current by other and returns a new object
		local
			l_decimal: MA_DECIMAL
		do
			l_decimal := current.ma_decimal * other.ma_decimal
			create result.make_from_decimal (l_decimal)
		end

	quotient alias "/", divide (other: DECIMAL): DECIMAL
			-- divides current by other and returns a new object
		local
			l_decimal: MA_DECIMAL
		do
			l_decimal := current.ma_decimal / other.ma_decimal
			create result.make_from_decimal (l_decimal)
		end

	divided_by alias "|/" (other: DECIMAL): DECIMAL
			-- divides current by `other' and returns a new object
			-- cannot divide by zer0, whereas `/' allows it
		require
			other /~ zero
		local
			l_decimal: MA_DECIMAL
		do
--			l_decimal := current.ma_decimal / other.ma_decimal
--			create result.make_from_decimal (l_decimal)
--			l_decimal := divide (other: like Current; ma_decimal_ctx)
			l_decimal := ma_divided_by(ma_decimal,other.ma_decimal)
			create Result.make_from_decimal (l_decimal)
		end

	ma_divided_by(x,y: MA_DECIMAL): MA_DECIMAL
		do
			Result := x.divide (y, ma_decimal_ctx)
		end

	opposite alias "-": DECIMAL
			-- unary minus
		do
			create result.make_from_decimal (ma_decimal.opposite)
		end

	identity alias "+": DECIMAL
			-- unary plus
		do
			create result.make_from_decimal (ma_decimal)
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
		do
			result := ma_decimal.is_integer
		end

	is_negative: BOOLEAN
		do
			result := ma_decimal.is_negative
		end

	root: DECIMAL
		-- calculates square root for this instance
		require
			non_negative: not is_negative
		local
			l_epsilon: DECIMAL
			l_root: DECIMAL
		do
			l_epsilon := epsilon
			from
				l_root := clone_me
			until
				((l_root - (current / l_root)).absolute <= epsilon * l_root)
			loop
				l_root := ((current / l_root) + l_root) / create {DECIMAL}.make_from_string("2.0")
			end
			result := l_root
		end

	exp alias "^", exponent(power: DECIMAL): DECIMAL
		-- calculates the value of current instance raised to 'power'
		require
			is_exponentiable: exponentiable(power)
		do
			if power.is_integer then	-- use either real_exp or integer_exp
				result := integer_exp (current, power.ma_decimal.to_integer.abs)
			else
				result := real_exp (current, power.absolute)
			end
			if power.is_negative then
				result := one / result
			end
		end

	set_precision (precision: INTEGER)	-- this may not work as expected
		require
			precision_positive: precision > 0
		local
			l_decimal_ctx: MA_DECIMAL_CONTEXT
		do
			create l_decimal_ctx.make (precision, ma_decimal_ctx.rounding_mode)
			ma_decimal.set_shared_decimal_context (l_decimal_ctx)
		end

	reset_precision	-- this may not work as expected
		local
			l_decimal_ctx: MA_DECIMAL_CONTEXT
		do
			create l_decimal_ctx.make (default_precision, ma_decimal_ctx.rounding_mode)
			ma_decimal.set_shared_decimal_context (l_decimal_ctx)
		end

feature -- conversion

	as_double: REAL_64
			-- represent as a DOUBLE
		do
			result := ma_decimal.to_double
		end

feature -- printing

	out: STRING
			-- return a representation of the number rounded to two decimal places
		do
			result := value_out
		end

	precise_out: STRING
			-- return precise representation of the number
		do
			result := value_precise_out
		end

feature -- rouding

	round_to (digits: INTEGER): DECIMAL
			-- rounds the current VALUE_IMP to 'digits'
			-- Uses default stragegy as set in ma_decimal_ctx
		require
			digits >= 0
		local
			l_decimal_ctx: MA_DECIMAL_CONTEXT
			decimal_left: INTEGER
		do
			decimal_left := value_precise_out.split (decimal_char) [1].count
			if is_negative then
				decimal_left := decimal_left - 1
			end
			create l_decimal_ctx.make (decimal_left + digits, ma_decimal_ctx.rounding_mode)
			create result.make_from_decimal (create {MA_DECIMAL}.make_from_string_ctx (item, l_decimal_ctx))
		end

	precise_out_to (digits: INTEGER): STRING
			-- returns the precise string representation to 'digits'
		require
			digits >= 0
		local
			digit_list: LIST [STRING]
			decimal_left: STRING
			decimal_right: STRING
			l_decimal: DECIMAL
			zero_pad: STRING
		do
			create result.make_empty
			l_decimal := round_to (digits)
			digit_list := l_decimal.precise_out.split (decimal_char)
			decimal_left := digit_list [1]
			result.append (decimal_left)
			result.append (create {STRING}.make_filled (decimal_char, 1))
			if digit_list.count > 1 then
				decimal_right := digit_list [2]
				if decimal_right.count < digits then
					create zero_pad.make_filled ('0', digits - decimal_right.count)
					result.append (decimal_right)
					result.append (zero_pad)
				else
					result.append (decimal_right.substring (1, digits))
				end
			else
				create zero_pad.make_filled ('0', digits)
				result.append (zero_pad)
			end
		end

	round (digits: INTEGER)
			-- rounds this instance to the specified number of digits
		require
			digits >= 0
		local
			l_decimal_ctx: MA_DECIMAL_CONTEXT
			decimal_left: INTEGER
		do
			decimal_left := value_precise_out.split (decimal_char) [1].count
			if is_negative then
				decimal_left := decimal_left - 1
			end
			create l_decimal_ctx.make (decimal_left + digits, ma_decimal_ctx.rounding_mode)
			current.make_from_decimal (create {MA_DECIMAL}.make_from_string_ctx (item, l_decimal_ctx))
		end

	negate
			-- negates a number
		local
			l_decimal: MA_DECIMAL
		do
			l_decimal := ma_decimal.opposite
			current.make_from_decimal (l_decimal)
		end

	absolute: DECIMAL
		do
			create result.make_from_decimal (ma_decimal.abs)
		end

invariant
	consistent_rounding: default_rounding = {MA_DECIMAL_CONTEXT}.round_half_up

end
