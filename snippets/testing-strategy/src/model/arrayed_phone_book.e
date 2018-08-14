note
	description: "[
		Efficient implemtation of a phone book
		using two arrays: names and phones
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARRAYED_PHONE_BOOK
inherit
	PHONE_BOOK_ADT

create
	make
feature {NONE}
	make
		do
			create names.make_empty
			names.compare_objects
			create phones.make_empty
			phones.compare_objects
		end

feature {NOME} --implementation
	names: ARRAY[NAME]
	phones: ARRAY[PHONE]

feature -- model
	book: FUN[NAME, PHONE]
			--abstraction function
		do
			create Result.make_empty
			across 1 |..| names.count as i loop
				Result.extend ([names[i.item], phones[i.item]])
			end
		end
feature -- queries
	has(a_name: NAME): BOOLEAN
		do
			Result := names.has (a_name)
		end

	count: INTEGER
		do
			Result := names.count
		end

feature -- commands
	extend(a_name: NAME; a_phone: PHONE)
		local
			i: INTEGER
		do
			i := count + 1
			names.force (a_name, i)
			phones.force (a_phone, i)
		end

	item alias "[]"(a_name: NAME): detachable PHONE
		local
			i: INTEGER
			found: BOOLEAN
		do
			from
				i := 1
			until
				i > names.count or found
			loop
				if names[i] ~ a_name then
					Result := phones[i]
				end
				i := i + 1
			end
		end
end
