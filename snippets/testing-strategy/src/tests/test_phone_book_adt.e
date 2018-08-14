note
	description: "[
		API for Tests.
		Uses template and creation design patterns.
	]"
	author: "JSO"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TEST_PHONE_BOOK_ADT
inherit
	ES_TEST

feature {NONE} -- Initialization

	make
			-- run tests
		do
			add_boolean_case (agent t0)
			add_boolean_case (agent t1)
			add_boolean_case (agent t2)
		end

feature -- tests

	pb: PHONE_BOOK_ADT
			-- creation factory
		deferred
		end

	t0: BOOLEAN
		local
			tom,pam: NAME
			p1,p2: PHONE
		do
			comment("t0: create and test Tom and Pam")
			create tom.make ("Tom")
			create pam.make ("Pam")
			create p1.make (416, 7362100)
			create p2.make (416, 5555555)
			Result := p2.out ~ "416-5555555" and tom.item ~ "Tom"
		end

	t1: BOOLEAN
		local
			tom,pam: NAME
			p1,p2: PHONE
			l_pb: like pb
		do
			comment("t1: extend phone book with Tom and Pam")
			l_pb := pb
			create tom.make ("Tom")
			create pam.make ("Pam")
			create p1.make (416, 7362100)
			create p2.make (416, 5555555)
			Result := p2.out ~ "416-5555555"
			check Result end
			l_pb.extend (tom,p1)
			l_pb.extend (pam,p2)
			Result := l_pb[tom] ~ p1 and l_pb[pam] ~ p2
		end

	t2: BOOLEAN
		local
			tom,pam,jim: NAME
			p1,p2,p3: PHONE
			l_pb: like pb
		do
			comment("t2: non existing contact")
			l_pb := pb
			create tom.make ("Tom")
			create pam.make ("Pam")
			create jim.make ("Jim")
			create p1.make (416, 7362100)
			create p2.make (416, 5555555)
			create p3.make (718, 9234567)
			l_pb.extend (tom,p1)
			l_pb.extend (pam,p2)
			Result := l_pb[tom] ~ p1 and l_pb[pam] ~ p2
			check Result end
			Result := not l_pb.has (jim)
		end

end
