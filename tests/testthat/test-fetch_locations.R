test_that("fetch_locations gives a data frame", {
  expect_true(is.data.frame(fetch_pcons()))
  # expect_true(is.data.frame(fetch_lads()))
  # expect_true(is.data.frame(fetch_las()))
})

test_that("fetch_locations have no duplicate rows", {
  expect_true(!anyDuplicated(fetch_pcons()))
  # expect_true(!anyDuplicated(fetch_lads()))
  # expect_true(!anyDuplicated(fetch_las()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These tests will fail if there are genuine changes to the locations
# Counts of locations done manually from the data screener repo lookup we had
test_that("year filtering works as expected", {
  # PCONs
  expect_equal(nrow(fetch_pcons()), 678888888)

  expect_equal(nrow(fetch_pcons(c("2024", "2023"))), 678888888)

  # LADs

  # LAs
})

test_that("2024 locations match what we expect", {
  # PCONs
  expect_equal(nrow(fetch_pcons("2024")), 650)
  expect_equal(nrow(fetch_pcons("2024", c("England", "Scotland"))), 600)
  expect_equal(nrow(fetch_pcons("2024", "England")), 543)
  expect_equal(nrow(fetch_pcons("2024", "Scotland")), 57)
  expect_equal(nrow(fetch_pcons("2024", "Wales")), 32)
  expect_equal(nrow(fetch_pcons("2024", "Northern Ireland")), 18)

  # # LADs
  # expect_equal(nrow(fetch_lads("2024")), 361)
  # expect_equal(nrow(fetch_lads("2024", c("England", "Wales"))), 328)
  # expect_equal(nrow(fetch_lads("2024", "England")), 296)
  # expect_equal(nrow(fetch_lads("2024", "Scotland")), 32)
  # expect_equal(nrow(fetch_lads("2024", "Wales")), 22)
  # expect_equal(nrow(fetch_lads("2024", "Northern Ireland")), 11)
  #
  # # LAs
  # expect_equal(nrow(fetch_las("2024")), 220)
  # expect_equal(nrow(fetch_las("2024", c("England", "Scotland", "Wales"))), 209)
  # expect_equal(nrow(fetch_las("2024", "England")), 153)
  # expect_equal(nrow(fetch_las("2024", "Scotland")), 32)
  # expect_equal(nrow(fetch_las("2024", "Wales")), 22)
  # expect_equal(nrow(fetch_las("2024", "Northern Ireland")), 11)
})

# Comparison against existing screener lookup (add to PR notes)

screener <- read.csv("https://raw.githubusercontent.com/dfe-analytical-services/dfe-published-data-qa/main/data/ward_lad_la_pcon_hierarchy.csv")

waldo::compare(
  screener,
  dfeR::wd_pcon_lad_la
)
