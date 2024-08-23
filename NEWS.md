# dfeR 0.4.1

Update comma_sep() function to allow non-numeric values instead of throwing an error, now returns them unchanged.

# dfeR 0.4.0

Add function which creates a DfE R project:

- create_project() 

# dfeR 0.3.1

Fix bug in get_clean_sql() where using the additional settings would lose the original SQL statement

# dfeR 0.3.0

Add pretty_* functions for presenting pretty numbers:

- pretty_num()
- pretty_filesize()
- pretty_time_taken()

Add helper function for comma separating numbers:

- comma_sep()

# dfeR 0.2.0

Add function for formatting financial years:

- format_fy()

Add reversing functions for academic and financial years:

- format_ay_reverse()
- format_fy_reverse()

Add function for grabbing and cleaning a SQL script, and vignette for connecting to SQL.

- get_clean_sql()

# dfeR 0.1.1

Add default value to decimal place argument of round_five_up() function.

# dfeR 0.1.0

Relaunch of the package with two functions:

- format_ay()
- round_five_up()
