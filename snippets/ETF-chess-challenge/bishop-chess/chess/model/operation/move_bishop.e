note
	description: "Move operation with undo/redo"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	MOVE_BISHOP

inherit

	MOVE
		redefine
			out
		end

	DEBUG_OUTPUT
		redefine
			out
		end

create
	make

feature {NONE} -- constructor

	make(a_new_position: SQUARE)
		do
			old_position := board.bishop_position
			position := a_new_position
		end

feature -- queries
		old_position: SQUARE
		position: SQUARE

	directions: ARRAY[TUPLE[x: INTEGER; y: INTEGER]]
		local
			x,y: INTEGER
		do
			create Result.make_empty
			-- To Do
		end



feature -- commands

	execute
		do
				-- To Do
		end

	undo
		do

				-- To Do
		end

	redo
		do
			-- To Do
		end

feature

	out: STRING
		do
			Result := ""
		end

	debug_output: STRING
		do
			Result := out
		end

end
