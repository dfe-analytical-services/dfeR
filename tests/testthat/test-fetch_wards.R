test_that("Gives a data frame", {
  expect_true(is.data.frame(fetch_wards()))
})

test_that("Has no duplicate rows", {
  expect_true(!anyDuplicated(fetch_wards()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Snapshot tests to check numbers over time
test_that("number of locations stays consistent", {
  years <- c(2017:2025)
  countries <- c("All") # just doing "All" for speed, as full takes > 15secs

  expect_snapshot(fetch_location_counts(fetch_wards, years, countries))
})
