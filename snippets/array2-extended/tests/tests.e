note
	description: "Summary description for {TESTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TESTS
inherit
	ES_TEST

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			add_boolean_case (agent t0)
		end

feature -- tests
	t0: BOOLEAN
		local
			l_array: ARRAY2_EXT[INTEGER]
		do
			comment("t0: First test")
		end

end
