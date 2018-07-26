note
	description: "Summary description for {TESTS}."
	author: "Amin Bandali"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_INT_2
inherit
	ES_TEST

create
	make

feature {NONE} -- Initialization

	make
			-- run tests
		do
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
			add_boolean_case (agent t3)
			add_boolean_case (agent t4)
			add_boolean_case (agent t5)
			add_boolean_case (agent t6)
			add_boolean_case (agent t7)
		end

feature -- tests

	t1: BOOLEAN
		local
			i: BIG_INTEGER
		do
			comment ("t1: make and is_equal test")
			create i.make_from_string ("12")
			check i.out ~ "12" and i ~ "12" end
			create i.make_from_string ("13")
			check i.out ~ "13" and i ~ "13" end
			create i.make_from_string ("003")
			check i.out ~ "3" and i ~ "3" end
			create i.make_from_string ("-003")
			check i.out ~ "-3" and i ~ "-3" end
			check i ~ "-000000000003" end
			create i.make_from_string ("-311")
			check i.out ~ "-311" and i ~ "-311" end
			create i.make_from_string ("-0")
			check i.out ~ "0" and i ~ "0"  end
			create i.make_from_string ("0")
			check i.out ~ "0" and i ~ "0"  end
			create i.make_from_string ("0")
			check i.out ~ "0" and i ~ "0"  end 
			create i.make_from_string ("23")
			Result := i.out ~ "23" and i ~ "23"
		end

	t2: BOOLEAN
		local
			zero, i: BIG_INTEGER
		do
			comment ("t2: is_less test")
			create zero
			create i.make_from_string ("0")
			check i ~ zero and not (zero < i) and not (zero > i) end
			i := "13"
			check zero < i end
			check i > zero end
			check i /~ zero end
			Result := i ~ i and i ~ "000013" and i ~ "00000013"
			Result := Result and not (i > i) and not (i < i)
			Result := Result and not (i ~ "-13")
		end

	t3: BOOLEAN
		local
			zero, i1, i2: BIG_INTEGER
		do
			comment ("t3: addition test")
			create zero
			create i1.make_from_string ("9")
			create i2.make_from_string ("8")
			Result := i1 + i2 ~ "17"
		end

	t4: BOOLEAN
		local
			i1, i2: BIG_INTEGER
		do
			comment ("t4: addition test with larger ints")
			create i1.make_from_string ("123456789123456789111111")
			create i2.make_from_string ("98798798798798798799879879879879879879")
			Result := i1 + i2 ~ "98798798798798922256669003336668990990"
		end

	t5: BOOLEAN
		local
			i1, i2: BIG_INTEGER
		do
			comment ("t5: test square and is_less")

			create i1.make_from_string ("10000")
			create i2.make_from_string ("10001")
			check i1 < i2 end
			check i1.square < i2.square end

			create i1.make_from_string ("-444")
			create i2.make_from_string ("-10")
			check i1.square > i2.square end

			create i2.make_from_string ("123456789123456789123456789")
			check i1 < i2 end
			check i1.square < i2.square end

			create i1.make_from_string ("15241578780673678546105778281054720515622620750190521")
			Result := i2.square ~ i1
		end

	t6: BOOLEAN
		local
			i1, i2: BIG_INTEGER
		do
			comment ("t6: power test")

			i1 := "123456789123456789123456789"
			i2 := "15241578780673678546105778281054720515622620750190521"
			check i1 ^ 0 ~ "1" end
			check i1 ^ 1 ~ "123456789123456789123456789" end
			check i2 ~ i1.square end
			check i2 ~ i1 ^ 2 end

			i1 := "123"
			i2 := i1 * i1 * i1 * i1 * i1
			check i2 ~ i1 ^ 5 end
			check i2 ~ i1 ^ 3 * (i1.square) end

			i2 := i1 ^ 23
			Result := i2 ~ "1169008215014432917465348578887506800769541157267"
		end

	t7: BOOLEAN
		local
			i1, i2: BIG_INTEGER
		do
			comment ("t7: gcd test")

			i1 := "12"
			i2 := "0"
			check i1.gcd (i2) ~ i1 and i2.gcd (i1) ~ i1 end

			i2 := "1"
			check i1.gcd (i2) ~ i2 end

			i2 := "13"
			check i1.gcd (i2) ~ i2.gcd (i1) and i1.gcd (i2) ~ "1" end

			i1 := "7"
			i2 := "21"
			check i1.gcd (i2) ~ i1 and i2.gcd (i1) ~ i1 end

			i1 := "18"
			i2 := "12"
			check i1.gcd (i2) ~ i2.gcd (i1) and i1.gcd (i2) ~ "6" end

			i1 := "18"
			i2 := "27"
			Result := i1.gcd (i2) ~ i2.gcd (i1) and i1.gcd (i2) ~ "9"
		end

end


-- test cases showing the issues with INT_PORT (BigInteger port) and INT_E2J (Eiffel2Java wrapper)

--	t5: BOOLEAN
--		local
--			i1, i2: INT_PORT
--		do
--			comment ("t5: test square and is_less")

--			create i1.make ("10000")
--			create i2.make ("10001")
--			check i1 < i2 end
--			check i1.square < i2.square end

--			create i1.make ("-444")
--			create i2.make ("-10")
--			check i1.square > i2.square end

--			create i2.make ("123456789123456789123456789")
--			check i1 < i2 end
--			check i1.square < i2.square end

--			create i1.make ("15241578780673678546105778281054720515622620750190521")
--			Result := i2.square ~ i1
--		end

--	t6: BOOLEAN
--		local
--			zero, i1, i2: INT_E2J
--		do
--			comment ("t1: INT creation")

--			create zero
--			check zero ~ "0" end
--			check zero ~ 0 end
--			Result := True
--		end
