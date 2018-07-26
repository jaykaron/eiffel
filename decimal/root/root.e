note
	description: "Calendar application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	ROOT

inherit
	ARGUMENTS
	ES_SUITE

create
	make

feature {NONE} -- Initialization

	make
			-- Run application.
		do
			add_test (create {JSO_DECIMAL_TEST}.make)
			add_test (create {DECIMAL_TEST1}.make)
			add_test (create {DECIMAL_TEST2}.make)
--			add_test (create {SLOW_DECIMAL_TESTS}.make) --eneable this

			add_test (create {TEST_INT_JSO}.make)
			add_test (create {TEST_INT_1}.make)
			add_test (create {TEST_INT_2}.make)
			add_test (create {TEST_RATIONAL_1}.make)

			show_browser
			run_espec
		end

end
