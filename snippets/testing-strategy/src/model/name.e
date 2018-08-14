note
	description: "Name in a phone book"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	NAME
inherit
	ANY
		redefine is_equal end
create
	make
feature {NONE}
	make(a_name: IMMUTABLE_STRING_32)
		do
			item := a_name
		end
feature
	item: IMMUTABLE_STRING_32

	is_equal(other: like Current): BOOLEAN
		do
			Result := item ~ other.item
		end
end
