# Create a data frame for testing

df <- data.frame(
  a = c(1, 2, 3, as.double(NA)),
  b = c(1, 2, as.double(NA), 4),
  school_name = c("school1", "school2", NA_character_, "school3"),
  time_period = c(2008, 2023, 2024, as.double(NA))
)

test_that("z_replace outputs are as expected", {
  # testing standard functionality
  expect_equal(z_replace(df), data.frame(
    a = c("1", "2", "3", "z"),
    b = c("1", "2", "z", "4"),
    school_name = c("school1", "school2", NA_character_, "school3"),
    time_period = c(2008, 2023, 2024, as.double(NA))
  ))

  # testing alternative replacement

  expect_equal(z_replace(df, replacement_alt = "x"), data.frame(
    a = c("1", "2", "3", "x"),
    b = c("1", "2", "x", "4"),
    school_name = c("school1", "school2", NA_character_, "school3"),
    time_period = c(2008, 2023, 2024, as.double(NA))
  ))


  expect_equal(z_replace(df, replacement_alt = "c"), data.frame(
    a = c("1", "2", "3", "c"),
    b = c("1", "2", "c", "4"),
    school_name = c("school1", "school2", NA_character_, "school3"),
    time_period = c(2008, 2023, 2024, as.double(NA))
  ))
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

# calculating the time it takes
test_time <- summary(microbenchmark::microbenchmark(z_replace(df),
  unit = "seconds", times = 100
))$max

# testing that the speed is less than 1 second
test_that("Speed of the function", {
  expect_equal(test_time < 1, TRUE)
})

# Check error message

# create table
df <- data.frame()

test_that("Error messages are as expected", {
  expect_error(z_replace(df))

  expect_error(z_replace(df, replacement_alt = "x"))
})
