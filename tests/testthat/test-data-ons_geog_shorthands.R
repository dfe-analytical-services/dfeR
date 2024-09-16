test_that("geog_shorthands is a data frame", {
  expect_true(is.data.frame(dfeR::ons_geog_shorthands))
})

test_that("geog_shorthands has the expected columns", {
  # This is less of a unit test and more a test to remind us that if we break
  # it, it may break other things!
  expect_true(
    all(
      c("ons_level_shorthands", "name_column", "code_column") %in%
        names(dfeR::ons_geog_shorthands)
    )
  )
})

test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::ons_geog_shorthands), 7)
  expect_equal(ncol(dfeR::ons_geog_shorthands), 3)
})
