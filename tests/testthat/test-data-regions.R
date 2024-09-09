test_that("regions is a data frame", {
  expect_true(is.data.frame(dfeR::regions))
})

test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::regions), 16)
  expect_equal(ncol(dfeR::regions), 2)
})

test_that("There are no blank cells", {
  expect_false(any(is.na(dfeR::regions)))
})

test_that("There are no duplicate rows", {
  expect_true(!anyDuplicated(dfeR::regions))
})
