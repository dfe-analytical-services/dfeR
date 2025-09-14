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
      "^\\d{4}$",
      dfeR::wd_pcon_lad_la_rgn_ctry$most_recent_year_included
    ))
  )
})

test_that("code cols are always a 9 digit code except old_la_code", {
  # Get column names ending in _code
  code_columns <- colnames(dfeR::wd_pcon_lad_la_rgn_ctry)[grepl(
    "_code$",
    colnames(dfeR::wd_pcon_lad_la_rgn_ctry)
  )]

  # remove old_la_code
  code_columns <- code_columns[
    !code_columns %in% c("old_la_code", "cauth_code")
  ]

  # Check the format for each code column
  for (col in code_columns) {
    expect_true(
      all(grepl("^[A-Z]\\d{8}$", dfeR::wd_pcon_lad_la_rgn_ctry[[col]]))
    )
  }
})

test_that("old_la_code is always a 3 digit code, except for 'z'", {
  # filter out z values from the old_la_code column
  old_la_code_test <- dfeR::wd_pcon_lad_la_rgn_ctry |>
    dplyr::filter(old_la_code != "z")
  # do the test using filtered data
  expect_true(
    all(grepl("\\d{3}", old_la_code_test$old_la_code))
  )
})

test_that("cauth_code is always a 9 digit code, except for 'z'", {
  cauth_code_test <- dfeR::wd_pcon_lad_la_rgn_ctry |>
    dplyr::filter(cauth_code != "z")

  expect_true(
    all(grepl("^[A-Z]\\d{8}$", cauth_code_test$cauth_code))
  )
})

# Making sure we don't blank on the join
test_that("there are at least 10 unique combined authority names", {
  expect_true(length(unique(dfeR::wd_pcon_lad_la_rgn_ctry$cauth_name)) >= 10)
})

test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::wd_pcon_lad_la_rgn_ctry), 24629)
  expect_equal(ncol(dfeR::wd_pcon_lad_la_rgn_ctry), 17)

  expected_columns <- c(
    "first_available_year_included",
    "most_recent_year_included",
    "ward_name",
    "pcon_name",
    "lad_name",
    "la_name",
    "cauth_name",
    "region_name",
    "country_name",
    "ward_code",
    "pcon_code",
    "lad_code",
    "old_la_code",
    "new_la_code",
    "cauth_code",
    "region_code",
    "country_code"
  )

  expect_equal(names(dfeR::wd_pcon_lad_la_rgn_ctry), expected_columns)
})
