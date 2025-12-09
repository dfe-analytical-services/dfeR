# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Get a list of countries and codes from ONS API
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Set the year ----------------------------------------------------------------
year <- 2023
year_end <- 23

test_that("`year` ends in `year_end`", {
  expect_true(grepl(paste0(year_end, "$"), year))
})

# Set query parameters --------------------------------------------------------
params <- list(
  where = "1=1",
  outFields = paste0("CTRY", year_end, "CD,CTRY", year_end, "NM"),
  outSR = 4326,
  f = "json"
)

# Run the query ---------------------------------------------------------------
ons_countries <- dfeR::get_ons_api_data(
  paste0("CTRY_DEC_", year, "_UK_NC"),
  query_params = params
) |>
  dplyr::rename(
    "country_name" = paste0("attributes.CTRY", year_end, "NM"),
    "country_code" = paste0("attributes.CTRY", year_end, "CD")
  )

# Set custom DfE countries ----------------------------------------------------
custom_dfe_countries <- data.frame(
  "country_name" = c(
    "England, Wales and Northern Ireland",
    "Outside of England and unknown",
    "Outside of the United Kingdom and unknown"
  ),
  "country_code" = c("z", "z", "z")
)

# Stack into one data frame and write out -------------------------------------
countries <- rbind(ons_countries, custom_dfe_countries)

usethis::use_data(countries, overwrite = TRUE)
