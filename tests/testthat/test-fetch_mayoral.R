test_that("Gives a data frame", {
  expect_true(is.data.frame(fetch_mayoral()))
})

test_that("Has no duplicate rows", {
  expect_true(!anyDuplicated(fetch_mayoral()))
})

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Snapshot test outputs
test_that("location counts per year are consistent", {
  expect_snapshot(
    lapply(2017:2025, fetch_mayoral)
  )
})
