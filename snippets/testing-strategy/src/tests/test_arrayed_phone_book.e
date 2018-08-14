note
	description: "Test arrayed phone book."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_ARRAYED_PHONE_BOOK
inherit
	TEST_PHONE_BOOK_ADT

create
	make
feature

	pb: ARRAYED_PHONE_BOOK
			-- factory
		do
			create Result.make
		end


end
