# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Get a list of potential location and time columns
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(dplyr)

# get geography column names from geography_matrix.csv

geog_levels <- read.csv("data/geography_matrix.csv")

# extract relevant column names from geography_matrix.csv
geog_col_names <- c(
  "geographic_level",
  geog_levels$code_field,
  geog_levels$name_field,
  geog_levels$code_field_secondary
)

# remove NA values

geog_col_names <- geog_col_names[!is.na(geog_col_names)]

# write column names for time

time_col_names <- c("time_period", "time_identifier")

# put the time and location vectors together

geog_time_identifiers <- c(geog_col_names, time_col_names)

# write it out to the data folder

usethis::use_data(geog_time_identifiers, overwrite = TRUE)
