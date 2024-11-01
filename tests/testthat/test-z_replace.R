# Create a data frame for testing

df <- data.frame(
  time_period = c(2022, 2022, 2022),
  time_identifier = c("Calendar year", "Calendar year", "Calendar year"),
  geographic_level = c("National", "Regional", "Regional"),
  country_code = c("E92000001", "E92000001", "E92000001"),
  country_name = c("England", "England", "England"),
  region_code = c(NA, "E12000001", "E12000002"),
  region_name = c(NA, "North East", "North West"),
  mystery_count = c(42, 25, NA)
)

test_that("z_replace outputs are as expected", {
  # testing standard functionality
  expect_equal(z_replace(df), data.frame(
    time_period = c(2022, 2022, 2022),
    time_identifier = c("Calendar year", "Calendar year", "Calendar year"),
    geographic_level = c("National", "Regional", "Regional"),
    country_code = c("E92000001", "E92000001", "E92000001"),
    country_name = c("England", "England", "England"),
    region_code = c(NA, "E12000001", "E12000002"),
    region_name = c(NA, "North East", "North West"),
    mystery_count = c(42, 25, "z")
  ))

  # testing alternative replacement

  expect_equal(z_replace(df, replacement_alt = "x"), data.frame(
    time_period = c(2022, 2022, 2022),
    time_identifier = c("Calendar year", "Calendar year", "Calendar year"),
    geographic_level = c("National", "Regional", "Regional"),
    country_code = c("E92000001", "E92000001", "E92000001"),
    country_name = c("England", "England", "England"),
    region_code = c(NA, "E12000001", "E12000002"),
    region_name = c(NA, "North East", "North West"),
    mystery_count = c(42, 25, "x")
  ))


  expect_equal(z_replace(df, replacement_alt = "c"), data.frame(
    time_period = c(2022, 2022, 2022),
    time_identifier = c("Calendar year", "Calendar year", "Calendar year"),
    geographic_level = c("National", "Regional", "Regional"),
    country_code = c("E92000001", "E92000001", "E92000001"),
    country_name = c("England", "England", "England"),
    region_code = c(NA, "E12000001", "E12000002"),
    region_name = c(NA, "North East", "North West"),
    mystery_count = c(42, 25, "c")
  ))
})

# check error messages for non-empty data frames

test_that("Error messages are as expected in non-empty frames", {
  # testing error for non character strings in replacement_alt
  expect_error(
    z_replace(df, replacement_alt = 1),
    cat(
      "You provided a numeric input for replacement_alt.\n",
      "Please amend replace it with a character vector."
    )
  )

  # testing error for multiple vectors in replacement_alt
  expect_error(
    z_replace(df, replacement_alt = c("a", "z", "x")),
    cat(
      "You provided multiple values for replacement_alt.\n",
      "Please, only provide a single value."
    )
  )
})
# Create a table to text exclude_columns

df <- data.frame(
  a = c("1", "2", "3", "z"),
  b = c("1", "2", "z", "4"),
  county_name = c("county1", "county2", NA_character_, "county3"),
  country_code = c("country1", NA_character_, "country2", "country3"),
  time_period = c(2008, 2023, 2024, as.double(NA))
)

# without including county_name in exclude_columns
test_that("exclude_columns works", {
  # without including county_name in exclude_columns
  expect_equal(z_replace(df), data.frame(
    a = c("1", "2", "3", "z"),
    b = c("1", "2", "z", "4"),
    county_name = c("county1", "county2", "z", "county3"),
    country_code = c("country1", NA_character_, "country2", "country3"),
    time_period = c(2008, 2023, 2024, as.double(NA))
  ))


  # including county_name in exclude_columns
  expect_equal(z_replace(df, exclude_columns = "county_name"), data.frame(
    a = c("1", "2", "3", "z"),
    b = c("1", "2", "z", "4"),
    county_name = c("county1", "county2", NA_character_, "county3"),
    country_code = c("country1", NA_character_, "country2", "country3"),
    time_period = c(2008, 2023, 2024, as.double(NA))
  ))
})


# Checking speed of the function

# make this reproducible
set.seed(123)
# create table with randomly generated numbers
df <- data.frame(
  a = sample(1:1000, 10000, replace = TRUE),
  b = sample(1:1000, 10000, replace = TRUE),
  c = sample(1:1000, 10000, replace = TRUE),
  d = sample(1:1000, 10000, replace = TRUE),
  e = sample(1:1000, 10000, replace = TRUE),
  f = sample(1:1000, 10000, replace = TRUE),
  e = sample(1:1000, 10000, replace = TRUE),
  h = sample(1:1000, 10000, replace = TRUE),
  i = sample(1:1000, 10000, replace = TRUE),
  j = sample(1:1000, 10000, replace = TRUE),
  school_urn = sample(1:1000, 10000, replace = TRUE)
)

# putting NAs in the table
df <- df %>%
  dplyr::mutate(across(
    a:school_urn,
    ~ dplyr::if_else(. < 300, as.double(NA), .)
  ))

start_time <- Sys.time()
z_replace(df)
end_time <- Sys.time()
test_time <- difftime(end_time, start_time, units = "secs")

# calculating the time it takes
test_time <- summary(microbenchmark::microbenchmark(z_replace(df),
  unit = "seconds", times = 100
))$max

print(test_time)

# testing that the speed is less than 1 second
test_that("Speed of the function", {
  expect_equal(test_time < 1, TRUE)
})

# Check error message for empty data frame

# create table
df <- data.frame()

test_that("Error messages are as expected", {
  expect_error(z_replace(df), "Table is empty or contains no rows.")

  expect_error(
    z_replace(df, replacement_alt = "x"),
    "Table is empty or contains no rows."
  )
})


# Check error messages for when tables contain geography
# and time columns from th ees screener but different formatting

df <- data.frame(
  GEOGRAPHIC_LEVEL = c("level1", "level2", "level3", NA_character_),
  time_period = c(2008, 2023, 2024, as.double(NA))
)

test_that("Formatting of column names are checked", {
  expect_error(
    z_replace(df),
    cat(
      "Your table has geography and/or time column(s) that are not",
      "in snake_case.\nPlease amend your column names to match the formatting",
      "to dfeR::geog_time_identifiers."
    )
  )
})
