# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Get a list of regions and codes from ONS API
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
  outFields = paste0("RGN", year_end, "CD,RGN", year_end, "NM"),
  outSR = 4326,
  f = "json"
)

# Run query -------------------------------------------------------------------
ons_regions <- dfeR::get_ons_api_data(
  paste0("RGN_DEC_", year, "_EN_NC"), # data set uses 4 digit year
  query_params = params
) |>
  dplyr::rename(
    "region_name" = paste0("attributes.RGN", year_end, "NM"),
    "region_code" = paste0("attributes.RGN", year_end, "CD")
  )

# Set custom DfE regions ------------------------------------------------------
custom_dfe_regions <- data.frame(
  "region_name" = c(
    "Inner London", # This is a county we tend to publish as a region
    "Outer London", # This is a county we tend to publish as a region
    "Outside of England and unknown",
    "Outside of the United Kingdom and unknown",
    "Outside of England",
    "Outside of United Kingdom",
    "Unknown"
  ),
  "region_code" = c("E13000001", "E13000002", "z", "z", "z", "z", "z")
)

# Stack into one data frame and write out -------------------------------------
regions <- rbind(ons_regions, custom_dfe_regions)

usethis::use_data(regions, overwrite = TRUE)
