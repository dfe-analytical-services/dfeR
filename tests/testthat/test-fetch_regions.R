test_that("Gives a data frame", {
  expect_true(is.data.frame(fetch_regions()))
})

test_that("Has no duplicate rows", {
  expect_true(!anyDuplicated(fetch_regions()))
})
