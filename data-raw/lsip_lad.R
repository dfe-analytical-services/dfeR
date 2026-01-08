# ------------------------------------------------------------------------------
# Script to create the LSIP-LAD lookup dataset for the dfeR package
#
# This script fetches, processes, and saves the Local Authority District (LAD)
# to Local Skills Improvement Plan (LSIP) lookup for multiple years.
#
# Data Source:
#   - ONS Open Geography Portal API (https://geoportal.statistics.gov.uk/)
#   - Each year's data is accessed via a unique ArcGIS REST API endpoint from
#     the ONS Geography portal x, constructed from a common prefix, a
#     year-specific path, and a query suffix. See the get_lsip_lad() function
#     in R/datasets_utils.R for details on URL construction and year coverage.
# What this script does:
#   1. Calls get_lsip_lad() to fetch and combine LSIP-LAD data
#      for all available years.
#   2. The resulting data frame includes columns for LAD and LSIP codes
#      and names, the year, and operational period columns.
#   3. Saves the processed lookup as an internal package dataset.
#
# Usage:
#   - Run this code when new LSIP-LAD data is available or to refresh the lookup
#   - Ensure get_lsip_lad() is up to date with the correct endpoints for all
#     years required.
# How to update the data:
#   1. Check the ONS Open Geography Portal for new or updated LSIP-LAD datasets
#      and note the new URLs.
#   2. Update the `yr_specific_url` list in get_lsip_lad() (R/datasets_utils.R)
#      to include the section of the URL that corresponds to that year.
#   3. Run this script to fetch, process, and save the latest data.
#   4. Re-document and test the package as needed.
#
# ------------------------------------------------------------------------------

# use get_lsip_lad to get the data from ONS
lsip_lad <- get_lsip_lad()

# Save the data to the package's data directory
usethis::use_data(lsip_lad, overwrite = TRUE)
