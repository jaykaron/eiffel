note
	description: "Summary description for {TESTS}."
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_INT_1
inherit
	ES_TEST

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
			add_boolean_case (agent t3)

			add_violation_case_with_tag ("denominator_non_zero", agent t100)
		end

feature -- tests
	t1: BOOLEAN
			-- test addition
		local
			i1,i2,answer: BIG_INTEGER
			i3, i4: BIG_INTEGER
		do
			comment ("t1: test INT addition and subtraction")
			i1 := "11"
			i2 := "22"
			answer := "33"
			Result := i1 + i2 ~ answer
			check Result end
			Result := i1 + i2 ~ "33"
			i3 := "-11"
			i4 := "100"
			assert_equal ("fail",(i3 + i4).out, "89")
			answer := i3 + i4
			Result := i3 + i4 ~ "89"
		end

	t2: BOOLEAN
			-- test addition
		local
			i1,i2,answer: BIG_INTEGER
			i3,i4: BIG_INTEGER
		do
			comment ("t2: test INT multiplication")
			i1 := "5"
			i2 := "7"
			answer := "35"
			Result := i1 * i2 ~ answer
			check Result end
			Result := i1 * i2 ~ "35"
			i3 := "-6"
			i4 := "4"
			assert_equal ("fail",(i3 * i4).out, "-24")
			answer := i3 * i4
			Result := i3 * i4 ~ "-24"
		end

	t3: BOOLEAN
			-- test addition
		local
			i1,i2,answer: BIG_INTEGER
			i3,i4: BIG_INTEGER
		do
			comment ("t3: test INT integer division")
			i1 := "40"
			i2 := "8"
			answer := "5"
			Result := i1 // i2 ~ answer
			check Result end
			Result := i1 // i2 ~ "5"
			i3 := "7"
			i4 := "3"
			assert_equal ("fail",(i3 // i4).out, "2")
			answer := i3 // i4
			Result := i3 // i4 ~ "2"
			check Result end
			i3 := "1"
			i4 := "3"
			Result := i3 // i4 ~ "0"
			check Result end
			i3 := "9223372036854775807"
			i4 := "100000000000000000"
			Result := i3//i4 ~ "92"
			check Result end
			i3 := "-9223372036854775808"
			i4 := "100000000000000000"
			Result := i3//i4 ~ "-92"
			check Result end
--			i3 := "9223372036854775808"
--			print(i3.as_integer64)  -- corretly generate pre violation

		end

feature --
	t100
			-- test addition
		local
			i1,i2,answer: BIG_INTEGER
		do
			comment ("t100:cannot divide by zero")
			i1 := "40"
			i2 := "0"
			answer :=  i1 // i2
		end

end
