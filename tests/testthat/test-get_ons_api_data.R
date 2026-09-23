# {mockery} replaces httr::POST() inside ons_api_query() (or ons_api_query()
# inside get_ons_api_data()) with fakes, so these tests don't hit the ONS API
# and don't depend on the network.

# Minimal stand-in for an httr response object, enough for http_error(),
# status_code() and content() to work on.
fake_response <- function(status_code, body) {
  structure(
    list(
      url = "https://example.com",
      status_code = as.integer(status_code),
      headers = list(`Content-Type` = "application/json; charset=utf-8"),
      content = charToRaw(body)
    ),
    class = "response"
  )
}

test_that("ons_api_query returns the parsed JSON on success", {
  skip_if_not_installed("mockery")

  mockery::stub(
    ons_api_query,
    "httr::POST",
    fake_response(200, '{"objectIds": [1, 2, 3]}')
  )

  expect_equal(
    ons_api_query("https://example.com", list())$objectIds,
    1:3
  )
})

test_that("ons_api_query gives an informative error if it can't connect", {
  skip_if_not_installed("mockery")

  # Simulate no connection / the API being down
  mockery::stub(
    ons_api_query,
    "httr::POST",
    function(...) stop("network error")
  )

  expect_error(
    ons_api_query("https://example.com", list()),
    "Failed to connect to the ONS Open Geography API"
  )
})

test_that("ons_api_query gives an informative error on an HTTP error", {
  skip_if_not_installed("mockery")

  mockery::stub(
    ons_api_query,
    "httr::POST",
    fake_response(500, "Internal Server Error")
  )

  expect_error(
    ons_api_query("https://example.com", list()),
    "returned HTTP status 500"
  )
})

test_that("ons_api_query gives an informative error if it can't parse", {
  skip_if_not_installed("mockery")

  mockery::stub(
    ons_api_query,
    "httr::POST",
    fake_response(200, "<html>not json</html>")
  )

  expect_error(
    ons_api_query("https://example.com", list()),
    "Could not parse the response"
  )
})

test_that("ons_api_query surfaces errors the API returns with a 200", {
  skip_if_not_installed("mockery")

  # ArcGIS returns errors such as an unknown data_id with a 200 status
  mockery::stub(
    ons_api_query,
    "httr::POST",
    fake_response(
      200,
      '{"error": {"code": 400, "message": "Invalid URL", "details": []}}'
    )
  )

  expect_error(
    ons_api_query("https://example.com", list()),
    "API message: Invalid URL"
  )
})

test_that("get_ons_api_data errors informatively if no objects are found", {
  skip_if_not_installed("mockery")

  mockery::stub(
    get_ons_api_data,
    "ons_api_query",
    list(objectIds = list())
  )

  expect_error(
    get_ons_api_data("NOT_A_DATA_SET", verbose = FALSE),
    "No objects were found"
  )
})

test_that("get_ons_api_data batches, stacks and flattens the results", {
  skip_if_not_installed("mockery")

  # One call for the ids, then one call per batch (3 ids / batch_size 2)
  m_query <- mockery::mock(
    jsonlite::fromJSON('{"objectIds": [1, 2, 3]}'),
    jsonlite::fromJSON(
      '{"features": [{"attributes": {"code": "A"}},
                     {"attributes": {"code": "B"}}]}'
    ),
    jsonlite::fromJSON('{"features": [{"attributes": {"code": "C"}}]}')
  )
  mockery::stub(get_ons_api_data, "ons_api_query", m_query)

  output <- get_ons_api_data("A_DATA_SET", batch_size = 2, verbose = FALSE)

  expect_equal(output, data.frame(attributes.code = c("A", "B", "C")))
  mockery::expect_called(m_query, 3)

  # The batch queries ask for the object ids directly, without a where clause
  args <- mockery::mock_args(m_query)
  expect_equal(args[[2]][[2]]$objectIds, "1,2")
  expect_null(args[[2]][[2]]$where)
})
