note
	description: "[
		API for a phone book.
		A phone book is a function from NAME 
		to North American PHONE numbers
		]"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PHONE_BOOK_ADT

feature -- model
	book: FUN[NAME,PHONE]
			-- abstraction function
		deferred
		end


feature -- queries
	has(a_name: NAME): BOOLEAN
		deferred
		ensure
			Result = book.domain.has (a_name)
		end

	count: INTEGER
		deferred
		ensure
			Result = book.count
		end

feature -- commands
	extend(a_name: NAME; a_phone: PHONE)
			-- phone book with `a_name' and a_phone entry
		require
			not has (a_name)
		deferred
		ensure
			book ~ (old book.deep_twin + [a_name, a_phone])
		end

	item alias "[]"(a_name: NAME): detachable PHONE
			-- return a phone if _anmae exists
			-- else Void
		deferred
		ensure
			if has (a_name) then
				Result = book[a_name]
			else
				Result = Void
			end
		end

end
