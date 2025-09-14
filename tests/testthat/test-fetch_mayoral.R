test_that("Gives a data frame", {
  expect_true(is.data.frame(fetch_mayoral()))
})

test_that("Has no duplicate rows", {
  expect_true(!anyDuplicated(fetch_mayoral()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These tests will fail if there are genuine changes to the locations
# Manual counts from ONS Open Geography Portal
test_that("2025 locations match what we expect", {
  expect_equal(nrow(fetch_mayoral(2025)), 15)
})

# Checking an extra year so we know the year filtering works for past years
test_that("2022 locations match what we expect", {
  expect_equal(nrow(fetch_mayoral(2022)), 10)
})

# Checking the first year so we know the year filtering works
test_that("2017 locations match what we expect", {
  expect_equal(nrow(fetch_mayoral(2017)), 9)
})
