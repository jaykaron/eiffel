note
	description: "Summary description for {NAME}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NAME

inherit

	ANY
		redefine
			is_equal,
			out
		end

	HASHABLE
		redefine
			is_equal,
			out
		end

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING_32)
			-- Initialization for `Current'.
		do
			item := a_name
		end

feature

	item: IMMUTABLE_STRING_32

	is_equal (other: like Current): BOOLEAN
		do
			Result := item ~ other.item
		end

	hash_code: INTEGER
		do
			Result := item.hash_code
		end

	out: STRING
		do
			Result := item.out
		end

end
