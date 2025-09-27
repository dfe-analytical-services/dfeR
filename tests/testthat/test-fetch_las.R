test_that("Gives a data frame", {
  expect_true(is.data.frame(fetch_las()))
})

test_that("Has no duplicate rows", {
  expect_true(!anyDuplicated(fetch_las()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Snapshot tests to check numbers over time
test_that("number of locations stays consistent", {
  years <- c(2017:2025)
  countries <- c("All", "England", "Scotland", "Wales", "Northern Ireland")

  expect_snapshot(fetch_location_counts(fetch_las, years, countries))
})
