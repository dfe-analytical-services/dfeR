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
#'   fetch_ons_api_data(
#'     data_id = "LAD23_RGN23_EN_LU",
#'     query_params =
#'       list(where = "1=1", outFields = "*", outSR = "4326", f = "json")
#'   )
#' }
fetch_ons_api_data <- function(data_id, query_params) {
  # Known URL for ONS API
  part_1 <-
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"

  # Split in two parts so that the data_id can be smushed in the middle
  part_2 <- "/FeatureServer/0/query"

  # Stitch the data_id in and give the query parameters
  response <- httr::POST(
    paste0(part_1, data_id, part_2),
    query = query_params
  )

  # Get the body of the response
  body <- httr::content(response, "text")

  # Parse the JSON
  parsed <- jsonlite::fromJSON(body)

  # Return flattened data.frame
  return(jsonlite::flatten(parsed$features))
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
    country_shorthands <- unique(substr(countries, 1, 1))

    # Create a regex pattern to filter on
    country_regex <- paste0("^", country_shorthands, collapse = "|")

    lookup <- with(lookup, subset(lookup, grepl(country_regex, pcon_code)))
  }

  return(dplyr::distinct(lookup))
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
