note
	description: "Summary description for {TESTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DECIMAL_TEST1
inherit
	ES_TEST

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			add_boolean_case (agent t0)
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
--			add_boolean_case (agent test1)
--			add_boolean_case (agent test2)
		end

feature -- tests
	t0: BOOLEAN
		local
			ma_decimal1: DECIMAL
			ma_decimal2: DECIMAL
			ma_result: DECIMAL

			value1: VALUE
			value2: VALUE
			val_result: VALUE
		do
			comment("t0: First test to default precision 36")
			create ma_decimal1.make_from_string("22");
			create ma_decimal2.make_from_string("7");
			ma_result := ma_decimal1 / ma_decimal2;
			Result := ma_result ~ "3.142857142857142857142857142857142857"
			-- "3.1428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428571428"
			check Result end
			value1 := "22";
			value2 := "7";
			val_result := value1/value2;
			Result := val_result.precise_out ~ ma_result
			check Result end
		end

	pi100: STRING = "3.142857142857142857142857142857142857142857142857142857142857142857142857142857142857142857142857143"
		-- the 100th digit after the pointv is 8, hence round to 3
	t1: BOOLEAN
		local
			d1: DECIMAL
			d2: DECIMAL
			rd: DECIMAL
			pi: DECIMAL
			d1c: MA_DECIMAL_CONTEXT
		do
			comment("t1: test to  precision 100")
			create d1.make_from_string("22");
			create d2.make_from_string("7");
			rd := d1 / d2;
			Result := rd ~ "3.142857142857142857142857142857142857"
			check Result end
			-- change context
			create d1c.make (100, 4)  -- precision 100, rounding 4
			create d1.make_from_string_ctx ("22", d1c)
			create d2.make_from_string_ctx ("7", d1c)
			pi := pi100
			rd := d1 // d2  -- proper division

			Result := rd ~ pi
			check Result end
		end

	t2: BOOLEAN
		local
			d1, d2, r, pi: DECIMAL
		do
			comment("t2: test to  precision 100")
			create d1.make_with_precision ("22", 100)
			create d2.make_with_precision ("7", 100)
			pi := pi100
			r := d1 // d2  -- proper division
			Result := r ~ pi
			check Result end
		end

	test: BOOLEAN
		local
			str: STRING
--			int: INTEGER
			dec1: DECIMAL
			dec2: DECIMAL
			dec3: DECIMAL
			dec4: DECIMAL
			val: VALUE
		do
			dec1 := "33.244234523223234232446464984946131313164676413246764513767314";
			dec2 := "0.00000000000000";
			dec3 := "245234523452345";
			dec4 := "12341241.123412412341234"
			str := dec3.out

			val := "333333"
		end

	test1: BOOLEAN
		local
			m1: DECIMAL
			m2: DECIMAL
		do
			m1 := "25.5556"
			m2 := m1.root
		end

	test2: BOOLEAN
		local
			m1: DECIMAL
			m2: DECIMAL
			res: DECIMAL
		do
			m1 := "2"
			m2 := "-0.3"
			res := m1^m2
		end
end
