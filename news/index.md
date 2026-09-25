# Changelog

## dfeR 2.0.0

CRAN release: 2026-09-23

- **Breaking change**: Removed the deprecated `wd_pcon_lad_la_rgn_ctry`
  dataset and its startup message. Use `geo_hierarchy` instead, which
  has all the same columns plus more, and is kept up to date (it
  includes 2025, `wd_pcon_lad_la_rgn_ctry` stopped at 2024).
- Added
  [`diagnostic_test()`](https://dfe-analytical-services.github.io/dfeR/reference/diagnostic_test.md)
  and a set of `check_*` helpers to diagnose and (optionally) fix common
  DfE laptop R-setup issues — proxy settings, Git SSL verification,
  `GITHUB_PAT`, renv download methods, RTools toolchain, global
  `.gitconfig` location, and `.Renviron`/`.Rprofile` location.
- Added
  [`fetch_mp_lookup()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_mp_lookup.md)
  to fetch the Westminster constituency to sitting MP lookup maintained
  at <https://github.com/dfe-analytical-services/mp-lookup>, giving one
  row per constituency with the MP’s name, party, member ID and email
  alongside the geography the constituency maps to. It errors with an
  informative message if the upstream file is missing any expected
  columns.
- [`air_install()`](https://dfe-analytical-services.github.io/dfeR/reference/air_install.md)
  now checks the installed Air version and automatically reinstalls it
  if it is older than the minimum version required by
  [`air_style()`](https://dfe-analytical-services.github.io/dfeR/reference/air_style.md)
  (currently 0.10.0, when Air’s default `assignment-style` changed to
  `"arrow"`). It also gains a `force` argument to always reinstall. If
  the install does not leave a supported version of Air in place, it now
  warns rather than failing silently.
- [`format_ay()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay.md),
  [`format_fy()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy.md),
  [`format_ay_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay_reverse.md)
  and
  [`format_fy_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy_reverse.md)
  now accept vectors of years, e.g. `format_ay(c(201617, 201718))`.
  Previously they failed given more than one value.
- Fixed
  [`get_ons_api_data()`](https://dfe-analytical-services.github.io/dfeR/reference/get_ons_api_data.md)
  ignoring any `where` filter in `query_params`; filtered queries could
  return extra rows. It also now gives informative errors when a query
  matches nothing, the API can’t be reached, or the API rejects the
  request (for example an unknown `data_id`).
- Fixed
  [`air_style()`](https://dfe-analytical-services.github.io/dfeR/reference/air_style.md)
  failing when the `target` path contains spaces (for example a OneDrive
  path under “OneDrive - Department for Education”).
- Fixed
  [`check_databricks_odbc()`](https://dfe-analytical-services.github.io/dfeR/reference/check_databricks_odbc.md)
  failing for users who don’t have `stringr` installed.

## dfeR 1.3.0

- **Breaking change**: In `geo_hierarchy` and the output of
  [`fetch_mayoral()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_mayoral.md),
  the `cauth_name` and `cauth_code` columns are renamed to
  `english_devolved_area_name` and `english_devolved_area_code`, and the
  Greater London Authority is now included as the mayoral authority for
  London boroughs.
- Added
  [`air_install()`](https://dfe-analytical-services.github.io/dfeR/reference/air_install.md)
  and
  [`air_style()`](https://dfe-analytical-services.github.io/dfeR/reference/air_style.md)
  to install and run the Air formatter on R code.
- Added
  [`write_df_to_delta()`](https://dfe-analytical-services.github.io/dfeR/reference/write_df_to_delta.md)
  to write a data frame to a Delta table in Databricks, with an
  accompanying vignette. It accepts `DATABRICKS_HOST` with or without a
  scheme; bare hosts have `https://` prepended automatically, `http://`
  is upgraded to `https://`, and any trailing slash is stripped. An
  unset or empty `DATABRICKS_HOST` gives a clear error.
- Added the data `lsip_lad` which is a lookup table for Local Skills
  Improvement Plan (LSIP) areas and the function
  [`fetch_lsips()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_lsips.md)
  to fetch LSIP data.
- Updated `geo_hierarchy`, and associated `fetch_*` functions with
  latest 2025 lookups.
- Updated
  [`pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md)
  to add an `abbreviate` argument giving the option to avoid displaying
  large numbers in millions/billions, and a `dynamic_dp_value` argument
  that adds decimal places only when a value in millions/billions isn’t
  a whole number.
- The `fetch_*()` functions now give an error when given a year that
  their lookup does not cover, where previously they returned an empty
  data frame.

## dfeR 1.2.0

- Added `geo_hierarchy`, which supersedes `wd_pcon_lad_la_rgn_ctry` and
  adds 2025 along with mayoral columns.
- Added
  [`fetch_mayoral()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_mayoral.md).

## dfeR 1.1.0

- Added a function that checks Databricks variables for ODBC
  connections:
  [`check_databricks_odbc()`](https://dfe-analytical-services.github.io/dfeR/reference/check_databricks_odbc.md).
- Updated `wd_pcon_lad_la_rgn_ctry` by adding three digit local
  authority codes (also known as old_la_codes) to the data.
- Added old_la_codes which is an internal lookup table of local
  authorities with their names, nine digit codes and ‘old’ three digit
  codes. It is used to add ‘old’ 3 digit la codes to
  `wd_pcon_lad_la_rgn_ctry`.
- Updated
  [`fetch_las()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_las.md)
  so that old_la_codes are included in the output.

## dfeR 1.0.1

CRAN release: 2025-01-15

Fix the spacing and printing of the z_replace() warning message,
updating the eesyapi URL in the README and removed extraneous package
tests.

## dfeR 1.0.0

CRAN release: 2025-01-13

Initial CRAN release. Added lookup data geog_time_identifiers. Added
z_replace() to replace NA values in tables except for ones in geography
and time columns that match ones in geog_time_identifiers.

## dfeR 0.6.1

Patch to update the pretty_num() function so that the `dp` argument’s
default is 0.

## dfeR 0.6.0

Update pretty_num so that:

- it can take single or multiple values.
- it has the argument `nsmall` that allows control over the number of
  digits displayed after rounding.

Add pretty_num_table() which uses pretty_num() to format numbers in a
readable format in data frames. It has all the customization provided by
pretty_num.

## dfeR 0.5.1

Patch to update the get_clean_sql() function to ignore lines starting
with ‘USE’.

## dfeR 0.5.0

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

## dfeR 0.4.1

Update comma_sep() function to allow non-numeric values instead of
throwing an error, now returns them unchanged.

## dfeR 0.4.0

Add function which creates a DfE R project:

- create_project()

## dfeR 0.3.1

Fix bug in get_clean_sql() where using the additional settings would
lose the original SQL statement.

## dfeR 0.3.0

Add pretty\_\* functions for presenting pretty numbers:

- pretty_num()
- pretty_filesize()
- pretty_time_taken()

Add helper function for comma separating numbers:

- comma_sep()

## dfeR 0.2.0

Add function for formatting financial years:

- format_fy()

Add reversing functions for academic and financial years:

- format_ay_reverse()
- format_fy_reverse()

Add function for grabbing and cleaning a SQL script, and vignette for
connecting to SQL.

- get_clean_sql()

## dfeR 0.1.1

Add default value to decimal place argument of round_five_up() function.

## dfeR 0.1.0

Relaunch of the package with two functions:

- format_ay()
- round_five_up()
