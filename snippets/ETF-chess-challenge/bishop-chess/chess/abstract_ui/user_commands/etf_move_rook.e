note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE_ROOK
inherit 
	ETF_MOVE_ROOK_INTERFACE
		redefine move_rook end
create
	make
feature -- command 
	move_rook(square: TUPLE[x: INTEGER_64; y: INTEGER_64])
		require else 
			move_rook_precond(square)
    	do
			-- perform some update on the model state
			model.default_update
			etf_cmd_container.on_change.notify ([Current])
    	end

end
