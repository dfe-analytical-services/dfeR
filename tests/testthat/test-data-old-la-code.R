test_that("old_la_codes is a data frame", {
  expect_true(is.data.frame(dfeR::old_la_codes))
})

test_that("There are no blank cells", {
  expect_false(any(is.na(dfeR::old_la_codes)))
})

test_that("There are no duplicate rows", {
  expect_true(!anyDuplicated(dfeR::old_la_codes))
})



test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::old_la_codes), 224)
  expect_equal(ncol(dfeR::old_la_codes), 3)

  expected_columns <- c(
    "la_name", "old_la_code", "new_la_code"
  )

  expect_equal(names(dfeR::old_la_codes), expected_columns)
})
