#' Fetch Westminster parliamentary constituencies
#'
#' Fetch a data frame of all Westminster Parliamentary Constituencies for a
#' given year and country based on the dfeR::wd_pcon_lad_la file
#'
#' @param year year to filter the locations to, default is "All",
#' options of "2017", "2019", "2020", "2021", "2022", "2023", "2024"
#' @param countries vector of desired countries to filter the locations to,
#' default is "All", or can be a vector with options of "England", "Scotland",
#' "Wales" or "Northern Ireland"
#'
#' @return data frame of unique location names and codes
#' @export
#'
#' @name fetch
#' @examples
#' fetch_pcons()
#' fetch_pcons("2023")
#' fetch_pcons(countries = "Scotland")
#' fetch_pcons(year = "2023", countries = c("England", "Wales"))
#'
#' fetch_las("2024", "Wales")
#'
#' fetch_pcons("2022", "Northern Ireland")
fetch_pcons <- function(year = "All", countries = "All") {
  # Function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Filter the lookup to the columns we care about
  pcon_cols <- c(
    "pcon_code", "pcon_name", "first_available_year_included",
    "most_recent_year_included"
  )

  lookup <- dplyr::select(dfeR::wd_pcon_lad_la, dplyr::all_of(pcon_cols))

  resummarised_lookup <- lookup %>%
    dplyr::summarise(
      "first_available_year_included" =
        min(.data$first_available_year_included),
      "most_recent_year_included" =
        max(.data$most_recent_year_included),
      .by = c("pcon_name", "pcon_code")
    )

  # Return early without filtering if defaults are used
  if (all(year == "All", countries == "All")) {
    # Drop the time cols
    return(dplyr::distinct(resummarised_lookup[, 1:2]))
  }

  # Filtering based on years and countries
  if (year != "All") {
    resummarised_lookup <-
      with(
        resummarised_lookup,
        subset(resummarised_lookup, most_recent_year_included == year)
      )
  }
  if (paste0(countries, collapse = "") != "All") {
    # Filter every value to its first letter as that matches the ONS code
    # then filter the data set to only have codes from the selected countries
    resummarised_lookup <- with(
      resummarised_lookup,
      subset(
        resummarised_lookup,
        grepl(
          paste0("^", unique(substr(countries, 1, 1)), collapse = "|"),
          pcon_code
        )
      )
    )
  }

  # Drop the time cols
  return(dplyr::distinct(resummarised_lookup[, 1:2]))
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
  # Function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Filter the lookup to the columns we care about
  lad_cols <- c(
    "lad_code", "lad_name", "first_available_year_included",
    "most_recent_year_included"
  )

  lookup <- dplyr::select(dfeR::wd_pcon_lad_la, dplyr::all_of(lad_cols))

  resummarised_lookup <- lookup %>%
    dplyr::summarise(
      "first_available_year_included" =
        min(.data$first_available_year_included),
      "most_recent_year_included" =
        max(.data$most_recent_year_included),
      .by = c("lad_name", "lad_code")
    )

  # Return early without filtering if defaults are used
  if (all(year == "All", countries == "All")) {
    # Drop the time cols
    return(dplyr::distinct(resummarised_lookup[, 1:2]))
  }

  # Filtering based on years and countries
  if (year != "All") {
    resummarised_lookup <-
      with(
        resummarised_lookup,
        subset(resummarised_lookup, most_recent_year_included == year)
      )
  }
  if (paste0(countries, collapse = "") != "All") {
    # Filter every value to its first letter as that matches the ONS code
    # then filter the data set to only have codes from the selected countries
    resummarised_lookup <- with(
      resummarised_lookup,
      subset(
        resummarised_lookup,
        grepl(
          paste0("^", unique(substr(countries, 1, 1)), collapse = "|"),
          lad_code
        )
      )
    )
  }

  # Drop the time cols
  return(dplyr::distinct(resummarised_lookup[, 1:2]))
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
  # Function to check the inputs are valid
  check_fetch_location_inputs(year, countries)

  # Filter the lookup to the columns we care about
  la_cols <- c(
    "new_la_code", "la_name", "first_available_year_included",
    "most_recent_year_included"
  )

  lookup <- dplyr::select(dfeR::wd_pcon_lad_la, dplyr::all_of(la_cols))

  resummarised_lookup <- lookup %>%
    dplyr::summarise(
      "first_available_year_included" =
        min(.data$first_available_year_included),
      "most_recent_year_included" =
        max(.data$most_recent_year_included),
      .by = c("la_name", "new_la_code")
    )

  # Return early without filtering if defaults are used
  if (all(year == "All", countries == "All")) {
    # Drop the time cols
    return(dplyr::distinct(resummarised_lookup[, 1:2]))
  }

  # Filtering based on years and countries
  if (year != "All") {
    resummarised_lookup <-
      with(
        resummarised_lookup,
        subset(resummarised_lookup, most_recent_year_included == year)
      )
  }
  if (paste0(countries, collapse = "") != "All") {
    # Filter every value to its first letter as that matches the ONS code
    # then filter the data set to only have codes from the selected countries
    resummarised_lookup <- with(
      resummarised_lookup,
      subset(
        resummarised_lookup,
        grepl(
          paste0("^", unique(substr(countries, 1, 1)), collapse = "|"),
          new_la_code
        )
      )
    )
  }

  # Drop the time cols
  return(dplyr::distinct(resummarised_lookup[, 1:2]))
}
