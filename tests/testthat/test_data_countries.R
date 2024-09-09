test_that("countries is a data frame", {
  expect_true(is.data.frame(dfeR::countries))
})

test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::countries), 10)
  expect_equal(ncol(dfeR::countries), 2)
})

test_that("There are no blank cells", {
  expect_false(any(is.na(dfeR::countries)))
})

test_that("There are no duplicate rows", {
  expect_true(!anyDuplicated(dfeR::countries))
})
