test_that("geo_hierarchy is a data frame", {
  expect_true(is.data.frame(dfeR::geo_hierarchy))
})

test_that("There are no blank cells", {
  expect_false(any(is.na(dfeR::geo_hierarchy)))
})

test_that("There are no duplicate rows", {
  expect_true(!anyDuplicated(dfeR::geo_hierarchy))
})

test_that("time cols are always 4 digit numbers", {
  expect_true(
    all(grepl(
      "^\\d{4}$",
      dfeR::geo_hierarchy$first_available_year_included
    ))
  )
  expect_true(
    all(grepl(
      "^\\d{4}$",
      dfeR::geo_hierarchy$most_recent_year_included
    ))
  )
})

test_that("code cols are always a 9 digit code except old_la_code", {
  # Get column names ending in _code
  code_columns <- colnames(dfeR::geo_hierarchy)[grepl(
    "_code$",
    colnames(dfeR::geo_hierarchy)
  )]

  # remove old_la_code
  code_columns <- code_columns[
    !code_columns %in% c("old_la_code", "english_devolved_area_code")
  ]

  # Check the format for each code column
  for (col in code_columns) {
    expect_true(
      all(grepl("^[A-Z]\\d{8}$", dfeR::geo_hierarchy[[col]]))
    )
  }
})

test_that("old_la_code is always a 3 digit code, except for 'z'", {
  # filter out z values from the old_la_code column
  old_la_code_test <- dfeR::geo_hierarchy |>
    dplyr::filter(old_la_code != "z")
  # do the test using filtered data
  expect_true(
    all(grepl("\\d{3}", old_la_code_test$old_la_code))
  )
})

test_that("EDA code is always a 9 digit code, except for 'z'", {
  eda_code_test <- dfeR::geo_hierarchy |>
    dplyr::filter(english_devolved_area_code != "z")

  expect_true(
    all(grepl(
      "^[A-Z]\\d{8}$",
      eda_code_test$english_devolved_area_code
    ))
  )
})

# Making sure we don't blank on the join
test_that("there are at least 10 unique combined authority names", {
  expect_true(
    length(unique(dfeR::geo_hierarchy$english_devolved_area_name)) >= 10
  )
})

test_that("rows and cols match description", {
  # This test is more of a reminder when updating the data set, if these change
  # then we need to update the description in R/datasets_documentation.R
  expect_equal(nrow(dfeR::geo_hierarchy), 26057)
  expect_equal(ncol(dfeR::geo_hierarchy), 17)

  expected_columns <- c(
    "first_available_year_included",
    "most_recent_year_included",
    "ward_name",
    "pcon_name",
    "lad_name",
    "la_name",
    "english_devolved_area_name",
    "region_name",
    "country_name",
    "ward_code",
    "pcon_code",
    "lad_code",
    "old_la_code",
    "new_la_code",
    "english_devolved_area_code",
    "region_code",
    "country_code"
  )

  expect_equal(names(dfeR::geo_hierarchy), expected_columns)
})
