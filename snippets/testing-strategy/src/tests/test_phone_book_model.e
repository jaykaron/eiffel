note
	description: "Test PHONE_BOOK_MODEL"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	TEST_PHONE_BOOK_MODEL
inherit
	TEST_PHONE_BOOK_ADT

create
	make
feature

	pb: PHONE_BOOK_MODEL
			-- factory
		do
			create Result.make
		end


end

