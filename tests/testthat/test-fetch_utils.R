# Unit tests for check_fetch_location_inputs and fetch_locations functions

# Test cases for check_fetch_location_inputs
test_that("check_fetch_location_inputs errors on invalid year", {
  expect_error(
    check_fetch_location_inputs("202A", "All"),
    "year must either be 'All'"
  )
  expect_error(
    check_fetch_location_inputs(202, "All"),
    "year must either be 'All'"
  )
})

test_that("check_fetch_location_inputs errors on invalid country", {
  expect_error(
    check_fetch_location_inputs("2024", "France"),
    "countries must either be 'All'"
  )
  expect_error(
    check_fetch_location_inputs("2024", c("England", "France")),
    "countries must either be 'All'"
  )
})

test_that("check_fetch_location_inputs passes for valid inputs", {
  expect_silent(check_fetch_location_inputs("All", "All"))
  expect_silent(check_fetch_location_inputs(2024, "England"))
  expect_silent(check_fetch_location_inputs(2024, c("England", "Wales")))
})

# Minimal mock data for fetch_locations
mock_lookup <- data.frame(
  code = c("E1", "S1", "W1", "N1"),
  name = c("A", "B", "C", "D"),
  first_available_year_included = c(2020, 2020, 2020, 2020),
  most_recent_year_included = c(2022, 2021, 2020, 2022)
)

# Test fetch_locations returns all when defaults
test_that("fetch_locations returns all locations for 'All'", {
  result <- fetch_locations(mock_lookup, c("code", "name"), "All", "All")
  expect_equal(nrow(result), 4)
  expect_equal(sort(result$code), sort(mock_lookup$code))
})

# Test fetch_locations filters by year
test_that("fetch_locations filters by year", {
  result <- fetch_locations(mock_lookup, c("code", "name"), 2021, "All")
  expect_true(all(result$code %in% c("E1", "S1", "N1")))
  expect_false("W1" %in% result$code)
})

test_that("summarise_locations_by_year works as expected", {
  data <- data.frame(
    lad_code = c("A", "A", "B"),
    lad_name = c("Alpha", "Alpha", "Beta"),
    lsip_code = c("X", "X", "Y"),
    lsip_name = c("X-ray", "X-ray", "Yankee"),
    first_available_year_included = c(2020, 2020, 2021),
    most_recent_year_included = c(2022, 2022, 2023)
  )
  cols <- c("lad_code", "lad_name", "lsip_code", "lsip_name")
  # All years
  res <- summarise_locations_by_year(data, cols, year = "All")
  expect_equal(nrow(res), 2)
  expect_true(all(
    c("lad_code", "lad_name", "lsip_code", "lsip_name") %in% names(res)
  ))
  # Filter by year
  res2 <- summarise_locations_by_year(data, cols, year = 2021)
  expect_true(all(
    res2$first_available_year_included <= 2021 &
      res2$most_recent_year_included >= 2021
  ))
  expect_false("first_available_year_included" %in% names(res2))
  expect_false("most_recent_year_included" %in% names(res2))
})
