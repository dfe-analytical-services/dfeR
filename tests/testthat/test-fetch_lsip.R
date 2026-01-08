test_that("fetch_lsip returns expected columns and data for all years", {
  result <- fetch_lsip()
  expect_true(is.data.frame(result))
  expect_true(all(
    c("lsip_code", "lsip_name") %in% names(result)
  ))
  expect_gt(nrow(result), 0)
})

test_that("fetch_lsip handles invalid year input", {
  expect_error(
    fetch_lsip(1800),
    "year must either be 'All' or a valid year between 2023 and 2025"
  )
})

test_that("fetch_lsip output matches lsip_lad dataset for all years", {
  raw <- dfeR::lsip_lad
  fetched <- fetch_lsip()
  # Only compare the columns returned by fetch_lsip
  cols <- c("lsip_code", "lsip_name")
  raw_subset <- unique(raw[cols])
  fetched_subset <- unique(fetched[cols])
  # The sets should be equal (ignoring row order)
  expect_equal(
    dplyr::arrange(raw_subset, lsip_code),
    dplyr::arrange(fetched_subset, lsip_code)
  )
})

test_that("fetch_lsip output matches lsip_lad for a specific year", {
  raw <- dfeR::lsip_lad
  # Pick a year present in the dataset
  test_year <- unique(raw$first_available_year_included)[1]
  fetched <- fetch_lsip(test_year)
  # Only compare the columns returned by fetch_lsip
  cols <- c("lsip_code", "lsip_name")
  # Filter raw data for the test year
  raw_year <- unique(raw[raw$first_available_year_included == test_year, cols])
  fetched_year <- unique(fetched[cols])
  # The sets should be equal (ignoring row order)
  expect_equal(
    dplyr::arrange(raw_year, lsip_code),
    dplyr::arrange(fetched_year, lsip_code)
  )
})


test_that("fetch_lsip output has no duplicate rows", {
  result <- fetch_lsip()
  expect_equal(nrow(result), nrow(unique(result)))
})

test_that("fetch_lsip output columns are correct types", {
  result <- fetch_lsip()
  expect_true(is.character(result$lsip_code))
  expect_true(is.character(result$lsip_name))
})
