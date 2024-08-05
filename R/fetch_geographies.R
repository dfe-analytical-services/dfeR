#' fetch_ons_api_data
#'
#' Helper function that takes a dataset id and parameters to query and parse
#' data from the ONS API
#'
#' On the ONS website, find the dataset you're interested in and then use the
#' query explorer to find the information for the query
#'
#' @param data_id the id of the dataset to query, can be found from the Open
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



# Functions to create for unique locations by first and last available year
# fetch_countries
# fetch_regions
# fetch_las
# fetch_lads
# fetch_pcons
# fetch_wards
# fetch_leps
# fetch_eda?


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# INTERNAL ONLY FUNCTIONS #####################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Tidy a lookup file from the Open Geography Portal
#'
#' Takes a file from the open geography portal and tidies it ready for
#' appending to an existing lookup
#'
#' @param raw_lookup_file data.frame of a lookup file downloaded from Open
#' Geography Portal, e.g. the output of `fetch_ons_api_data()`, or any other
#' data frame from R memory
#'
#' @keywords internal
#' @return a data frame of a tidied lookup file
tidy_raw_lookup <- function(raw_lookup_file) {
  if (!is.data.frame(raw_lookup_file)) {
    stop("raw_lookup_file must be a data frame")
  }

  # Tidy out the attributes. col prefix ---------------------------------------
  colnames(raw_lookup_file) <- sub(
    "^attributes\\.", "", colnames(raw_lookup_file)
  )

  # Extract the year from columns ---------------------------------------------
  # Remove all non-digits from column names
  new_year <- gsub("[^0-9]", "", names(raw_lookup_file)) %>%
    unique()

  # Check there is only one year available ------------------------------------
  if (length(new_year) != 1) {
    stop(
      paste0(
        "There appears to be either zero or multiple years of data in the ",
        "selected lookup, the function doesn't know which year to pick"
      )
    )
  }

  #' Function to rename columns using the dfeR::ons_geog_shorthands table
  #'
  #' col_name single column name to be updated based on the shorthand
  #' lookup table
  #'
  #' @return string for new column name if a match was found, if no match found
  #' then the original name is returned
  generate_new_name <- function(col_name) {
    # Take the prefix and check it exists
    prefix <- stringr::str_extract(col_name, "^[A-Z]*")
    if (prefix %in% dfeR::ons_geog_shorthands$ons_level_shorthands) {
      # Take the suffix
      suffix <- stringr::str_sub(col_name, start = -2, end = -1)

      # Replace with either the name or code column as appropriate
      if (suffix == "NM") {
        new_name <- dfeR::ons_geog_shorthands[
          dfeR::ons_geog_shorthands$ons_level_shorthands == prefix,
        ]$name_column
      } else {
        new_name <- dfeR::ons_geog_shorthands[
          dfeR::ons_geog_shorthands$ons_level_shorthands == prefix,
        ]$code_column
      }

      message("Renaming ", col_name, " to ", new_name)
      return(new_name) # Return replaced name
    } else {
      message("No match found for ", col_name, ", returning original name")
      return(col_name) # Keep original name if no match
    }
  }

  # Apply the function to rename columns
  names(raw_lookup_file) <- unlist(
    lapply(names(raw_lookup_file), generate_new_name)
  )

  # Add columns showing years for the codes
  lookup_with_time <- raw_lookup_file %>%
    dplyr::distinct() %>%
    dplyr::mutate(
      first_available_year_included = paste0("20", new_year),
      most_recent_year_included = paste0("20", new_year)
    )

  # Extra tidy up for separating LAs / LADs
  # This bit is to deal with LAs and UTLAs not being quite the same thing.
  # The parent UTLA for LADs in metropolitan counties (E11, e.g. Manchester),
  # and Inner or Outer London (E13) are the Metropolitan counties
  # and Inner / Outer London.
  # But in these cases, the LA for our purposes is the LAD itself.

  # So this is using the LAD as it's own parent LA if it's in a metropolitan
  # county or in London and taking the UTLA otherwise.

  # For example, Barnsley is a metropolitan borough of South Yorkshire
  # South Yorkshire is the UTLA, but we use Barnsley as the LA and LAD

  lookup_met_la <- lookup_with_time

  if ("new_la_code" %in% names(raw_lookup_file)) {
    met_swap <- grepl("E11", lookup_met_la$new_la_code) |
      grepl("E13", lookup_met_la$new_la_code)

    # Update la_name and new_la_code based on the conditions
    lookup_met_la$la_name[met_swap] <- lookup_met_la$lad_name[met_swap]
    lookup_met_la$new_la_code[met_swap] <- lookup_met_la$lad_code[met_swap]
  }

  # Strip out excess white space from name columns
  tidied_lookup <- lookup_met_la %>%
    dplyr::mutate(
      dplyr::across(
        tidyselect::ends_with("_name"),
        ~ stringr::str_replace_all(.x, "\\s+", " ")
      )
    ) %>%
    # Also strip out leading and trailing whitespace for belts and braces
    dplyr::mutate(dplyr::across(dplyr::everything(), ~ stringr::str_trim(.x)))

  return(tidied_lookup)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Smush lookups together to make a time series
#'
#' Take a list of tidied files, likely produced by the tidy_downloaded_lookup
#' function append together
#'
#' Updates the `first_available_year_included` and `most_recent_year_included`
#' columns so that they are accurate for the full ser-EES
#'
#' @keywords internal
#' @param lookups_list list of data frames of new lookup table,
#' usually the output of tidy_raw_lookup
#'
#' @return single data.frame of all lookup files combined

create_time_series_lookup <- function(lookups_list) {
  # Input validation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Added some quick checks based on the assumptions we make in this function
  # Hoping this will prevent rogue error messages taking up lots of time in
  # future

  # Check if the new_lookups list contains only data frames
  all_are_data_frames <- all(sapply(lookups_list, is.data.frame))

  if (all_are_data_frames) {
    # Get the column names for the first data frame (if it exists)
    if (length(lookups_list) > 0) {
      reference_cols <- colnames(lookups_list[[1]])

      # Compare column names across all data frames
      all_same_cols <- all(
        sapply(
          lookups_list,
          function(df) identical(sort(colnames(df)), sort(reference_cols))
        )
      )

      if (all_same_cols) {
        # Nothing to see here
      } else {
        stop("data frames within the list have different column names.")
      }
    } else {
      stop("the new_lookups list is empty")
    }
  } else {
    stop("the new_lookups list contains items that are not data frames")
  }
  # End of input validation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Get the column names from the first dataset as we know they all share the
  # same cols, these are used to aggregate by when working out the years
  #
  # Drop the time cols so we only join on the geography cols
  join_cols <- setdiff(
    names(lookups_list[[1]]),
    c("first_available_year_included", "most_recent_year_included")
  )

  # Start with the first data frame in the list
  lookup <- lookups_list[[1]]

  # Append every other lookup in the list, starting with the second data frame
  for (lookup_number in 2:length(lookups_list)) {
    lookup <- lookup %>%
      # Stack the next data frame on
      rbind(lookups_list[[lookup_number]]) %>%
      # Then condense the rows, rewriting the first and last years for each row
      dplyr::summarise(
        first_available_year_included = min(first_available_year_included),
        most_recent_year_included = max(most_recent_year_included),
        .by = dplyr::all_of(join_cols)
      )
  }

  # Final tidy up of the output file ==========================================
  # Pull out code columns
  code_cols <- names(lookup %>% dplyr::select(tidyselect::ends_with("_code")))

  # Order the file by year and then code columns
  sorted_lookup <- lookup %>%
    dplyr::arrange(dplyr::desc("most_recent_year_included"), !!!code_cols)

  # Return the tidied data frame ==============================================
  return(sorted_lookup)
}
