#' Fetch Westminster parliamentary constituencies
#'
#' Fetch a data frame of all Westminster Parliamentary Constituencies for a
#' given year and country based on the dfeR::wd_pcon_lad_la file
#'
#' @param year year to filter the locations to, default is "All",
#' options of 2017, 2019, 2020, 2021, 2022", 2023, 2024
#' @param countries vector of desired countries to filter the locations to,
#' default is "All", or can be a vector with options of "England", "Scotland",
#' "Wales" or "Northern Ireland"
#'
#' @return data frame of unique location names and codes
#' @export
#'
#' @name fetch
#' @examples
#'
#' # Using head() to show only top 5 rows for examples
#' head(fetch_pcons())
#'
#' head(fetch_pcons(2023))
#'
#' head(fetch_pcons(countries = "Scotland"))
#'
#' head(fetch_pcons(year = 2023, countries = c("England", "Wales")))
#'
#' fetch_lads(2024, "Wales")
#'
#' fetch_las(2022, "Northern Ireland")
fetch_pcons <- function(year = "All", countries = "All") {
  # Helper function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Helper function to filter to locations we want
  output <- fetch_locations(
    lookup_data = dfeR::wd_pcon_lad_la,
    cols = c("pcon_code", "pcon_name"),
    year = year,
    countries = countries
  )

  return(output)
}

#' Fetch local authority districts
#'
#' @inheritParams fetch
#'
#' @family fetch_locations
#' @return data frame of unique location names and codes
#' @export
#'
#' @inherit fetch examples
fetch_lads <- function(year = "All", countries = "All") {
  # Helper function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Helper function to filter to locations we want
  output <- fetch_locations(
    lookup_data = dfeR::wd_pcon_lad_la,
    cols = c("lad_code", "lad_name"),
    year = year,
    countries = countries
  )

  return(output)
}

#' Fetch local authorities
#'
#' @inheritParams fetch
#'
#' @family fetch_locations
#' @return data frame of unique location names and codes
#' @export
#'
#' @inherit fetch examples
fetch_las <- function(year = "All", countries = "All") {
  # Helper function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Helper function to filter to locations we want
  output <- fetch_locations(
    lookup_data = dfeR::wd_pcon_lad_la,
    cols = c("new_la_code", "la_name"),
    year = year,
    countries = countries
  )

  return(output)
}
