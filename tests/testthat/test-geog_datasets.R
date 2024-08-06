# ons_geog_shorthands =========================================================
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

# wd_pcon_lad_la ==============================================================
test_that("wd_pcon_lad_la is a data frame", {
  expect_true(is.data.frame(dfeR::wd_pcon_lad_la))
})

test_that("There are no blank cells", {
  expect_false(any(is.na(dfeR::wd_pcon_lad_la)))
})

test_that("There are no duplicate rows", {
  expect_true(!anyDuplicated(dfeR::wd_pcon_lad_la))
})

test_that("time cols are always 4 digit numbers", {
  expect_true(
    all(grepl("^\\d{4}$", dfeR::wd_pcon_lad_la$first_available_year_included))
  )
  expect_true(
    all(grepl("^\\d{4}$", dfeR::wd_pcon_lad_la$most_recent_year_included))
  )
})

test_that("code cols are always a 9 digit code", {
  # Get column names ending in _code
  code_columns <-
    tidyselect::ends_with("_code", vars = colnames(dfeR::wd_pcon_lad_la))

  # Check the format for each column
  for (col in code_columns) {
    expect_true(
      all(grepl("^[A-Z]\\d{8}$", dfeR::wd_pcon_lad_la[[col]]))
    )
  }
})

test_that("rows and cols match description", {
  # This test is more of a reminder when updating the dataset, if these change
  # then we need to update the description in R/geog_datasets.R
  expect_equal(nrow(dfeR::wd_pcon_lad_la), 11691)
  expect_equal(ncol(dfeR::wd_pcon_lad_la), 10)
})
