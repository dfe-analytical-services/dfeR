#' Fetch Westminster parliamentary constituencies
#'
#' Fetch a data frame of all Westminster Parliamentary Constituencies for a
#' given year and country based on the dfeR::geo_hierarchy file.
#'
#' @param year year to filter the locations to, default is "All",
#' options of 2017, 2019, 2020, 2021, 2022, 2023, 2024, 2025
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
#' head(fetch_lsips())
#'
#' head(fetch_lsips(2025))
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
#' options of 2017, 2019, 2020, 2021, 2022, 2023, 2024, 2025
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

#' Fetch Westminster constituency to MP lookup
#'
#' Fetch a data frame with one row per Westminster parliamentary constituency
#' and the MP currently sitting for it. Alongside the constituency name and
#' code, it gives the MP's name, Parliament member ID, party, email address
#' and 2024 general election result summary, plus the local authority
#' districts, local authorities, mayoral authorities, region and country that
#' each constituency maps to.
#'
#' The lookup is maintained in the
#' \href{https://github.com/dfe-analytical-services/mp-lookup}{mp-lookup}
#' repository. It updates automatically as new results are
#' published, and is read directly from its GitHub-hosted CSV so that users
#' don't need to know or find the URL themselves.
#'
#' Note that this is a lookup of sitting MPs, not a set of candidate-level
#' results, so unsuccessful candidates are not included.
#'
#' @param verbose TRUE or FALSE boolean. TRUE by default. FALSE will turn off
#' the messages to the console that update on what the function is doing
#'
#' @return data frame with one row per Westminster parliamentary constituency
#' and its sitting MP
#' @export
#'
#' @examples
#' \donttest{
#' head(fetch_mp_lookup())
#' }
fetch_mp_lookup <- function(verbose = TRUE) {
  mp_lookup_url <- paste0(
    "https://raw.githubusercontent.com/dfe-analytical-services",
    "/mp-lookup/refs/heads/main/mp_lookup.csv"
  )

  dfeR::toggle_message("Fetching MP lookup data...", verbose = verbose)

  output <- tryCatch(
    utils::read.csv(
      mp_lookup_url,
      check.names = FALSE,
      encoding = "UTF-8"
    ),
    error = function(e) {
      stop(
        "Failed to fetch MP lookup data from:\n",
        mp_lookup_url,
        "\n\nOriginal error: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  dfeR::toggle_message("...data fetched!", verbose = verbose)

  output
}

#' Fetch Local Skills Improvement Plan (LSIP) areas lookup
#'
#' Fetch a data frame of Local Skills Improvement Plan (LSIP) areas
#' for a given year based on `dfeR::lsip_lad`.
#'
#' @param year year to filter the locations to, default is "All",
#' options of 2023 or 2025. ONS did not publish a 2024 lookup, so 2024 is not
#' a valid option
#' @family fetch_locations
#' @return data frame of LSIP for a given year.
#' @export
#' @inherit fetch examples
fetch_lsips <- function(year = "All") {
  # LSIP lookups have a gap in their years (no 2024), so we give the exact
  # years published rather than letting the year range be inferred
  check_fetch_location_inputs(
    year,
    "England",
    dfeR::lsip_lad,
    valid_years = c(2023, 2025)
  )

  fetch_locations(
    lookup_data = dfeR::lsip_lad,
    cols = c("lsip_code", "lsip_name"),
    year = year,
    countries = "All"
  )
}
