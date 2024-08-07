#' fetch_ons_api_data
#'
#' Helper function that takes a data set id and parameters to query and parse
#' data from the ONS API
#'
#' On the ONS website, find the data set you're interested in and then use the
#' query explorer to find the information for the query
#'
#' @param data_id the id of the data set to query, can be found from the Open
#' Geography Portal
#' @param query_params query parameters to pass into the API
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

# https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/WD17_PCON17_LAD17_UTLA17_UK_LU_7d674672d1be40fdb94f4f26527a937a/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json
# Expecting 9578 ids
# WD17_PCON17_LAD17_UTLA17_UK_LU_7d674672d1be40fdb94f4f26527a937a
# TODO: TESTING query_params <- list(where = "1=1", outFields = "*", outSR = "4326", f = "json")

fetch_ons_api_data <- function(data_id, query_params = list(where = "1=1", outFields = "*", outSR = "4326", f = "json")) {
  # Known URL for ONS API
  # Split in two parts so that the data_id can be smushed in the middle
  part_1 <-
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"
  part_2 <- "/FeatureServer/0/query"

  dataset_url <- paste0(part_1, data_id, part_2)

  # Initial query to get number of objects in requested data
  # Force the returnIdsOnly argument
  message("Checking total number of objects...")
  id_params <- query_params
  # TODO: document this
  id_params$returnIdsOnly <- "TRUE"
  id_response <- httr::POST(dataset_url, query = id_params)
  id_body <- httr::content(id_response, "text")
  id_parsed <- jsonlite::fromJSON(id_body)$objectIds

  # Work out total number of ids
  total_ids <- max(id_parsed)
  message(dfeR::pretty_num(total_ids), " objects found for the query")

  # Create a list of batches of ids
  # Using 1000 as that's the max recommended number features on the ONS API
  # 2000 is the maximum limit for a batch
  batches <- split(1:total_ids, ceiling(seq_along(1:total_ids) / 250))
  message("Created ", length(batches), " batches of objects to query")

  message("Querying API to get objects...")

  # Set up a blank dataframe to start dumping into
  full_table <- data.frame()

  # Loop the the main feature query (this gets the locations data itself)
  for (batch_num in 1:length(batches)){
    message(
      "...fetching batch ", batch_num, ": objects ",
      dfeR::pretty_num(min(batches[[batch_num]])), " to ", dfeR::pretty_num(max(batches[[batch_num]])), "..."
    )

    # Force the objectIds for the batch into the query
    # TODO: document this
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


    message("...success! There are now ", dfeR::pretty_num(nrow(full_table)), " rows in your table...")
  }






  # TODO: query in batches and rbind flattened results
  # TODO: add messages to users about batching and queries
  # TODO: add details to documentation on batching


  message("...data frame signed sealed and delivered!")

  return(full_table)
}

#' check_fetch_location_inputs
#'
#' @param year_input the value of the years input
#' @param country_input the value of the countries input
#'
#' @return nothing, unless a failure, and then it will return an error
#' @keywords internal
check_fetch_location_inputs <- function(year_input, country_input) {
  if (paste0(year_input, collapse = "") != "All") {
    if (!all(grepl("^\\d{4}$", as.character(year_input)))) {
      stop(paste0(
        "years must either be 'All', or a vector of valid 4 digit years",
        " e.g. c('2020', '2021')"
      ))
    }
  }

  allowed_countries <- c("England", "Scotland", "Wales", "Northern Ireland")

  if (paste0(country_input, collapse = "") != "All") {
    if (!all(country_input %in% allowed_countries)) {
      stop(paste0(
        "countries must either be 'All', or a vector of valid country names ",
        "from: England, Scotland, Wales, or Northern Ireland"
      ))
    }
  }
}

#' fetch_pcons
#'
#' Fetch a data frame of all Westminster Parliamentary Constituencies for a
#' given year and country based on the dfeR::wd_pcon_lad_la file
#'
#' @param years vector of years to filter the locations to, default is "All",
#' options of "2017", "2019", "2020", "2021", "2022", "2023", "2024", can pass
#' a vector of a custom combination
#' @param countries vector of desired countries to filter the locations to,
#' default is "All", or can be a vector with options of "England", "Scotland",
#' "Wales" or "Northern Ireland"
#'
#' @return data frame of unique locations
#' @export
#'
#' @examples
#' fetch_pcons()
#' fetch_pcons("2023")
#' fetch_pcons(countries = "Scotland")
#' fetch_pcons(years = c("2023", "2024"), countries = c("England", "Wales"))
fetch_pcons <- function(years = "All", countries = "All") {
  # Function to check the inputs are valid
  check_fetch_location_inputs(years, countries)

  # Filter the lookup to the columns we care about
  pcon_cols <- c(
    "pcon_code", "pcon_name", "first_available_year_included",
    "most_recent_year_included"
  )

  lookup <- dplyr::select(dfeR::wd_pcon_lad_la, dplyr::all_of(pcon_cols))

  # Return early without filtering if defaults are used
  if (all(years == "All", countries == "All")) {
    return(dplyr::distinct(lookup))
  }

  # Filtering based on years and countries
  if (paste0(years, collapse = "") != "All") {
    lookup <-
      with(lookup, subset(lookup, most_recent_year_included %in% years))
  }
  if (paste0(countries, collapse = "") != "All") {
    # Filter every value to its first letter as that matches the ONS code
    # then filter the data set to only have codes from the selected countries
    lookup <- with(
      lookup,
      subset(
        lookup,
        grepl(
          paste0("^", unique(substr(countries, 1, 1)), collapse = "|"),
          pcon_code
        )
      )
    )
  }

  resummarised_lookup <- lookup %>%
    dplyr::summarise(
      "first_available_year_included" =
        min(.data$first_available_year_included),
      "most_recent_year_included" =
        max(.data$most_recent_year_included),
      .by = dplyr::all_of(pcon_cols)
    )

  return(dplyr::distinct(resummarised_lookup))
}

#' fetch_lads
#'
#' @inheritParams fetch_pcons
#'
#' @family fetch_locations
#' @return data frame of unique locations
#' @export
#'
#' @examples
#' fetch_lads()
fetch_lads <- function(years = "All", countries = "All") {
  # Validate the inputs
}

#' fetch_las
#'
#' @inheritParams fetch_pcons
#'
#' @family fetch_locations
#' @return data frame of unique locations
#' @export
#'
#' @examples
#' fetch_las()
fetch_las <- function(years = "All", countries = "All") {
  # Validate the inputs
}
