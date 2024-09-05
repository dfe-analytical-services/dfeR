## code to prepare `ons_geog_shorthands` dataset goes here

ons_level_shorthands <- c("WD", "PCON", "LAD", "UTLA", "GOR", "RGN", "CTRY")
name_column <- paste0(c("ward", "pcon", "lad", "la", "region", "region", "country"), "_name")
code_column <- paste0(c("ward", "pcon", "lad", "new_la", "region", "region", "country"), "_code")

ons_geog_shorthands <- data.frame(
  ons_level_shorthands,
  name_column,
  code_column
)

usethis::use_data(ons_geog_shorthands, overwrite = TRUE)
