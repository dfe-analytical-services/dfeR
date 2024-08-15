#' Comma separate
#'
#' @description
#' Adds separating commas to big numbers.
#'
#' @param number number to be comma separated
#'
#' @return string containing comma separated number
#' @export
#'
#' @examples
#' comma_sep(100)
#' comma_sep(1000)
#' comma_sep(3567000)
comma_sep <- function(number) {
  if (!is.numeric(number)) {
    stop("number must be a numeric value")
  }

  format(number, big.mark = ",", trim = TRUE, scientific = FALSE)
}

#' Round five up
#'
#' @description
#' Round any number to a specified number of places, with 5's being rounded up.
#'
#' @details
#' Rounds to 0 decimal places by default.
#'
#' You can use a negative value for the decimal places. For example:
#' -1 would round to the nearest 10
#' -2 would round to the nearest 100
#' and so on.
#'
#' This is as an alternative to round in base R, which uses a bankers round.
#' For more information see the
#' [round() documentation](https://rdrr.io/r/base/Round.html).
#'
#'
#' @param number number to be rounded
#' @param dp number of decimal places to round to, default is 0
#'
#' @return Rounded number
#' @export
#'
#' @examples
#' # No dp set
#' round_five_up(2485.85)
#'
#' # With dp set
#' round_five_up(2485.85, 2)
#' round_five_up(2485.85, 1)
#' round_five_up(2485.85, 0)
#' round_five_up(2485.85, -1)
#' round_five_up(2485.85, -2)
round_five_up <- function(number, dp = 0) {
  if (!is.numeric(number) && !is.numeric(dp)) {
    stop("both input arguments must be numeric")
  }
  if (!is.numeric(number)) {
    stop("the input number to be rounded must be numeric")
  }
  if (!is.numeric(dp)) {
    stop("the decimal places input must be numeric")
  }

  z <- abs(number) * 10^dp
  z <- z + 0.5 + sqrt(.Machine$double.eps)
  z <- trunc(z)
  z <- z / 10^dp
  return(z * sign(number))
}

#' Fetch ONS Open Geography API data
#'
#' Helper function that takes a data set id and parameters to query and parse
#' data from the ONS Open Geography API.
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
#' @param data_id the id of the data set to query, can be found from the Open
#' Geography Portal
#' @param query_params query parameters to pass into the API, see the ESRI
#' documentation for more information on query parameters -
#' \href{https://shorturl.at/5xrJT}{ESRI Query (Feature Service/Layer)}
#' @param batch_size the number of rows per query. This is 250 by default, if
#' you hit errors then try lowering this. The API has a limit of 1000 to 2000
#' rows per query, and in truth, the actual limit for our method is lower as
#' every ObjectId queried is pasted into the query URL so for every row
#' included in the batch, and especial if those Id's go into the 1,000s or
#' 10,000s they will increase the size of the URL and risk hitting the limit.
#' @param verbose TRUE or FALSE boolean. TRUE by default. FALSE will turn off
#' the messages to the console that update on what the function is doing
#'
#' @export
#' @return parsed data.frame of geographic names and codes
#'
#' @examples
#' if (interactive()) {
#'   # Specify some parameters
#'   fetch_ons_api_data(
#'     data_id = "LAD23_RGN23_EN_LU",
#'     query_params =
#'       list(outFields = "column1, column2", outSR = "4326", f = "json")
#'   )
#'
#'   # Just fetch everything
#'   fetch_ons_api_data(data_id = "LAD23_RGN23_EN_LU")
#' }
fetch_ons_api_data <- function(data_id,
                               query_params =
                                 list(
                                   where = "1=1",
                                   outFields = "*",
                                   outSR = "4326",
                                   f = "json"
                                 ),
                               batch_size = 200,
                               verbose = TRUE) {
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
  id_response <- httr::POST(dataset_url, query = id_params)
  id_body <- httr::content(id_response, "text")
  id_parsed <- jsonlite::fromJSON(id_body)$objectIds

  # Work out total number of ids
  total_ids <- max(id_parsed)
  dfeR::toggle_message(
    dfeR::pretty_num(total_ids),
    " objects found for the query",
    verbose = verbose
  )

  # Create a list of batches of ids
  # Using 1000 as that's the max recommended number features on the ONS API
  # 2000 is the maximum limit for a batch
  batches <- split(1:total_ids, ceiling(seq_along(1:total_ids) / batch_size))
  dfeR::toggle_message(
    "Created ", length(batches), " batches of objects to query",
    verbose = verbose
  )

  dfeR::toggle_message("Querying API to get objects...", verbose = verbose)

  # Set up a blank dataframe to start dumping into
  full_table <- data.frame()

  # Loop the the main feature query (this gets the locations data itself)
  for (batch_num in seq_len(batches)) {
    dfeR::toggle_message(
      "...fetching batch ", batch_num, ": objects ",
      dfeR::pretty_num(min(batches[[batch_num]])), " to ",
      dfeR::pretty_num(max(batches[[batch_num]])), "...",
      verbose = verbose
    )

    # Force the objectIds for the batch into the query
    # This also blanks out any WHERE filters as we don't need those for getting
    # the total number of Ids
    batch_params <- query_params
    batch_params$where <- NULL
    batch_params$objectIds <- paste0(batches[[batch_num]], collapse = ",")

    # Stitch the data_id in and give the query parameters
    batch_response <- httr::POST(
      dataset_url,
      query = batch_params
    )

    # Get the body of the response
    batch_body <- httr::content(batch_response, "text")

    # Parse the JSON
    batch_parsed <- jsonlite::fromJSON(batch_body)

    # bind on batch to rest
    full_table <- rbind(full_table, jsonlite::flatten(batch_parsed$features))


    dfeR::toggle_message(
      "...success! There are now ", dfeR::pretty_num(nrow(full_table)),
      " rows in your table...",
      verbose = verbose
    )
  }

  dfeR::toggle_message(
    "...data frame batched, stacked and delivered!",
    verbose = verbose
  )

  return(full_table)
}

#' Controllable console messages
#'
#' Quick expansion to the `message()` function aimed for use in functions for
#' an easy addition of a global verbose TRUE / FALSE argument to toggle the
#' messages on or off
#'
#' @param ... any message you would normally pass into `message()`. See
#' \code{\link{message}} for more details
#'
#' @param verbose logical, usually a variable passed from the function you are
#' using this within
#'
#' @export
#'
#' @examples
#' # Usually used in a function
#' my_function <- function(count_fingers, verbose) {
#'   toggle_message("I have ", count_fingers, " fingers", verbose = verbose)
#'   fingers_thumbs <- count_fingers + 2
#'   toggle_message("I have ", fingers_thumbs, " digits", verbose = verbose)
#' }
#'
#' my_function(5, verbose = FALSE)
#' my_function(5, verbose = TRUE)
#'
#' # Can be used in isolation
#' toggle_message("I want the world to read this!", verbose = TRUE)
#' toggle_message("I ain't gonna show this message!", verbose = FALSE)
#'
#' count_fingers <- 5
#' toggle_message("I have ", count_fingers, " fingers", verbose = TRUE)
toggle_message <- function(..., verbose) {
  if (verbose) {
    message(...)
  }
}
