note
	description: "Summary description for {JSO_TESTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSO_DECIMAL_TEST
inherit
	ES_TEST
create
	make
feature {NONE}
	make
		do
			add_boolean_case (agent t0)

			add_boolean_case (agent t10)
		end

feature -- tests
	t0: BOOLEAN
		local
			d1,d2: DECIMAL
		do
			comment("t0: 0.1 ten times")
			d1 := ".1"
			d2 := d1 + d1 + d1 + d1 + d1 + d1 + d1 + d1 +d1 + d1
			Result := d2.out ~ "1.00" and d2.precise_out ~ "1"
		end

	t10: BOOLEAN
		local
			d1,d2: DECIMAL
		do
			comment("t0:sqrt(2)")
			d1 := "2"
			d2 := d1.root
			Result := d2.out ~ "1.41"
			check Result end
			d1 := "9.3"
			d2 := d1.root
			Result := d2.out ~ "3.05"
		end

end
