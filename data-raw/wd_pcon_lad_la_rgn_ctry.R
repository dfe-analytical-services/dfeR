# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Created: 05/08/2024, Cam Race
#
# This script creates the wd_pcon_lad_la_reg_ctry data set
#
# If updating the data, follow these steps:
# 1. Load the package using `devtools::load_all(".")`
# 2. Add in an extra year for the new year into this script within the
#    create_timeseries_lookup function (R/datasets_utils.R)
# 3. Check if we need to add a new year into the LAD to region lookup
# 4. Add the extra year to descriptions, params and validation code in
#    fetch.R
# 5. Run this script
# 6. Inspect changes to the data set, and update its entry in
#    datasets_documentation.R as needed
#
# If you hit any errors or issues with the new year, ONS may have used
# different data set ids, edit the `case_when()` in the `get_wd_pcon_lad_la()`
# or `get_lad_region()` functions to add a new condition for the latest
# year, both of these are defined in R/datasets_utils.R
#
# Data is documented, including source information in R/datasets_documentation.R
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(readxl)
library(dplyr)

# Get the main lookup ---------------------------------------------------------
# Started publishing in 2017, but didn't publish a 2018 file
wd_pcon_lad_la <- create_time_series_lookup(
  lapply(
    c(17, 19:24), # list of all individual data frames
    get_wd_pcon_lad_la # defined in R/datasets_utils.R
  )
) %>%
  dplyr::select(
    "first_available_year_included", "most_recent_year_included",
    "ward_name", "pcon_name", "lad_name", "la_name",
    "ward_code", "pcon_code", "lad_code", "new_la_code",
  )

# Get the regions lookup ------------------------------------------------------
regions_lookup <- create_time_series_lookup(
  # Skipping 2021 as not published in API
  lapply(
    c(17:20, 22:23), # list of all individual data frames
    get_lad_region # defined in R/datasets_utils.R
  )
) %>%
  # Half the regions for Scotland in 2017 were missing
  # the other half were just Scotland, so forcing them all to be
  mutate(
    region_name = if_else(grepl("^S", lad_code), "Scotland", region_name),
    region_code = if_else(grepl("^S", lad_code), "S92000003", region_code)
  ) %>%
  # Get just the unique values to join with
  dplyr::distinct(lad_name, lad_code, region_name, region_code)

# Join on regions -------------------------------------------------------------
wd_pcon_lad_la_rgn <- wd_pcon_lad_la %>%
  dplyr::left_join(
    # Join all rows that aren't missing a region name
    na.omit(regions_lookup, cols = "region_name"),
    by = c("lad_code" = "lad_code", "lad_name" = "lad_name")
  )

# Join on countries -----------------------------------------------------------
wd_pcon_lad_la_rgn_ctry <- wd_pcon_lad_la_rgn %>%
  dplyr::mutate(
    "country_name" = dplyr::case_when(
      startsWith(pcon_code, "E") ~ "England",
      startsWith(pcon_code, "S") ~ "Scotland",
      startsWith(pcon_code, "W") ~ "Wales",
      startsWith(pcon_code, "N") ~ "Northern Ireland",
      .default = "ERROR"
    ),
    "country_code" = dplyr::case_when(
      startsWith(pcon_code, "E") ~ "E92000001",
      startsWith(pcon_code, "S") ~ "S92000003",
      startsWith(pcon_code, "W") ~ "W92000004",
      startsWith(pcon_code, "N") ~ "N92000002",
      .default = "ERROR"
    )
  )

# QA the joining --------------------------------------------------------------
# Check for any rgeions that failed to join
region_error_check <- wd_pcon_lad_la_rgn_ctry %>%
  filter(
    region_code == "" | region_name == "" |
      is.na(region_name) | is.na(region_code)
  )

if (nrow(region_error_check) > 0) {
  stop("Region information failing to match, check why this is happening")
}

# Check for any countries that failed to join
country_error_check <- wd_pcon_lad_la_rgn_ctry %>%
  filter(country_code == "ERROR" | country_name == "ERROR")

if (nrow(country_error_check) > 0) {
  stop("Country information failing to match, check why this is happening")
}

# Manual fixes ----------------------------------------------------------------
# !IMPORTANT! Make sure to log all of these in the description for the file in
# the `R/datasets_documentation.R` script
wd_pcon_lad_la_rgn_ctry <- wd_pcon_lad_la_rgn_ctry %>%
  # ONS seemed to miss a 0 in 2017 for Glasgow East PCon
  mutate(across(everything(), ~ ifelse(. == "S1400030", "S14000030", .)))

# Set the order of the columns ------------------------------------------------
wd_pcon_lad_la_rgn_ctry <- wd_pcon_lad_la_rgn_ctry %>%
  dplyr::select(
    "first_available_year_included", "most_recent_year_included",
    "ward_name", "pcon_name", "lad_name", "la_name",
    "region_name", "country_name",
    "ward_code", "pcon_code", "lad_code", "new_la_code",
    "region_code", "country_code"
  )

# Write the data into the package ---------------------------------------------
usethis::use_data(wd_pcon_lad_la_rgn_ctry, overwrite = TRUE)
