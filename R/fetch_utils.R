#' Validation for fetch location lookups
#'
#' @param year_input the value of the years input
#' @param country_input the value of the countries input
#'
#' @return nothing, unless a failure, and then it will give an error
#' @keywords internal
#' @noRd
check_fetch_location_inputs <- function(year_input, country_input) {
  if (year_input != "All") {
    if (!grepl("^\\d{4}$", as.character(year_input))) {
      stop(
        "year must either be 'All', or a valid 4 digit year e.g. '2024'"
      )
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

#' Fetch locations for a given lookup
#'
#' Helper function for the fetch_xxx() functions to save repeating code
#'
#' @param lookup_data lookup data to use to extract locations from
#' @param cols columns to extract from the main lookup table
#' @param year year of locations to extract, "All" will skip any filtering and
#' return all possible locations
#' @param countries countries for locations to be take from, "All" will skip
#' any filtering and return all
#'
#' @return a data frame of location names and codes
#' @keywords internal
#' @noRd
fetch_locations <- function(lookup_data, cols, year, countries) {
  # Return only the cols we specified
  # We know their position from the dplyr selection of the lookup
  # This is used wherever this function returns an output
  cols_to_return <- seq_along(cols)

  # Pull in main lookup data
  lookup <- dplyr::select(
    lookup_data,
    dplyr::all_of(
      c(cols, "first_available_year_included", "most_recent_year_included")
    )
  )

  # Resummarise the years to each unique location
  resummarised_lookup <- lookup %>%
    dplyr::summarise(
      "first_available_year_included" =
        min(.data$first_available_year_included),
      "most_recent_year_included" =
        max(.data$most_recent_year_included),
      .by = dplyr::all_of(cols)
    )

  # Return early without filtering if defaults are used
  if (all(year == "All", countries == "All")) {
    return(dplyr::distinct(resummarised_lookup[, cols_to_return]))
  }

  # Filter based on year selection if specified
  if (year != "All") {
    # Flag the rows that are in the year asked for
    resummarised_lookup <- resummarised_lookup %>%
      dplyr::mutate("in_specified_year" = ifelse(
        as.numeric(.data$most_recent_year_included) >= year &
          as.numeric(.data$first_available_year_included) <= year,
        TRUE,
        FALSE
      ))

    # Filter to only those locations
    resummarised_lookup <- with(
      resummarised_lookup,
      subset(resummarised_lookup, in_specified_year == TRUE)
    ) %>%
      dplyr::select(-c("in_specified_year")) # remove temp column
  }

  # Filter based on country selcetion if specified
  if (paste0(countries, collapse = "") != "All") {
    # Get the code column
    # Take new_la_code if present (as sometimes there may also be old_la code)
    # Otherwise work it out
    if ("new_la_code" %in% cols) {
      code_col <- "new_la_code"
    } else {
      code_col <- grep("_code$", cols, value = TRUE)
    }

    if (length(code_col) != 1) {
      stop(
        "More than one code column found, there must only be one code column"
      )
    }

    # Filter every value to its first letter as that matches the ONS code
    # then filter the data set to only have codes from the selected countries
    resummarised_lookup <- resummarised_lookup %>%
      dplyr::filter(
        grepl(
          paste0("^", unique(substr(countries, 1, 1)), collapse = "|"),
          !!rlang::sym(code_col)
        )
      )
  }

  return(dplyr::distinct(resummarised_lookup[, cols_to_return]))
}
