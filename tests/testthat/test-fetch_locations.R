test_that("fetch_locations gives a data frame", {
  expect_true(is.data.frame(fetch_pcons()))
  expect_true(is.data.frame(fetch_lads()))
  expect_true(is.data.frame(fetch_las()))
})

test_that("fetch_locations have no duplicate rows", {
  expect_true(!anyDuplicated(fetch_pcons()))
  expect_true(!anyDuplicated(fetch_lads()))
  expect_true(!anyDuplicated(fetch_las()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These tests will fail if there are genuine changes to the locations
# Counts of locations done manually from the data screener repo lookup we had
# Used this kind of thing and counted the YES cells:
# =IF(AND($A2<=2022, $B2>=2022), "YES", "NO")
# =IF(OR(E2="YES", F2="YES"), "YES", "NO")
test_that("year filtering works as expected", {
  # PCONs
  expect_equal(nrow(fetch_pcons(c("2017", "2019", "2020", "2021", "2022", "2023", "2024"))), 1295)
  # expect_equal(nrow(fetch_pcons(c("2022", "2023"))), 650) # TODO

  # LADs
  expect_equal(nrow(fetch_lads(c("2017", "2019", "2020", "2021", "2022", "2023", "2024"))), 408)
  # expect_equal(nrow(fetch_lads(c("2024", "2023"))), 400) # TODO

  # LAs
  #  expect_equal(nrow(fetch_las(c("2017", "2019", "2020", "2021", "2022", "2023", "2024"))), 399) # TODO
  # expect_equal(nrow(fetch_las(c("2024", "2023"))), 399) # TODO
})

test_that("2024 locations match what we expect", {
  # PCONs
  # https://www.parliament.uk/about/how/elections-and-voting/constituencies/
  expect_equal(nrow(fetch_pcons("2024")), 650)
  expect_equal(nrow(fetch_pcons("2024", c("England", "Scotland"))), 600)
  expect_equal(nrow(fetch_pcons("2024", "England")), 543)
  expect_equal(nrow(fetch_pcons("2024", "Scotland")), 57)
  expect_equal(nrow(fetch_pcons("2024", "Wales")), 32)
  expect_equal(nrow(fetch_pcons("2024", "Northern Ireland")), 18)

  # LADs
  expect_equal(nrow(fetch_lads("2024")), 361)
  expect_equal(nrow(fetch_lads("2024", c("England", "Wales"))), 318)
  expect_equal(nrow(fetch_lads("2024", "England")), 296)
  expect_equal(nrow(fetch_lads("2024", "Scotland")), 32)
  expect_equal(nrow(fetch_lads("2024", "Wales")), 22)
  expect_equal(nrow(fetch_lads("2024", "Northern Ireland")), 11)

  # LAs
  #  expect_equal(nrow(fetch_las("2024")), 220) # TODO
  # expect_equal(nrow(fetch_las("2024", c("England", "Scotland", "Wales"))), 207) # TODO
  #  expect_equal(nrow(fetch_las("2024", "England")), 153) # TODO
  #  expect_equal(nrow(fetch_las("2024", "Scotland")), 32) # TODO
  expect_equal(nrow(fetch_las("2024", "Wales")), 22)
  expect_equal(nrow(fetch_las("2024", "Northern Ireland")), 11)
})
