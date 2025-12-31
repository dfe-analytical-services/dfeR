#' Fetch Westminster parliamentary constituencies
#'
#' Fetch a data frame of all Westminster Parliamentary Constituencies for a
#' given year and country based on the dfeR::geo_hierarchy file.
#'
#' @param year year to filter the locations to, default is "All",
#' options of 2017, 2019, 2020, 2021, 2022", 2023, 2024, 2025
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
#' head(fetch_wards())
#'
#' head(fetch_pcons())
#'
#' head(fetch_pcons(2023))
#'
#' head(fetch_pcons(countries = "Scotland"))
#'
#' head(fetch_pcons(year = 2023, countries = c("England", "Wales")))
#'
#' head(fetch_mayoral())
#'
#' fetch_lads(2024, "Wales")
#'
#' fetch_las(2022, "Northern Ireland")
#'
#' # The following have no specific years available and return all values
#' fetch_regions()
#' fetch_countries()
fetch_pcons <- function(year = "All", countries = "All") {
  # Helper function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Helper function to filter to locations we want
  output <- fetch_locations(
    lookup_data = dfeR::geo_hierarchy,
    cols = c("pcon_code", "pcon_name"),
    year = year,
    countries = countries
  )

  output
}

#' Fetch local authority districts
#'
#' Fetch a data frame of all local authority districts for a
#' given year and country based on the dfeR::geo_hierarchy file.
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
    lookup_data = dfeR::geo_hierarchy,
    cols = c("lad_code", "lad_name"),
    year = year,
    countries = countries
  )

  output
}

#' Fetch local authorities
#'
#' Fetch a data frame of all local authorities for a given year and country
#' based on the dfeR::geo_hierarchy file.
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
    lookup_data = dfeR::geo_hierarchy,
    cols = c("new_la_code", "la_name", "old_la_code"),
    year = year,
    countries = countries
  )

  output
}

#' Fetch wards
#'
#' Fetch a data frame of all wards for a given year and country based on the
#' dfeR::geo_hierarchy file.
#'
#' @inheritParams fetch
#'
#' @family fetch_locations
#' @return data frame of unique location names and codes
#' @export
#'
#' @inherit fetch examples
fetch_wards <- function(year = "All", countries = "All") {
  # Helper function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Helper function to filter to locations we want
  output <- fetch_locations(
    lookup_data = dfeR::geo_hierarchy,
    cols = c("ward_code", "ward_name"),
    year = year,
    countries = countries
  )

  output
}

#' Fetch mayoral combined authorities
#'
#' Fetch a data frame of all mayoral combined authorities for a given year
#' and country based on the dfeR::geo_hierarchy file.
#'
#' Note that mayoral combined authorities only exist for England.
#'
#' Mayoral combined authorities are also known as English Devolved Areas, as
#' we add in the Greater London Authority to the combined authority lookup
#' published by ONS.
#'
#' @param year year to filter the locations to, default is "All",
#' options of 2017, 2019, 2020, 2021, 2022", 2023, 2024, 2025
#'
#' @family fetch_locations
#' @return data frame of unique location names and codes
#' @export
#'
#' @inherit fetch examples
fetch_mayoral <- function(year = "All") {
  # Helper function to check the inputs are valid (only England for mayoral)
  check_fetch_location_inputs(year, "England")

  # Helper function to filter to locations we want
  output <- fetch_locations(
    lookup_data = dfeR::geo_hierarchy,
    cols = c("english_devolved_area_code", "english_devolved_area_name"),
    year = year,
    countries = "England"
  ) |>
    dplyr::arrange("english_devolved_area_code")

  # Drop rows where not applicable
  output[output$english_devolved_area_code != "z", ]
}

#' Fetch regions
#'
#' Fetch a data frame of all regions based on the dfeR::regions file.
#'
#' @family fetch_locations
#' @return data frame of unique location names and codes
#' @export
#'
#' @inherit fetch examples
fetch_regions <- function() {
  dfeR::regions
}

#' Fetch countries
#'
#' Fetch a data frame of all countries based on the dfeR::countries file.
#'
#' @family fetch_locations
#' @return data frame of unique location names and codes
#' @export
#'
#' @inherit fetch examples
fetch_countries <- function() {
  dfeR::countries
}

#' Fetch LSIP-LAD lookup
#'
#' Fetch a data frame of LSIP-LAD relationships for a given year.
#'
#' @param year Year to filter the lookup to, default is "All".
#' @return data frame of LSIP-LAD relationships
#' @export
fetch_lsip_lad <- function(year = "All") {
  #convert year input to numeric if possible
  if (is.character(year) && year != "All") {
    year_num <- suppressWarnings(as.numeric(year))
    if (!is.na(year_num)) {
      year <- year_num
    }
  }

  #add a check for year input to see if it's in range
  min_year <- min(dfeR::lsip_lad$first_available_year_included)
  max_year <- max(dfeR::lsip_lad$most_recent_year_included)
  if (
    !(year == "All" || (year %% 1 == 0 && year >= min_year && year <= max_year))
  ) {
    stop(
      paste0(
        "year must either be 'All' or a valid year between ",
        min_year,
        " and ",
        max_year
      ),
      call. = FALSE
    )
  }
  lookup_data <- dfeR::lsip_lad
  cols <- c("lad_code", "lad_name", "lsip_code", "lsip_name")
  summarise_locations_by_year(lookup_data, cols, year)
}
