# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create the wd_pcon_lad_la_reg_ctry data set
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# This data is created by joining wd_pcon_lad_la
# - https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
# and lad_region from these lookups
# - https://geoportal.statistics.gov.uk/search?q=lup_wd_lad_cty_rgn_gor_ctry
#
# We make some small changes to these currently, more details are in the
# public facing documentation in R/datasets_documentation.R and the functions
# in R/datasets_utils.R.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# To update this data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# 1. Load the package using `devtools::load_all(".")`
#
# 2. Edit the years set near the start of this script to those you want to
#    create for (often, just add one new one to the end!)
#
# 3. Run this script to generate and save a new data file
#
# 4. Run the tests (ctrl-shft-t) and package checks (ctrl-shft-e)
#
# 5. Inspect changes to the data set, and update its entry in
#    datasets_documentation.R as needed, updating the tests afterwards if
#    appropriate
#
# 6. Update the options listed for the year @param in the fetch.R @description
#
# 7. Re-document the package (ctrl-shft-d)
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Common potential issues with this data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# 1. ONS like to vary their data set ids
#    You may need edit the `case_when()` in the `get_wd_pcon_lad_la()`
#    or `get_lad_region()` functions to add a new condition for the latest
#    year, both of these are defined in R/datasets_utils.R
#
# 2. Watch out for standard column names changing
#    Double check the Open Geography Portal for the latest source data and make
#    sure the output from the API for the latest file matches up with previous
#    years
#
# 3. Regions not joining
#    The two files are published out of sync, so the years aren't a perfect
#    match. It's pretty possible that in the future we may need to do some
#    manual joins. In this case add them to the bottom section and make sure
#    to document in R/datasets_documentation.R, as well as giving the source
#    for where you found the details from.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(readxl)
library(dplyr)

# Set the years we want to pull for -------------------------------------------
# Started publishing in 2017, but didn't publish a 2018 file
wd_pcon_lad_la_years <- c(2017, 2019:2024)

# Skipping 2021 as not published in API for lad_region and we have enough
# coverage from other years to join without any gaps
lad_region_years <- c(2017:2020, 2022:2023)

# Get the main lookup ---------------------------------------------------------
# Functions defined in R/datasets_utils.R
# Start with a list of individual data frames per year
wd_pcon_lad_la <- lapply(wd_pcon_lad_la_years, get_wd_pcon_lad_la) |>
  create_time_series_lookup() |> # smush together into single data frame
  dplyr::select(
    "first_available_year_included", "most_recent_year_included",
    "ward_name", "pcon_name", "lad_name", "la_name",
    "ward_code", "pcon_code", "lad_code", "new_la_code",
  )

# Get the regions lookup ------------------------------------------------------
regions_lookup <- lapply(lad_region_years, get_lad_region) |>
  create_time_series_lookup() |>
  # Half the regions for Scotland in 2017 were missing
  # the other half were just Scotland, so forcing them all to be Scotland
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

# Manual fixes ----------------------------------------------------------------
# !IMPORTANT! Make sure to log all of these in the description for the file in
# the `R/datasets_documentation.R` script
wd_pcon_lad_la_rgn_ctry <- wd_pcon_lad_la_rgn_ctry %>%
  # ONS seemed to miss a 0 in 2017 for Glasgow East PCon
  mutate(across(everything(), ~ ifelse(. == "S1400030", "S14000030", .)))

# Add 3 digit local authority codes from GIAS  ----------------------------
wd_pcon_lad_la_rgn_ctry <- wd_pcon_lad_la_rgn_ctry %>%
  # join the data onto the GIAs LA 3 digit code data
  dplyr::left_join(gias_3_digit_la_codes, by = c(
    "la_name" = "la_name",
    "new_la_code" = "new_la_code",
    "old_la_code" = "old_la_code"
  )) %>%
  dplyr::mutate(old_la_code = dplyr::if_else(is.na(old_la_code),
    "z", old_la_code
  )) %>%
  dplyr::distinct()

# Set the order of the columns ------------------------------------------------
wd_pcon_lad_la_rgn_ctry <- wd_pcon_lad_la_rgn_ctry %>%
  dplyr::select(
    "first_available_year_included", "most_recent_year_included",
    "ward_name", "pcon_name", "lad_name", "la_name",
    "region_name", "country_name",
    "ward_code", "pcon_code", "lad_code", "new_la_code",
    "region_code", "country_code"
  )

# QA the joining --------------------------------------------------------------
# Check for any regions that failed to join
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

# Write the data into the package ---------------------------------------------
usethis::use_data(wd_pcon_lad_la_rgn_ctry, overwrite = TRUE)
