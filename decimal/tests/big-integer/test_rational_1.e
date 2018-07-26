note
	description: "Summary description for {TEST_RATIONAL_1}."
	author: "Amin Bandali"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_RATIONAL_1
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
			add_boolean_case (agent t4)
			add_boolean_case (agent t5)
			add_boolean_case (agent t6)
			add_boolean_case (agent t7)
			add_boolean_case (agent t8)
			add_boolean_case (agent t9)
--			add_boolean_case (agent t10) -- as_real64
--			add_boolean_case (agent t11)
			add_boolean_case (agent t12)
			add_boolean_case (agent t13)

			add_violation_case (agent t100)
			add_violation_case (agent t101)
			add_violation_case (agent t102)
			add_violation_case (agent t103)
			add_violation_case (agent t104)
			add_violation_case (agent t105)
			add_violation_case (agent t106)
			add_violation_case (agent t107)
			add_violation_case (agent t108)
			add_violation_case (agent t109)
		end

feature -- tests

	t1: BOOLEAN
		local
			i1, i2: BIG_INTEGER
			ii1, ii2: INTEGER
			r1, r2: RATIONAL
		do
			comment ("t1: creation and is_equal test")

			i1 := "10"
			i2 := "23"

			ii1 := 10
			ii2 := 23

			create r1.make_from_ints (i1, i2)
			create r2.make (ii1, ii2)

			Result := r1 ~ r2
		end

	t2: BOOLEAN
		local
			r: RATIONAL
		do
			comment ("t2: make_from_string tests")
			r := "1"
			r := "123456"
--			r := "1/0"
			Result := not r.string_is_rational ("1/0")
			check Result end
			r := "0/1"
			r := "000/001"
--			r := "10/0000"
			Result := not r.string_is_rational ("10/0000")
			check Result end
			Result := not r.string_is_rational ("-5/00")
			check Result end
			r := "-1/2"
			r := "2/-3"
			r := "0/-3"
--			r := "-5/00"

			Result := True
		end

	t3: BOOLEAN
		local
			r1, r2: RATIONAL
		do
			comment ("t3: addition and subtraction")

			r1 := "1/2"
			r2 := "3/4"
			check r1 + r2 ~ "5/4" end

			r1 := "3/7"
			check r1 + r2 ~ "33/28" and r1 + r2 ~ "-33/-28" end
			check r1 - r2 ~ "-9/28" and r1 - r2 ~ "9/-28" end
			Result := r2 - r1 ~ "9/28" and r2 - r1 ~ "-9/-28"
		end

	t4: BOOLEAN
		local
			r1, r2: RATIONAL
		do
			comment ("t4: multiplication and division")

			r1 := "1/2"
			r2 := "3/4"
			check r1 * r2 ~ "3/8" end

			r1 := "3/7"
			check r1 * r2 ~ "9/28" and r1 * r2 ~ "-9/-28" end
			check r1 / r2 ~ "4/7" end
			check r2 / r1 ~ "7/4" end

			check r1 / r2 ~ ("1" / (r2 / r1)) end
			Result := r1 / r2 ~ (r2 / r1).reciprocal
		end

	t5: BOOLEAN
		local
			r1, r2: RATIONAL
		do
			comment ("t5: square and power")

			r1 := "7/13"
			r2 := "9/-5"

			check r1.square ~ "49/169" and r1.square ~ "-49/-169" end
			check r2.square ~ "81/25" and r2.square ~ "-81/-25" end

			check r1 ^ 2 ~ r1.square end
			check r2 ^ 2 ~ r2.square end

			check r1 ^ 3 ~ "343/2197" end
			check r2 ^ 3 ~ "-729/125" end

			check r1 ^ (-2) ~ "169/49" end
			check r2 ^ (-2) ~ "25/81" end

			check r1 ^ (-3) ~ "2197/343" end
			Result := r2 ^ (-3) ~ "-125/729" and r2 ^ (-3) ~ "125/-729"
		end

	t6: BOOLEAN
		local
			r1, r2: RATIONAL
		do
			comment ("t6: float-like creation with -45.783")

			r1 := "-45.783"
			r2 := "-45.784"
			Result := r1 > r2
			check Result end

			r2 := "-45783/1000"
			Result := r1 ~ r2
			check Result end

			r2 := "-45.784"
			Result := r1 /~ r2
			check Result end

			r2 := "-45.7833"
			Result := r1 /~ r2

