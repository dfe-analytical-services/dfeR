fake_mp_lookup <- data.frame(
  pcon_name = c("Aberafan Maesteg", "Brighton Pavilion"),
  pcon_code = c("W07000109", "E14001130"),
  member_id = c("5301", "5314"),
  display_as = c("Stephen Kinnock", "Siân Berry"),
  party_text = c("Labour", "Green Party"),
  stringsAsFactors = FALSE
)

test_that("fetch_mp_lookup returns a data frame using the mp-lookup URL", {
  mockery::stub(fetch_mp_lookup, "utils::read.csv", fake_mp_lookup)

  output <- fetch_mp_lookup(verbose = FALSE)

  expect_true(is.data.frame(output))
  expect_equal(output, fake_mp_lookup)
})

test_that("fetch_mp_lookup gives an informative error if the fetch fails", {
  mockery::stub(
    fetch_mp_lookup,
    "utils::read.csv",
    function(...) stop("network error")
  )

  expect_error(
    fetch_mp_lookup(verbose = FALSE),
    "Failed to fetch MP lookup data"
  )
})

test_that("fetch_mp_lookup respects the verbose argument", {
  mockery::stub(fetch_mp_lookup, "utils::read.csv", fake_mp_lookup)

  expect_message(fetch_mp_lookup(verbose = TRUE), "Fetching MP lookup data")
  expect_no_message(fetch_mp_lookup(verbose = FALSE))
})

test_that("the live mp-lookup file still has the expected shape", {
  skip_on_cran()
  skip_if_offline()

  output <- fetch_mp_lookup(verbose = FALSE)

  # Guards against the upstream file changing shape without us noticing
  expect_true(
    all(
      c(
        "pcon_name",
        "pcon_code",
        "member_id",
        "display_as",
        "party_text",
        "member_email",
        "election_result_summary_2024",
        "region_name",
        "country_name"
      ) %in%
        names(output)
    )
  )

  # Geography codes must stay as character, never guessed as numeric
  expect_type(output$pcon_code, "character")
  expect_type(output$region_code, "character")
  expect_type(output$country_code, "character")

  # One row per constituency, not one row per candidate
  expect_gt(nrow(output), 600)
  expect_equal(anyDuplicated(output$pcon_name), 0)
})
