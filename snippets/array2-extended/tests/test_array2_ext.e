note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TEST_ARRAY2_EXT

inherit
	EQA_TEST_SET

feature -- Test routines

	array2_ext_test
			-- New test routine
		local
			l_array: ARRAY2_EXT[INTEGER]
		do
			create l_array.make_filled(0,3,4)
			l_array.put_row (row1, 1)
			assert ("put row", l_array.row(1)[1] = 10)
--            assert_arrays_equal("row1", row1, l_array.row (1))

		end

feature -- constants
	row1: ARRAY[INTEGER] once Result := <<10, 20, 30, 40>> end

end


