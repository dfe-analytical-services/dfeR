test_that("fetch_lsips returns expected columns and data for all years", {
  result <- fetch_lsips()
  expect_true(is.data.frame(result))
  expect_true(all(
    c("lsip_code", "lsip_name") %in% names(result)
  ))
  expect_gt(nrow(result), 0)
})

test_that("fetch_lsips handles invalid year input", {
  expect_error(
    fetch_lsips(1800),
    "year must either be 'All' or one of: 2023, 2025"
  )
})

test_that("fetch_lsips rejects years ONS never published", {
  # ONS published LSIP lookups for 2023 and 2025 but not 2024, so 2024 must
  # error rather than quietly returning the areas common to both lookups
  expect_error(
    fetch_lsips(2024),
    "year must either be 'All' or one of: 2023, 2025"
  )
})

test_that("fetch_lsips output matches lsip_lad dataset for all years", {
  raw <- dfeR::lsip_lad
  fetched <- fetch_lsips()
  # Only compare the columns returned by fetch_lsips
  cols <- c("lsip_code", "lsip_name")
  raw_subset <- unique(raw[cols])
  fetched_subset <- unique(fetched[cols])
  # The sets should be equal (ignoring row order)
  expect_equal(
    dplyr::arrange(raw_subset, lsip_code),
    dplyr::arrange(fetched_subset, lsip_code)
  )
})

test_that("fetch_lsips output matches lsip_lad for a specific year", {
  raw <- dfeR::lsip_lad
  # Only compare the columns returned by fetch_lsips
  cols <- c("lsip_code", "lsip_name")

  for (test_year in c(2023, 2025)) {
    fetched <- fetch_lsips(test_year)
    # An area is in a year if that year falls within its first and most recent
    # years, matching how fetch_lsips() filters
    raw_year <- unique(
      raw[
        raw$first_available_year_included <= test_year &
          raw$most_recent_year_included >= test_year,
        cols
      ]
    )
    fetched_year <- unique(fetched[cols])
    # The sets should be equal (ignoring row order)
    expect_equal(
      dplyr::arrange(raw_year, lsip_code),
      dplyr::arrange(fetched_year, lsip_code)
    )
  }
})

test_that("fetch_lsips output has no duplicate rows", {
  result <- fetch_lsips()
  expect_equal(nrow(result), nrow(unique(result)))
})

test_that("fetch_lsips output columns are correct types", {
  result <- fetch_lsips()
  expect_true(is.character(result$lsip_code))
  expect_true(is.character(result$lsip_name))
})
