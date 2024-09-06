# Get a list of countries and codes from ONS API

params <- list(
  where = "1=1",
  outFields = "CTRY23CD,CTRY23NM",
  outSR = 4326,
  f = "json"
)

ons_countries <- dfeR::get_ons_api_data(
  "CTRY_DEC_2023_UK_NC",
  query_params = params
) |>
  dplyr::rename(
    "country_name" = attributes.CTRY23NM,
    "country_code" = attributes.CTRY23CD
  )

custom_dfe_countries <- data.frame(
  "country_name" = c(
    "England, Wales and Northern Ireland", "Outside of England and unknown",
    "Outside of the United Kingdom and unknown"
  ),
  "country_code" = c("z", "z", "z")
)

countries <- rbind(ons_countries, custom_dfe_countries)

usethis::use_data(countries, overwrite = TRUE)
