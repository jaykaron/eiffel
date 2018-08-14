note
	description: "[
		Possibly inefficient implementation of a phone,
		using Mathmodels commands
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PHONE_BOOK_MODEL
inherit

	PHONE_BOOK_ADT
		redefine book end
create
	make
feature {NONE}
	book_imp: like book

	make
		do
			create book_imp.make_empty
		end
feature -- model
	book: FUN[NAME,PHONE]
			--abstraction function is easy
		do
			Result := book_imp
		end

feature -- queries
	has(a_name: NAME): BOOLEAN
		do
			Result := book.domain.has (a_name)
		end

	count: INTEGER
		do
			Result := book.count

		end

feature -- commands
	extend(a_name: NAME; a_phone: PHONE)
		do
			book_imp.extend ([a_name, a_phone])
		end

	item alias "[]"(a_name: NAME): detachable PHONE
		do
			if book.domain.has (a_name) then
				Result := book[a_name]
			else
				Result := Void
			end
		end

end



