# ------------------------------------------------------------------------------
# Script to create the LSIP-LAD lookup dataset for the dfeR package
#
# This script fetches, processes, and saves the Local Authority District (LAD)
# to Local Skills Improvement Plan (LSIP) lookup for multiple years
# using the internal get_lsip_lad() helper and create_time_series_lookup().
#
# Data Source:
#   - ONS Open Geography Portal API (https://geoportal.statistics.gov.uk/)
#   - Each year's data is accessed via a unique ArcGIS REST API endpoint from
#     the ONS Geography portal, with the correct endpoints managed in the
#     get_lsip_lad() helper (see R/datasets_utils.R for details).
# What this script does:
#   1. Calls get_lsip_lad() to fetch and combine LSIP-LAD data for all
#      available years.
#   2. Uses create_time_series_lookup() to add operational period columns
#      and combine years.
#   3. Saves the processed lookup as an internal package dataset.
#
# Usage:
#   - Run this code when new LSIP-LAD data is available or to refresh the
#     lookup.
#   - To add a new year, update the yr_specific_url list in get_lsip_lad()
#     (see R/datasets_utils.R).
# How to update the data:
#   1. Check the ONS Open Geography Portal for new or updated LSIP-LAD datasets.
#   2. Update the yr_specific_url list in get_lsip_lad() to include the new
#      year and endpoint.
#   3. Run this script to fetch, process, and save the latest data.
#   4. Re-document and test the package as needed.
#
# ------------------------------------------------------------------------------


# Fetch and combine LSIP-LAD data for all available years using get_lsip_lad()
# First boundaries published in 2023, ONS didn't publish a 2024 set

# Fetch and combine LSIP-LAD data for all available years using get_lsip_lad()
# First boundaries published in 2023, ONS didn't publish a 2024 set
lsip_lad <- lapply(c(2023, 2025), get_lsip_lad) |>
  create_time_series_lookup()

# Save the data to the package's data directory
usethis::use_data(lsip_lad, overwrite = TRUE)
