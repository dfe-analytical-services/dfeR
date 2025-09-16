# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Get a list of potential location and time columns
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# create a vector of possible time and geography column names
geog_time_identifiers <- c(
  "geographic_level", "country_code", "region_code", "new_la_code", "lad_code",
  "pcon_code", "lsip_code", "local_enterprise_partnership_code",
  "english_devolved_area_code", "opportunity_area_code", "ward_code",
  "trust_id", "sponsor_id", "school_urn", "provider_ukprn", "institution_id",
  "planning_area_code", "country_name", "region_name", "la_name", "lad_name",
  "rsc_region_lead_name", "pcon_name", "lsip_name",
  "local_enterprise_partnership_name", "english_devolved_area_name",
  "opportunity_area_name", "ward_name", "trust_name", "sponsor_name",
  "school_name", "provider_name", "institution_name", "planning_area_name",
  "old_la_code", "school_laestab", "time_period", "time_identifier"
)

# write it out to the data folder

usethis::use_data(geog_time_identifiers, overwrite = TRUE)
