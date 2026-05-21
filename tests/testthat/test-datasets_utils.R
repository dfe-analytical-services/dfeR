# tidy_raw_lookup tests =======================================================
test_that("tidy_raw_lookup errors on non-data.frame input", {
  expect_error(tidy_raw_lookup(1:5), "must be a data frame")
})

test_that("tidy_raw_lookup renames columns using shorthands", {
  df <- data.frame(
    LAD20NM = "Barnsley",
    LAD20CD = "E08000016",
    stringsAsFactors = FALSE
  )
  result <- tidy_raw_lookup(df)
  expect_true("lad_name" %in% names(result))
  expect_true("lad_code" %in% names(result))
})

test_that("tidy_raw_lookup adds year columns", {
  df <- data.frame(
    LAD20NM = "Barnsley",
    LAD20CD = "E08000016",
    stringsAsFactors = FALSE
  )
  result <- tidy_raw_lookup(df)
  expect_true("first_available_year_included" %in% names(result))
  expect_true("most_recent_year_included" %in% names(result))
  expect_equal(result$first_available_year_included, "2020")
  expect_equal(result$most_recent_year_included, "2020")
})

test_that("tidy_raw_lookup warns and picks latest year if multiple years", {
  df <- data.frame(LAD20NM = "A", LAD19NM = "B", stringsAsFactors = FALSE)
  expect_warning(tidy_raw_lookup(df), "Taking the latest year")
})

test_that("tidy_raw_lookup strips whitespace in name columns", {
  df <- data.frame(
    LAD20NM = "  Barnsley   ",
    LAD20CD = "E08000016",
    stringsAsFactors = FALSE
  )
  result <- tidy_raw_lookup(df)
  expect_equal(result$lad_name, "Barnsley")
})

# create_time_series_lookup tests =============================================
test_that("create_time_series_lookup errors on non-list input", {
  expect_error(create_time_series_lookup(1:5), "not data frames")
})

test_that("create_time_series_lookup errors on empty list", {
  expect_error(create_time_series_lookup(list()), "list is empty")
})

test_that("create_time_series_lookup errors on mismatched columns", {
  df1 <- data.frame(
    a = 1,
    b_code = 2,
    first_available_year_included = 2020,
    most_recent_year_included = 2020
  )
  df2 <- data.frame(
    a = 1,
    c_code = 2,
    first_available_year_included = 2021,
    most_recent_year_included = 2021
  )
  expect_error(
    create_time_series_lookup(list(df1, df2)),
    "different column names"
  )
})

test_that("create_time_series_lookup combines year columns correctly", {
  df1 <- data.frame(
    a = 1,
    a_code = 2,
    first_available_year_included = 2020,
    most_recent_year_included = 2020
  )
  df2 <- data.frame(
    a = 1,
    a_code = 2,
    first_available_year_included = 2021,
    most_recent_year_included = 2021
  )
  result <- create_time_series_lookup(list(df1, df2))
  expect_equal(result$first_available_year_included, 2020)
  expect_equal(result$most_recent_year_included, 2021)
  expect_true("a_code" %in% names(result))
})

# explode_timeseries tests ====================================================
test_that("explode_timeseries errors if required columns missing", {
  df <- data.frame(a = 1, b = 2)
  expect_error(
    explode_timeseries(df),
    "must contain 'first_available_year_included'"
  )
})

test_that("explode_timeseries expands rows for each year", {
  df <- data.frame(
    id = 1,
    first_available_year_included = 2020,
    most_recent_year_included = 2022
  )
  result <- explode_timeseries(df)
  expect_equal(nrow(result), 3)
  expect_equal(result$year, 2020:2022)
  expect_equal(result$id, c(1, 1, 1))
})

# collapse_timeseries tests ===================================================
test_that("collapse_timeseries errors if year column missing", {
  df <- data.frame(a = 1, b = 2)
  expect_error(collapse_timeseries(df), "must contain a 'year' column")
})

test_that("collapse_timeseries collapses years correctly", {
  df <- data.frame(
    id = c(1, 1, 1),
    year = c(2020, 2021, 2022)
  )
  result <- collapse_timeseries(df)
  expect_equal(result$first_available_year_included, 2020)
  expect_equal(result$most_recent_year_included, 2022)
  expect_equal(result$id, 1)
})
