test_that("Gives a data frame", {
  expect_true(is.data.frame(fetch_countries()))
})

test_that("Has no duplicate rows", {
  expect_true(!anyDuplicated(fetch_countries()))
})
