test_that("wd_pcon_lad_la_rgn_ctry is a data frame", {
  expect_true(is.data.frame(dfeR::wd_pcon_lad_la_rgn_ctry))
})

test_that("There are no blank cells", {
  expect_false(any(is.na(dfeR::wd_pcon_lad_la_rgn_ctry)))
})

test_that("There are no duplicate rows", {
  expect_true(!anyDuplicated(dfeR::wd_pcon_lad_la_rgn_ctry))
})

test_that("time cols are always 4 digit numbers", {
  expect_true(
    all(grepl(
      "^\\d{4}$",
      dfeR::wd_pcon_lad_la_rgn_ctry$first_available_year_included
    ))
  )
  expect_true(
    all(grepl(
      "^\\d{4}$", dfeR::wd_pcon_lad_la_rgn_ctry$most_recent_year_included
    ))
  )
})

test_that("code cols are always a 9 digit code", {
  # Get column names ending in _code
  code_columns <- tidyselect::ends_with(
    "_code",
    vars = colnames(dfeR::wd_pcon_lad_la_rgn_ctry)
  )

  # Check the format for each code column
  for (col in code_columns) {
    expect_true(
      all(grepl("^[A-Z]\\d{8}$", dfeR::wd_pcon_lad_la_rgn_ctry[[col]]))
    )
  }
})

test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::wd_pcon_lad_la_rgn_ctry), 24629)
  expect_equal(ncol(dfeR::wd_pcon_lad_la_rgn_ctry), 14)

  expected_columns <- c(
    "first_available_year_included", "most_recent_year_included",
    "ward_name", "pcon_name", "lad_name", "la_name",
    "region_name", "country_name",
    "ward_code", "pcon_code", "lad_code", "new_la_code",
    "region_code", "country_code"
  )

  expect_equal(names(dfeR::wd_pcon_lad_la_rgn_ctry), expected_columns)
})
