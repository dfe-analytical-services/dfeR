# dfeR 1.0.1

Fix the spacing and printing of the z_replace() warning message, updating the eesyapi URL in the README and removed extraneous package tests.

# dfeR 1.0.0

Initial CRAN release.
Added lookup data geog_time_identifiers.
Added z_replace() to replace NA values in tables except for ones in geography and time columns that match ones in geog_time_identifiers. 

# dfeR 0.6.1

Patch to update the pretty_num() function so that the `dp` argument's default is 0. 

# dfeR 0.6.0

Update pretty_num so that: 

- it can take single or multiple values. 
- it has the argument `nsmall` that allows control over the number of digits displayed after rounding. 

Add pretty_num_table() which uses pretty_num() to format numbers in a readable format in data frames. 
It has all the customization provided by pretty_num. 

# dfeR 0.5.1

Patch to update the get_clean_sql() function to ignore lines starting with 'USE'.

# dfeR 0.5.0

Add the following lookup data sets into the package:

- ons_geog_shorthands
- countries
- regions
- wd_pcon_lad_la_rgn_ctry

Add the following fetch_locations() functions:

- fetch_wards()
- fetch_pcons()
- fetch_lads()
- fetch_las()
- fetch_regions()
- fetch_countries()

Add wrapper for ONS Open Geography Portal API:

- get_ons_api_data()

Add helper for turning messages on or off:

- toggle_message()

# dfeR 0.4.1

Update comma_sep() function to allow non-numeric values instead of throwing an error, now returns them unchanged.

# dfeR 0.4.0

Add function which creates a DfE R project:

- create_project() 

# dfeR 0.3.1

Fix bug in get_clean_sql() where using the additional settings would lose the original SQL statement.

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
