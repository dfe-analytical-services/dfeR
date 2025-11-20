# Get a cleaned SQL script into R

This function cleans a SQL script, ready for using within R in the DfE.

## Usage

``` r
get_clean_sql(filepath, additional_settings = FALSE)
```

## Arguments

- filepath:

  path to a SQL script

- additional_settings:

  TRUE or FALSE boolean for the addition of settings at the start of the
  SQL script

## Value

Cleaned string containing SQL query

## Examples

``` r
# This assumes you have already set up a database connection
# and that the filepath for the function exists
# For more details see the vignette on connecting to SQL

# Pull a cleaned version of the SQL file into R
if (file.exists("your_script.sql")) {
  sql_query <- get_clean_sql("your_script.sql")
}
```
