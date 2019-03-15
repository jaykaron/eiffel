note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE_KNIGHT
inherit 
	ETF_MOVE_KNIGHT_INTERFACE
		redefine move_knight end
create
	make
feature -- command 
	move_knight(square: TUPLE[x: INTEGER_64; y: INTEGER_64])
		require else 
			move_knight_precond(square)
    	do
			-- perform some update on the model state
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
