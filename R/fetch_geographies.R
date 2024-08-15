#' Fetch Westminster parliamentary constituencies
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

  resummarised_lookup <- lookup %>%
    dplyr::summarise(
      "first_available_year_included" =
        min(.data$first_available_year_included),
      "most_recent_year_included" =
        max(.data$most_recent_year_included),
      .by = c("pcon_name", "pcon_code")
    )

  # Return early without filtering if defaults are used
  if (all(years == "All", countries == "All")) {
    return(dplyr::distinct(resummarised_lookup))
  }

  # Filtering based on years and countries
  if (paste0(years, collapse = "") != "All") {
    resummarised_lookup <-
      with(
        resummarised_lookup,
        subset(resummarised_lookup, most_recent_year_included %in% years)
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

  return(dplyr::distinct(resummarised_lookup))
}

#' Fetch local authority districts
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
  # Function to check the inputs are valid
  check_fetch_location_inputs(years, countries)

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
  if (all(years == "All", countries == "All")) {
    return(dplyr::distinct(resummarised_lookup))
  }

  # Filtering based on years and countries
  if (paste0(years, collapse = "") != "All") {
    resummarised_lookup <-
      with(
        resummarised_lookup,
        subset(resummarised_lookup, most_recent_year_included %in% years)
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

  return(dplyr::distinct(resummarised_lookup))
}

#' Fetch local authorities
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
  # Function to check the inputs are valid
  check_fetch_location_inputs(years, countries)

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
  if (all(years == "All", countries == "All")) {
    return(dplyr::distinct(resummarised_lookup))
  }

  # Filtering based on years and countries
  if (paste0(years, collapse = "") != "All") {
    lookup <-
      with(
        resummarised_lookup,
        subset(resummarised_lookup, most_recent_year_included %in% years)
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

  return(dplyr::distinct(resummarised_lookup))
}