--			print_to_screen (r1.as_real.out + "%N")
--			print_to_screen (r2.as_real.out + "%N")
		end

	t7: BOOLEAN
		local
			r1, r2, r3: RATIONAL
		do
			comment ("t7: float-like creation with 123.23456")

			r1 := "123.23456"
			r2 := "123.234561"
			Result := r1 < r2
			check Result end

			r2 := "12323456/100000"
			r3 := "385108/3125"

			Result := r1 ~ r2 and r2 ~ r3
		end

	t8: BOOLEAN
		local
			r1, r2: RATIONAL
		do
			comment ("t8: creation with -12 and -12.000000000000000000000000000000001")

			r1 := "-12"
			r2 := "-12.000000000000000000000000000000001"
			Result := r1 > r2
			check Result end

			Result := r1 /~ r2
		end

	t9: BOOLEAN
		local
			r1, r2: RATIONAL
		do
			comment ("t9: as_real test with 13 and -89")
			r1 := "13"
			r2 := "-89"

			Result := r1.as_real = 13.0
			check Result end

			Result := r2.as_real = -89.0
		end

	t10: BOOLEAN
		local
			r: RATIONAL
		do
			comment ("t10: as_real test with 13.1")

			r := "13.1"
			Result := r.as_real = 13.1
		end

	t11: BOOLEAN
		local
			r: RATIONAL
		do
			comment ("t11: as_real test with -87.996")

			r := "-87.996"
			Result := r.as_real = -87.996
		end

	t12: BOOLEAN
		local
			r: RATIONAL
		do
			comment ("t12: round_to test with 123.458890 to 3 decimal places")

			r := "123.458890"
			Result := r.round_to (3) ~ "123.459"
		end

	t13: BOOLEAN
		local
			r: RATIONAL
		do
			comment ("t13: round_to test with -567.098765432 to 5 decimal places")

			r := "-567.098765432"
			Result := r.round_to (5) ~ "-567.09877"
		end

feature -- violation cases

	t100
		local
			r: RATIONAL
		do
			comment ("t100: make_from_string violation case with 0/0")
			r := "0/0"
		end

	t101
		local
			r: RATIONAL
		do
			comment ("t101: make_from_string violation case with 000/000")
			r := "000/000"
		end

	t102
		local
			r: RATIONAL
		do
			comment ("t102: make_from_string violation case with 00/00000")
			r := "00/00000"
		end

	t103
		local
			r: RATIONAL
		do
			comment ("t103: make_from_string violation case with -55/")
			r := "-55/"
		end

	t104
		local
			r: RATIONAL
		do
			comment ("t104: make_from_string violation case with /1")
			r := "/1"
		end

	t105
		local
			r: RATIONAL
		do
			comment ("t105: make_from_string violation case with 1.1.")
			r := "1.1."
		end

	t106
		local
			r: RATIONAL
		do
			comment ("t106: make_from_string violation case with 111111111111.")
			r := "111111111111."
		end

	t107
		local
			r: RATIONAL
		do
			comment ("t107: make_from_string violation case with 1.0/")
			r := "1.0/"
		end

	t108
		local
			r: RATIONAL
		do
			comment ("t108: make_from_string violation case with 1.1/2.2")
			r := "1.1/2.2"
		end

	t109
		local
			r: RATIONAL
		do
			comment ("t109: make_from_string violation case with 1/2.0")
			r := "1/2.0"
		end
end
