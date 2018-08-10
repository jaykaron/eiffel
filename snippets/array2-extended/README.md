# ARRAY2 Extended
Suggested by Larry Rix on eiffel-users group. ECF is eiffel18.07 Void safe. Manual AutoTest is used. 

### Specfication

Add two new features to the class ARRAY2, to get  all the elements in one specific row or column. 

* row(i: INTEGER): ARRAY[G]
* col(i: INTEGER): ARRAY[G]

### Design
Use the open-closed principal. ARRAY2 is closed, but we can open it with inheritance. 

![array2_ext](model/array2_ext.e)

```eiffel
class
	ARRAY2_EXT [G]

inherit
	ARRAY2 [G]
		rename
			height as row_count,
			width as column_count
		end

create
	make,
	make_filled
...
```