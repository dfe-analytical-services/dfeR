test_that("Gives a data frame", {
  expect_true(is.data.frame(fetch_lads()))
})

test_that("Has no duplicate rows", {
  expect_true(!anyDuplicated(fetch_lads()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These tests will fail if there are genuine changes to the locations
# Counts of locations done manually from the data screener repo lookup we had
#
# Did this kind of thing against the screener lookup file to get the numbers
# Make a new column for in_2022 with =AND(2022 >= $A2, 2022 <= $B2)
# Filter to TRUE values only and remove duplcates

test_that("2024 locations match what we expect", {
  expect_equal(nrow(fetch_lads(2024)), 361)
  expect_equal(nrow(fetch_lads(2024, c("England", "Wales"))), 318)
  expect_equal(nrow(fetch_lads(2024, "England")), 296)
  expect_equal(nrow(fetch_lads(2024, "Scotland")), 32)
  expect_equal(nrow(fetch_lads(2024, "Wales")), 22)
  expect_equal(nrow(fetch_lads(2024, "Northern Ireland")), 11)
})

# Checking an extra year so we know the year filtering works for past years
test_that("2022 locations match what we expect", {
  expect_equal(nrow(fetch_lads(2022)), 374)
  expect_equal(nrow(fetch_lads(2022, c("England", "Wales"))), 331)
  expect_equal(nrow(fetch_lads(2022, "England")), 309)
  expect_equal(nrow(fetch_lads(2022, "Scotland")), 32)
  expect_equal(nrow(fetch_lads(2022, "Wales")), 22)
  expect_equal(nrow(fetch_lads(2022, "Northern Ireland")), 11)
})

# Checking the first year so we know the year filtering works
test_that("2017 locations match what we expect", {
  expect_equal(nrow(fetch_lads(2017)), 391)
  expect_equal(nrow(fetch_lads(2017, c("England", "Wales"))), 348)
  expect_equal(nrow(fetch_lads(2017, "England")), 326)
  expect_equal(nrow(fetch_lads(2017, "Scotland")), 32)
  expect_equal(nrow(fetch_lads(2017, "Wales")), 22)
  expect_equal(nrow(fetch_lads(2017, "Northern Ireland")), 11)
})
