# Package index

## Templates, code formatting and system set-up

Tools for establishing relevant user settings

- [`air_install()`](https://dfe-analytical-services.github.io/dfeR/reference/air_install.md)
  : Air Install
- [`air_style()`](https://dfe-analytical-services.github.io/dfeR/reference/air_style.md)
  : Air - style code in scripts
- [`create_project()`](https://dfe-analytical-services.github.io/dfeR/reference/create_project.md)
  : Creates a pre-populated project for DfE R

## Standard DfE data sets

Data sets exported in the package

- [`ons_geog_shorthands`](https://dfe-analytical-services.github.io/dfeR/reference/ons_geog_shorthands.md)
  : Lookup for ONS geography columns shorthands
- [`geo_hierarchy`](https://dfe-analytical-services.github.io/dfeR/reference/geo_hierarchy.md)
  : Geography hierarchy lookup
- [`countries`](https://dfe-analytical-services.github.io/dfeR/reference/countries.md)
  : Lookup for valid country names and codes
- [`regions`](https://dfe-analytical-services.github.io/dfeR/reference/regions.md)
  : Lookup for valid region names and codes
- [`geog_time_identifiers`](https://dfe-analytical-services.github.io/dfeR/reference/geog_time_identifiers.md)
  : Potential names for geography and time columns
- [`wd_pcon_lad_la_rgn_ctry`](https://dfe-analytical-services.github.io/dfeR/reference/wd_pcon_lad_la_rgn_ctry.md)
  **\[deprecated\]** : Ward to Constituency to LAD to LA to Region to
  Country lookup
- [`lsip_lad`](https://dfe-analytical-services.github.io/dfeR/reference/lsip_lad.md)
  : Local Skills Improvement Plan (LSIP) areas to Local Authority
  District (LAD) Lookup

## Fetch geography lists

Pull geography lookups from the ONS Geography Portal

- [`fetch_pcons()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch.md)
  : Fetch Westminster parliamentary constituencies
- [`fetch_countries()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_countries.md)
  : Fetch countries
- [`fetch_lads()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_lads.md)
  : Fetch local authority districts
- [`fetch_las()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_las.md)
  : Fetch local authorities
- [`fetch_lsips()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_lsips.md)
  : Fetch Local Skills Improvement Plan (LSIP) areas lookup
- [`fetch_mayoral()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_mayoral.md)
  : Fetch mayoral combined authorities
- [`fetch_regions()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_regions.md)
  : Fetch regions
- [`fetch_wards()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_wards.md)
  : Fetch wards
- [`get_ons_api_data()`](https://dfe-analytical-services.github.io/dfeR/reference/get_ons_api_data.md)
  : Fetch ONS Open Geography API data

## Database connection

Helpful functions for connecting to databases in DfE

- [`get_clean_sql()`](https://dfe-analytical-services.github.io/dfeR/reference/get_clean_sql.md)
  : Get a cleaned SQL script into R
- [`check_databricks_odbc()`](https://dfe-analytical-services.github.io/dfeR/reference/check_databricks_odbc.md)
  : Check Databricks ODBC connection variables
- [`write_df_to_delta()`](https://dfe-analytical-services.github.io/dfeR/reference/write_df_to_delta.md)
  : Write a Data Frame to Delta Lake with COPY INTO

## Presentation prettifiers

Functions for presenting pretty versions of numbers with readable code

- [`pretty_filesize()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_filesize.md)
  : Pretty numbers into readable file size

- [`pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md)
  : Prettify big numbers into a readable format

- [`pretty_num_table()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num_table.md)
  :

  Format a data frame with
  [`dfeR::pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md).

- [`pretty_time()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time.md)
  : Pretty time

- [`pretty_time_taken()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time_taken.md)
  : Calculate elapsed time between two points and present prettily

- [`round_five_up()`](https://dfe-analytical-services.github.io/dfeR/reference/round_five_up.md)
  : Round five up

- [`comma_sep()`](https://dfe-analytical-services.github.io/dfeR/reference/comma_sep.md)
  : Comma separate

- [`z_replace()`](https://dfe-analytical-services.github.io/dfeR/reference/z_replace.md)
  :

  Replaces `NA` values in tables

## Specific formats

Functions for converting to specific formats

- [`format_ay()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay.md)
  : Format academic year
- [`format_ay_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay_reverse.md)
  : Undo academic year formatting
- [`format_fy()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy.md)
  : Format financial year
- [`format_fy_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy_reverse.md)
  : Undo financial year formatting

## System diagnostics

Functions to diagnose and fix common system issues

- [`diagnostic_test()`](https://dfe-analytical-services.github.io/dfeR/reference/diagnostic_test.md)
  : Diagnostic testing
- [`check_proxy_settings()`](https://dfe-analytical-services.github.io/dfeR/reference/check_proxy_settings.md)
  : Check proxy settings
- [`check_git_sslverify()`](https://dfe-analytical-services.github.io/dfeR/reference/check_git_sslverify.md)
  : Check Git sslverify setting
- [`check_gitconfig_location()`](https://dfe-analytical-services.github.io/dfeR/reference/check_gitconfig_location.md)
  : Check the location of the global .gitconfig file
- [`check_github_pat()`](https://dfe-analytical-services.github.io/dfeR/reference/check_github_pat.md)
  : Check GITHUB_PAT setting
- [`check_renv_download_method()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_download_method.md)
  : Check renv download method
- [`check_renv_dl_file_method()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_dl_file_method.md)
  : Check RENV_DOWNLOAD_FILE_METHOD system variable
- [`check_rtools()`](https://dfe-analytical-services.github.io/dfeR/reference/check_rtools.md)
  : Check for an RTools / make toolchain
- [`check_renv_rprof_location()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_rprof_location.md)
  : Check the location of .Renviron and .Rprofile

## Helpers

Functions used in other functions across the package, exported as they
can also be useful in their own right

- [`toggle_message()`](https://dfe-analytical-services.github.io/dfeR/reference/toggle_message.md)
  : Controllable console messages
