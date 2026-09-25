# {mockery} replaces utils::read.csv() inside fetch_mp_lookup() with fake
# data, so these tests don't hit GitHub and don't depend on the network.
# Exception: the last test, which deliberately fetches the real file.

# Minimal stand-in for mp_lookup.csv - covers every column
# fetch_mp_lookup()'s shape check requires, so these tests don't trip it.
# Not a realistic copy of the live data (that's checked by the live test at
# the bottom of this file).
fake_mp_lookup <- data.frame(
  pcon_name = c("Aberafan Maesteg", "Brighton Pavilion"),
  pcon_code = c("W07000109", "E14001130"),
  member_id = c("5301", "5314"),
  display_as = c("Stephen Kinnock", "Siân Berry"),
  party_text = c("Labour", "Green Party"),
  member_email = c(
    "stephen.kinnock.mp@parliament.uk",
    "sian.berry.mp@parliament.uk"
  ),
  election_result_summary_2024 = c("Lab hold", "Green hold"),
  lad_names = c("Neath Port Talbot", "Brighton and Hove"),
  lad_codes = c("W06000012", "E06000043"),
  la_names = c("Neath Port Talbot", "Brighton and Hove"),
  new_la_codes = c("W06000012", "E06000043"),
  mayoral_auth_names = c(NA, NA),
  mayoral_auth_codes = c(NA, NA),
  region_name = c("Wales", "South East"),
  region_code = c("W92000004", "E12000008"),
  country_name = c("Wales", "England"),
  country_code = c("W92000004", "E92000001"),
  stringsAsFactors = FALSE
)

test_that("fetch_mp_lookup returns a data frame using the mp-lookup URL", {
  skip_if_not_installed("mockery")

  # mock() creates a fake read.csv() that returns fake_mp_lookup; stub()
  # swaps it in inside fetch_mp_lookup() for this test only. Using mock()
  # (vs. stubbing a value directly, as below) lets us inspect the call args.
  m_read <- mockery::mock(fake_mp_lookup)
  mockery::stub(fetch_mp_lookup, "utils::read.csv", m_read)

  output <- fetch_mp_lookup(verbose = FALSE)

  # Output should be exactly what read.csv() returned, untouched.
  expect_true(is.data.frame(output))
  expect_equal(output, fake_mp_lookup)

  # Hardcoded independently of the source function, so this confirms the
  # right file is requested - not just that a file is requested.
  expected_url <- paste0(
    "https://raw.githubusercontent.com/dfe-analytical-services",
    "/mp-lookup/refs/heads/main/mp_lookup.csv"
  )

  # mock_args() lists the arguments of each call made to m_read.
  # args[[1]][[1]] is the first argument of the first call - the URL.
  args <- mockery::mock_args(m_read)
  expect_equal(args[[1]][[1]], expected_url)
})

test_that("fetch_mp_lookup gives an informative error if the fetch fails", {
  skip_if_not_installed("mockery")

  # Stub read.csv() to always throw, simulating no connection/GitHub down.
  mockery::stub(
    fetch_mp_lookup,
    "utils::read.csv",
    function(...) stop("network error")
  )

  # fetch_mp_lookup() should wrap this in a clearer message via tryCatch,
  # not surface the raw read.csv() error.
  expect_error(
    fetch_mp_lookup(verbose = FALSE),
    "Failed to fetch MP lookup data"
  )
})

test_that("fetch_mp_lookup respects the verbose argument", {
  skip_if_not_installed("mockery")

  # stub() accepts a plain value here (not mock()) since we don't need to
  # inspect call args, just whether messages print.
  mockery::stub(fetch_mp_lookup, "utils::read.csv", fake_mp_lookup)

  # toggle_message() should only produce output when verbose = TRUE.
  expect_message(fetch_mp_lookup(verbose = TRUE), "Fetching MP lookup data")
  expect_no_message(fetch_mp_lookup(verbose = FALSE))
})

test_that("fetch_mp_lookup errors if the fetched data is missing columns", {
  skip_if_not_installed("mockery")

  # Simulates the upstream file changing shape (or a 404 body parsed into a
  # one-column data frame) - fewer columns than fetch_mp_lookup() expects.
  short_mp_lookup <- fake_mp_lookup[, c("pcon_name", "pcon_code")]
  mockery::stub(fetch_mp_lookup, "utils::read.csv", short_mp_lookup)

  expect_error(
    fetch_mp_lookup(verbose = FALSE),
    "is missing expected column"
  )
})

test_that("the live mp-lookup file still has the expected shape", {
  # Unlike the tests above, this one is not mocked - it hits the real,
  # live file, so it's slow and skipped on CRAN/offline. It catches
  # upstream changes (e.g. a renamed column) the mocked tests can't see.
  skip_on_cran()
  skip_if_offline()

  output <- fetch_mp_lookup(verbose = FALSE)

  # Guards against the upstream file changing shape without us noticing.
  # Shared with fetch_mp_lookup()'s own runtime check so the two can't drift.
  expect_true(all(dfeR:::mp_lookup_expected_cols %in% names(output)))

  # One row per constituency 600 is a loose sanity check (~650 exist)
  expect_gt(nrow(output), 600)
  expect_equal(anyDuplicated(output$pcon_name), 0)
})
