test_that("fetch_mp_lookup returns a data frame using the mp-lookup URL", {
  fake_data <- data.frame(
    "Constituency name" = "Aberafan Maesteg",
    "Candidate family name" = "Kinnock",
    check.names = FALSE
  )

  mockery::stub(fetch_mp_lookup, "readr::read_csv", fake_data)

  output <- fetch_mp_lookup(verbose = FALSE)

  expect_true(is.data.frame(output))
  expect_equal(output, fake_data)
})

test_that("fetch_mp_lookup gives an informative error if the fetch fails", {
  mockery::stub(
    fetch_mp_lookup,
    "readr::read_csv",
    function(...) stop("network error")
  )

  expect_error(
    fetch_mp_lookup(verbose = FALSE),
    "Failed to fetch MP lookup data"
  )
})

test_that("fetch_mp_lookup respects the verbose argument", {
  mockery::stub(fetch_mp_lookup, "readr::read_csv", data.frame(x = 1))

  expect_message(fetch_mp_lookup(verbose = TRUE), "Fetching MP lookup data")
  expect_no_message(fetch_mp_lookup(verbose = FALSE))
})
