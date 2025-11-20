# Replaces `NA` values in tables

Replaces `NA` values in tables except for ones in time and geography
columns that must be included in DfE official statistics. [Guidance on
our Open Data Standards.](https://www.shorturl.at/chy76)

## Usage

``` r
z_replace(data, replacement_alt = NULL, exclude_columns = NULL)
```

## Arguments

- data:

  name of the table that you want to replace NA values in

- replacement_alt:

  optional - if you want the NA replacement value to be different to "z"

- exclude_columns:

  optional - additional columns to exclude from NA replacement. Column
  names that match ones found in
  [`dfeR::geog_time_identifiers`](https://dfe-analytical-services.github.io/dfeR/reference/geog_time_identifiers.md)
  will always be excluded because any missing data for these columns
  need more explicit codes to explain why data is not available.

## Value

table with "z" or an alternate replacement value instead of `NA` values
for columns that are not for time or geography.

## Details

Names of geography and time columns that are used in this function can
be found in
[`dfeR::geog_time_identifiers`](https://dfe-analytical-services.github.io/dfeR/reference/geog_time_identifiers.md).

## See also

[geog_time_identifiers](https://dfe-analytical-services.github.io/dfeR/reference/geog_time_identifiers.md)

## Examples

``` r
# Create a table for the example

df <- data.frame(
  time_period = c(2022, 2022, 2022),
  time_identifier = c("Calendar year", "Calendar year", "Calendar year"),
  geographic_level = c("National", "Regional", "Regional"),
  country_code = c("E92000001", "E92000001", "E92000001"),
  country_name = c("England", "England", "England"),
  region_code = c(NA, "E12000001", "E12000002"),
  region_name = c(NA, "North East", "North West"),
  mystery_count = c(42, 25, NA)
)

z_replace(df)
#>   time_period time_identifier geographic_level country_code country_name
#> 1        2022   Calendar year         National    E92000001      England
#> 2        2022   Calendar year         Regional    E92000001      England
#> 3        2022   Calendar year         Regional    E92000001      England
#>   region_code region_name mystery_count
#> 1        <NA>        <NA>            42
#> 2   E12000001  North East            25
#> 3   E12000002  North West             z

# Use a different replacement value
z_replace(df, replacement_alt = "c")
#>   time_period time_identifier geographic_level country_code country_name
#> 1        2022   Calendar year         National    E92000001      England
#> 2        2022   Calendar year         Regional    E92000001      England
#> 3        2022   Calendar year         Regional    E92000001      England
#>   region_code region_name mystery_count
#> 1        <NA>        <NA>            42
#> 2   E12000001  North East            25
#> 3   E12000002  North West             c
```
