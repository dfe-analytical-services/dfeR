test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::lsip_lad), 466)
  expect_equal(ncol(dfeR::lsip_lad), 6)
})


test_that("There are no blank cells", {
  expect_false(any(is.na(dfeR::lsip_lad)))
})

test_that("There are no duplicate rows", {
  expect_true(!anyDuplicated(dfeR::lsip_lad))
})
