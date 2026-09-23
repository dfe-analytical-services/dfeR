#' Fetch ONS Open Geography API data
#'
#' Helper function that takes a data set id and parameters to query and parse
#' data from the ONS Open Geography API. Technically uses a POST request rather
#' than a GET request.
#'
#' It does a pre-query to understand the ObjectIds for the query you want, and
#' then does a query to retrieve those Ids directly in batches before then
#' stacking the whole thing back together to work around the row limits for a
#' single query.
#'
#' On the \href{https://geoportal.statistics.gov.uk/}{Open Geography Portal},
#' find the data set you're interested in and then use the query explorer to
#' find the information for the query.
#'
#' This function has been mostly developed for ease of use for dfeR maintainers
#' if you're interested in getting data from the Open Geography Portal more
#' widely you should also look at the
#' \href{https://github.com/francisbarton/boundr}{boundr package}.
#'
#' @param data_id the id of the data set to query, can be found from the Open
#' Geography Portal
#' @param query_params query parameters to pass into the API, see the ESRI
#' documentation for more information on query parameters -
#' \href{https://developers.arcgis.com/rest/services-reference/enterprise/query-feature-service-layer/}{ESRI Query (Feature Service/Layer)}
#' @param batch_size the number of rows per query. This is 200 by default, if
#' you hit errors then try lowering this. The API has a limit of 1000 to 2000
#' rows per query, and in truth, the actual limit for our method is lower as
#' every ObjectId queried is pasted into the request, so larger batches, and
#' especially Ids that go into the 1,000s or 10,000s, increase the size of
#' each request and risk hitting the limit.
#' @param verbose TRUE or FALSE boolean. TRUE by default. FALSE will turn off
#' the messages to the console that update on what the function is doing
#'
#' @export
#' @return parsed data.frame of geographic names and codes
#'
#' @examplesIf interactive()
#' # Fetch everything from a data set
#' dfeR::get_ons_api_data(data_id = "LAD23_RGN23_EN_LU")
#'
#' # Specify the columns you want
#' dfeR::get_ons_api_data(
#'   "RGN_DEC_2023_EN_NC",
#'   query_params = list(
#'     where = "1=1",
#'     outFields = "RGN23CD,RGN23NM",
#'     outSR = 4326,
#'     f = "json"
#'   )
#' )
get_ons_api_data <- function(
  data_id,
  query_params = list(
    where = "1=1",
    outFields = "*",
    outSR = "4326",
    f = "json"
  ),
  batch_size = 200,
  verbose = TRUE
) {
  # Known URL for ONS API
  # Split in two parts so that the data_id can be smushed in the middle
  part_1 <-
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"
  part_2 <- "/FeatureServer/0/query"

  dataset_url <- paste0(part_1, data_id, part_2)

  # Initial query to get number of objects in requested data
  dfeR::toggle_message("Checking total number of objects...", verbose = verbose)

  # Force the returnIdsOnly argument into the params to get Ids back
  id_params <- query_params
  id_params$returnIdsOnly <- "TRUE"

  # Query to get the Ids
  id_parsed <- ons_api_query(dataset_url, id_params)$objectIds

  if (length(id_parsed) == 0) {
    stop(
      "No objects were found in the ONS Open Geography API for data_id '",
      data_id,
      "' with the given query_params.",
      call. = FALSE
    )
  }

  # Work out total number of ids
  total_ids <- length(id_parsed)
  dfeR::toggle_message(
    dfeR::pretty_num(total_ids),
    " objects found for the query",
    verbose = verbose
  )

  # Create a list of batches of the ids returned by the query, so that any
  # where filter is respected and gaps in the ids are handled
  # 2000 is the maximum limit for a batch
  batches <- split(id_parsed, ceiling(seq_along(id_parsed) / batch_size))
  num_of_batches <- length(batches)
  dfeR::toggle_message(
    "Created ",
    num_of_batches,
    " batches of objects to query",
    verbose = verbose
  )

  dfeR::toggle_message("Querying API to get objects...", verbose = verbose)

  # Set up a blank dataframe to start dumping into
  full_table <- data.frame()

  # Loop the the main feature query (this gets the locations data itself)
  for (batch_num in seq_along(1:num_of_batches)) {
    dfeR::toggle_message(
      "...fetching batch ",
      batch_num,
      ": objects ",
      dfeR::pretty_num(min(batches[[batch_num]])),
      " to ",
      dfeR::pretty_num(max(batches[[batch_num]])),
      "...",
      verbose = verbose
    )

    # Force the objectIds for the batch into the query
    # This also blanks out any WHERE filters as the Ids have already been
    # filtered by the initial query
    batch_params <- query_params
    batch_params$where <- NULL
    batch_params$objectIds <- paste0(batches[[batch_num]], collapse = ",")

    # Stitch the data_id in, give the query parameters and parse the JSON
    batch_parsed <- ons_api_query(dataset_url, batch_params)

    # bind on batch to rest
    full_table <- rbind(full_table, jsonlite::flatten(batch_parsed$features))

    dfeR::toggle_message(
      "...success! There are now ",
      dfeR::pretty_num(nrow(full_table)),
      " rows in your table...",
      verbose = verbose
    )
  }

  dfeR::toggle_message(
    "...data frame batched, stacked and delivered!",
    verbose = verbose
  )

  full_table
}

# Internal helper: POST a query to the ONS API and return the parsed JSON.
# Stops with an informative error if the API can't be reached, returns an HTTP
# error status, returns something that isn't JSON, or reports an error in the
# response body (ArcGIS returns errors such as an unknown data_id with a 200
# status, so the status code alone isn't enough).
ons_api_query <- function(dataset_url, query_params) {
  response <- tryCatch(
    httr2::request(dataset_url) |>
      httr2::req_body_form(!!!query_params) |>
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform(),
    error = function(e) {
      stop(
        "Failed to connect to the ONS Open Geography API at:\n",
        dataset_url,
        "\n\nOriginal error: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  if (httr2::resp_is_error(response)) {
    stop(
      "The ONS Open Geography API returned HTTP status ",
      httr2::resp_status(response),
      " for:\n",
      dataset_url,
      call. = FALSE
    )
  }

  parsed <- tryCatch(
    jsonlite::fromJSON(httr2::resp_body_string(response)),
    error = function(e) {
      stop(
        "Could not parse the response from the ONS Open Geography API at:\n",
        dataset_url,
        "\n\nOriginal error: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  if (!is.null(parsed$error)) {
    stop(
      "The ONS Open Geography API returned an error for:\n",
      dataset_url,
      "\n\nAPI message: ",
      parsed$error$message,
      "\nCheck that the data_id and query_params are valid.",
      call. = FALSE
    )
  }

  parsed
}
