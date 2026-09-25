# {mockery} replaces httr2::req_perform() inside ons_api_query() (or
# ons_api_query() inside get_ons_api_data()) with fakes, so these tests don't
# hit the ONS API and don't depend on the network.

# Minimal stand-in for an httr2 response object, enough for resp_is_error(),
# resp_status() and resp_body_string() to work on.
fake_response <- function(status_code, body) {
  httr2::response(
    status_code = status_code,
    url = "https://example.com",
    headers = list(`Content-Type` = "application/json; charset=utf-8"),
    body = charToRaw(body)
  )
}

test_that("ons_api_query returns the parsed JSON on success", {
  skip_if_not_installed("mockery")

  mockery::stub(
    ons_api_query,
    "httr2::req_perform",
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
    "httr2::req_perform",
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
    "httr2::req_perform",
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
    "httr2::req_perform",
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
    "httr2::req_perform",
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

test_that("get_ons_api_data only queries the ids returned by the filter", {
  skip_if_not_installed("mockery")

  # A where filter can return gappy ids that don't start at 1, only those ids
  # should be queried
  m_query <- mockery::mock(
    jsonlite::fromJSON('{"objectIds": [5, 9, 20]}'),
    jsonlite::fromJSON(
      '{"features": [{"attributes": {"code": "E"}},
                     {"attributes": {"code": "I"}}]}'
    ),
    jsonlite::fromJSON('{"features": [{"attributes": {"code": "T"}}]}')
  )
  mockery::stub(get_ons_api_data, "ons_api_query", m_query)

  output <- get_ons_api_data(
    "A_DATA_SET",
    query_params = list(where = "code IN ('E', 'I', 'T')", f = "json"),
    batch_size = 2,
    verbose = FALSE
  )

  expect_equal(output, data.frame(attributes.code = c("E", "I", "T")))
  mockery::expect_called(m_query, 3)

  args <- mockery::mock_args(m_query)
  expect_equal(args[[1]][[2]]$where, "code IN ('E', 'I', 'T')")
  expect_equal(args[[2]][[2]]$objectIds, "5,9")
  expect_equal(args[[3]][[2]]$objectIds, "20")
})
