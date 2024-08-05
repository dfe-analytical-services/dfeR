# TODO: should this be a non-exported function?
#' Tidy a lookup file from the Open Geography Portal
#'
#' Takes a file from the open geography portal and tidies it ready for
#' appending to an existing lookup
#'
#' @param open_geography_file data.frame of a lookup file downloaded from Open Geography Portal,
#' e.g. the output of `get_wd_pcon_lad_la()`, or `fetch_ons_api_data()`, or any other data frame
#' from R memory
#' @param shorthand_lookup data frame that gives the conversion from the Open
#' Geography Portal's shorthands to our column names, usually the open_geog_shorthand_lookup object
#' from earlier in this script
#'
#' @return a data frame of a tidied lookup file
tidy_downloaded_lookup <- function(
    new_data,
    shorthand_lookup) {
  # Tidy out the attributes. col prefix ---------------------------------------
  colnames(new_data) <- sub("^attributes\\.", "", colnames(new_data))

  # Extract the year from columns ---------------------------------------------
  new_year <- names(new_data) %>%
    # Remove the geog shorthands and CD / NM
    stringr::str_remove_all(paste(c(open_geog_shorthands, "CD", "NM"), collapse = "|")) %>%
    # Pull out the year
    unique()

  # Check there is only one year available ------------------------------------
  if (length(new_year) != 1) {
    stop(
      paste0(
        "There appears to be either zero or multiple years of data in the selected lookup",
        ", the function doesn't know which year to pick"
      )
    )
  }

  #' Function to rename columns using the shorthand_lookup table made in
  #' R/standard-data-prep/update-geography-lookups.R
  #'
  #' @param col_name single column name to be updated based on the shorthand
  #' lookup table
  #'
  #' @return string for new column name if a match was found, if no match found
  #' then the original name is returned
  generate_new_name <- function(col_name) {
    # Take the prefix and check it exists
    prefix <- str_extract(col_name, "^[A-Z]*")
    if (prefix %in% open_geog_shorthands) {
      # Take the suffix
      suffix <- str_sub(col_name, start = -2, end = -1)

      # Replace with either the name or code column as appropriate
      if (suffix == "NM") {
        new_name <- shorthand_lookup %>%
          filter(open_geog_shorthands == prefix) %>%
          pull(name_column)
      } else {
        new_name <- shorthand_lookup %>%
          filter(open_geog_shorthands == prefix) %>%
          pull(code_column)
      }

      message("Renaming ", col_name, " to ", new_name)
      return(new_name) # Return replaced name
    } else {
      message("No match found for ", col_name, ", returning original name")
      return(col_name) # Keep original name if no match
    }
  }

  # Apply the function to rename columns
  names(new_data) <- unlist(lapply(names(new_data), generate_new_name))

  # Add columns showing years for the codes
  new_lookup <- new_data %>%
    distinct() %>%
    mutate(
      first_available_year_included = paste0("20", new_year),
      most_recent_year_included = paste0("20", new_year)
    )

  # Remove ObjectId if it exists
  if (suppressWarnings(!is.null(new_lookup$ObjectId))) {
    new_lookup <- new_lookup %>% select(-ObjectId)
  }

  # Extra tidy up for separating LAs / LADs
  # This bit's to deal with LAs and UTLAs not being quite the same thing.
  # The parent UTLA for LADs in metropolitan counties (E11, e.g. Manchester),
  # and Inner or Outer London (E13) are the Metropolitan counties
  # and Inner / Outer London.
  # But in these cases, the LA for our purposes is the LAD itself.

  # So this is using the LAD as it's own parent LA if it's in a metropolitan
  # county or in London and taking the UTLA otherwise.

  # For example, Barnsley is a metropolitan borough of South Yorkshire
  # South Yorkshire is the UTLA, but we use Barnsley as the LA and LAD

  if ("new_la_code" %in% names(new_lookup)) {
    new_lookup <- new_lookup %>%
      mutate(
        la_name = if_else(
          grepl("E11", new_la_code) | grepl("E13", new_la_code),
          lad_name,
          la_name
        ),
        new_la_code = if_else(
          grepl("E11", new_la_code) | grepl("E13", new_la_code),
          lad_code,
          new_la_code
        )
      )
  }

  # Strip out excess white space from name columns
  new_lookup <- new_lookup %>%
    mutate(across(ends_with("_name"), ~ str_replace_all(.x, "\\s+", " "))) %>%
    # Also strip out leading and trailing whitespace for belts and braces
    mutate(across(everything(), ~ str_trim(.x)))

  return(new_lookup)
}

# TODO: should this be a non-exported function?
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Overwrite the existing lookup file by appending new data
#'
#' Take a list of tidied files, likely produced by the tidy_downloaded_lookup
#' function append together
#'
#' Updates the `first_available_year_included` and `most_recent_year_included`
#' columns so that they are accurate for the full ser-EES
#'
#' @param new_lookups list of data frames of new lookup table,
#' usually the output of tidy_downloaded_lookup
#' @param join_cols columns we care about for this timeseries
#'
#' @return single data.frame of all lookup files combined

create_time_series_lookup <- function(new_lookups) {
  # Input validation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Added some quick checks based on the assumptions we make in this function
  # Hoping this will prevent rogue error messages taking up lots of time in future
  # Check if the new_lookups list contains only data frames
  all_are_data_frames <- all(sapply(new_lookups, is.data.frame))

  if (all_are_data_frames) {
    # Get the column names for the first data frame (if it exists)
    if (length(new_lookups) > 0) {
      reference_cols <- colnames(new_lookups[[1]])

      # Compare column names across all data frames
      all_same_cols <- all(
        sapply(new_lookups, function(df) identical(colnames(df), reference_cols))
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

  # Start with the first data frame in the list
  initial_data_frame <- wd_upwards_list[1]

  # Append every other lookup in the list, starting with the second data frame
  for (lookup_number in 2:length(wd_upwards_list)) {
    next_data_frame <- wd_upwards_list[lookup_number]

    full_lookup <- initial_data_frame %>%
      # Stack the next data frame on
      rbind(next_data_frame) %>%
      # Then condense the rows, rewriting the first and last years for each row
      summarise(
        first_available_year_included = min(first_available_year_included),
        most_recent_year_included = max(most_recent_year_included),
        .by = all_of(join_cols)
      )
  }






  # Final tidy up of the output file ==========================================
  # Select only columns that we expect
  # Start with any possible column from the shorthand table
  expected_columns <- potential_cols %>%
    # Filter to only the ones that exist in the new file too
    intersect(names(updated_lookup))

  # Select the columns we expect
  updated_lookup <- updated_lookup[, expected_columns]

  # Pull out code columns
  sorting_cols <- names(updated_lookup %>% select(ends_with("_code")))

  # Order the file by year and then code columns
  updated_lookup <- updated_lookup %>% arrange(desc(most_recent_year_included), !!!sorting_cols)

  # Update the existing lookup
  message("Writing new lookup to: ", lookup_filepath)
  tryCatch(
    {
      write_csv(updated_lookup, file = paste(lookup_filepath))
      message("...", lookup_filepath, " successfully written")
    },
    error = function(msg) {
      message("Issue writing lookup file. Try looking at the code within the `write_updated_lookup()` function and running in the console separately.")
    }
  )
}
