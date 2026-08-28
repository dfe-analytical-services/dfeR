# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create the lsip_lad data set
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# A lookup of local skills improvement plan (LSIP) areas to local authority
# districts (LADs) in England, taken from
# - https://geoportal.statistics.gov.uk/search?q=lad%20lsip
#
# The get_lsip_lad() function used in this script is stored in
# R/datasets_utils.R, in there you can see the details of how we query the API
# and any transformations we apply to the data within that function.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# To update this data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# 1. Load the package using `devtools::load_all(".")`
#
# 2. Add the new year to the vector in the lapply() below (get_lsip_lad() works
#    out the ONS data set id from the year for you)
#
# 3. Run this script to generate and save a new data file
#
# 4. Run the tests (ctrl-shft-t) and package checks (ctrl-shft-e)
#
# 5. Inspect changes to the data set, and update its entry in
#    datasets_documentation.R as needed, updating the tests afterwards if
#    appropriate
#
# 6. Update fetch_lsips() in fetch.R in both of the places the years are
#    listed, the valid_years vector passed to check_fetch_location_inputs()
#    and the options listed for the year @param. The valid_years vector is
#    what stops years ONS never published (such as 2024) being accepted
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# First boundaries published in 2023, ONS didn't publish a 2024 set
lsip_lad <- lapply(c(2023, 2025), get_lsip_lad) |>
  create_time_series_lookup()

# Save the data to the package's data directory
usethis::use_data(lsip_lad, overwrite = TRUE)
