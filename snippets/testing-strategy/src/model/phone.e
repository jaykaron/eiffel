note
	description: "Phone number in a phone book"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	PHONE
inherit
	ANY
		redefine out end
create
	make
feature {NONE}
	make(a_area_code: INTEGER; a_phone_number: INTEGER)
		require
			100 <= a_area_code and a_area_code <= 999
			1000000 <= a_phone_number and a_phone_number <= 9999999
		do
			area_code := a_area_code
			number := a_phone_number
		end
feature
	area_code: INTEGER
	number: INTEGER

	out: STRING
		do
			Result := area_code.out + "-" + number.out
		end

invariant
	100 <= area_code and area_code <= 999
	1000000 <= number and number <= 9999999
end
