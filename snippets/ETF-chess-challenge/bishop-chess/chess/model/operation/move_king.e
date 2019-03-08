note
	description: "Move operation with undo/redo"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

class
	MOVE_KING

inherit

	MOVE

create
	make

feature {NONE} -- constructor

	make(a_new_position: SQUARE)
		do
			old_position := board.king_position
			position := a_new_position
		end

feature -- queries
		old_position: SQUARE
		position: SQUARE

	directions: ARRAY[TUPLE[x: INTEGER; y: INTEGER]]
		do
			Result := <<[1, 0], [-1,  0], [ 0, 1], [ 0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]>>
		end

feature -- commands

	execute
		do
				board.move_king	 (position)
		end

	undo
		do

				-- To Do
		end

	redo
		do
			-- To Do
		end


end
