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
    paste0(
      "You provided a numeric input for replacement_alt.\n",
      "Please amend replace it with a character vector."
    )
  )

  # testing error for multiple vectors in replacement_alt
  expect_error(
    z_replace(df, replacement_alt = c("a", "z", "x")),
    paste0(
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
  expect_error(z_replace(df))
})
