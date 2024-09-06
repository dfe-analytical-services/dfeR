# Get a list of regions and codes from ONS API

params <- list(
  where = "1=1",
  outFields = "RGN23CD,RGN23NM",
  outSR = 4326,
  f = "json"
)

ons_regions <- dfeR::get_ons_api_data(
  "RGN_DEC_2023_EN_NC",
  query_params = params
) |>
  dplyr::rename(
    "region_name" = attributes.RGN23NM,
    "region_code" = attributes.RGN23CD
  )

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

regions <- rbind(ons_regions, custom_dfe_regions)

usethis::use_data(regions, overwrite = TRUE)
