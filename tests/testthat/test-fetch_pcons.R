test_that("fetch_locations gives a data frame", {
  expect_true(is.data.frame(fetch_pcons()))
})

test_that("fetch_locations have no duplicate rows", {
  expect_true(!anyDuplicated(fetch_pcons()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These tests will fail if there are genuine changes to the locations
# Counts of locations done manually from the data screener repo lookup we had
test_that("2024 locations match what we expect", {
  # Used the parly website to get numbers
  # https://www.parliament.uk/about/how/elections-and-voting/constituencies/
  expect_equal(nrow(fetch_pcons(2024)), 650)
  expect_equal(nrow(fetch_pcons(2024, c("England", "Scotland"))), 600)
  expect_equal(nrow(fetch_pcons(2024, "England")), 543)
  expect_equal(nrow(fetch_pcons(2024, "Scotland")), 57)
  expect_equal(nrow(fetch_pcons(2024, "Wales")), 32)
  expect_equal(nrow(fetch_pcons(2024, "Northern Ireland")), 18)
})

# Checking an extra year so we know the year filtering works for past years
test_that("2022 locations match what we expect", {
  # Did this kind of thing against the screener lookup file to get the numbers
  # Make a new column for in_2022 with =AND(2022 >= $A2, 2022 <= $B2)
  # Filter to TRUE values only and remove duplcates

  expect_equal(nrow(fetch_pcons(2022)), 650)
  expect_equal(nrow(fetch_pcons(2022, c("England", "Scotland"))), 592)
  expect_equal(nrow(fetch_pcons(2022, "England")), 533)
  expect_equal(nrow(fetch_pcons(2022, "Scotland")), 59)
  expect_equal(nrow(fetch_pcons(2022, "Wales")), 40)
  expect_equal(nrow(fetch_pcons(2022, "Northern Ireland")), 18)
})

# Checking the first year so we know the year filtering works
test_that("2017 locations match what we expect", {
  # Did this kind of thing against the screener lookup file to get the numbers
  # Make a new column for in_2017 with =AND(2017 >= $A2, 2017 <= $B2)
  # Filter to TRUE values only and remove duplcates

  expect_equal(nrow(fetch_pcons(2017)), 650)
  expect_equal(nrow(fetch_pcons(2017, c("England", "Scotland"))), 592)
  expect_equal(nrow(fetch_pcons(2017, "England")), 533)
  expect_equal(nrow(fetch_pcons(2017, "Scotland")), 59)
  expect_equal(nrow(fetch_pcons(2017, "Wales")), 40)
  expect_equal(nrow(fetch_pcons(2017, "Northern Ireland")), 18)
})
