note
	description: "ROOT class for project"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	ROOT
inherit
	ARGUMENTS_32
	ES_SUITE
create
	make

feature {NONE} -- Initialization

	make
			-- Run application
		do
			add_test (create {TEST_PHONE_BOOK_MODEL}.make)
			add_test (create {TEST_ARRAYED_PHONE_BOOK}.make)
			show_browser
			run_espec
		end

end
