# ------------------------------------------------------------------------------
# Script to create the LSIP-LAD lookup dataset for the dfeR package
#
# This script fetches, processes, and saves the Local Authority District (LAD) to
# Local Skills Improvement Plan (LSIP) lookup for multiple years.
#
# Data Source:
#   - ONS Open Geography Portal API (https://geoportal.statistics.gov.uk/)
#   - Each year's data is accessed via a unique ArcGIS REST API endpoint, constructed from a common
#     prefix, a year-specific path, and a query suffix. See the get_lsip_lad() function
#     in R/datasets_utils.R for details on URL construction and year coverage.
#   - Example endpoint:
#     https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LAD25_LSIP25_EN_LU/FeatureServer/0/query?outFields=*&where=1%3D1&f=json
#
# How to update the data:
#   1. Check the ONS Open Geography Portal for new or updated LSIP-LAD datasets and note the new endpoints.
#   2. Update the `yr_specific_url` object in get_lsip_lad() (R/datasets_utils.R) to include new years or revised endpoints.
#   3. Run this script to fetch, process, and save the latest data.
#   4. Re-document and test the package as needed.
#
# What this script does:
#   1. Calls get_lsip_lad() to fetch and combine LSIP-LAD data for all available years.
#   2. The resulting data frame includes columns for LAD and LSIP codes and names, the year,
#      and operational period columns (first_available_year_included, most_recent_year_included).
#   3. Saves the processed lookup as an internal package dataset for use in dfeR.
#
# Usage:
#   - Run this script whenever new LSIP-LAD data is available or to refresh the lookup.
#   - Ensure get_lsip_lad() is up to date with the correct endpoints for all years required.
# ------------------------------------------------------------------------------

# use get_lsip_lad to get the data from ONS
lsip_lad <- get_lsip_lad()

# Save the data to the package's data directory
usethis::use_data(lsip_lad, overwrite = TRUE)
