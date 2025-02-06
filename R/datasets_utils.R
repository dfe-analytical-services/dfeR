# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# INTERNAL ONLY FUNCTIONS #####################################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# These functions are only used by the scripts in data-raw/, but are kept here
# in order to keep those scripts cleaner and easier to use. To update any of
# the data used in this app, refer to the scripts kept in data-raw/.
#
# For more information on updating the geography data in the package see the
# 'Maintaining geography data' section of the .github/CONTRIBUTING.md file.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Tidy a lookup file from the Open Geography Portal
#'
#' Takes a file from the open geography portal and tidies it ready for
#' appending to an existing lookup
#'
#' @param raw_lookup_file data.frame of a lookup file downloaded from Open
#' Geography Portal, e.g. the output of `get_ons_api_data()`, or any other
#' data frame from R memory
#'
#' @keywords internal
#' @noRd
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
  new_year <- unique(gsub("[^0-9]", "", names(raw_lookup_file)))

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
#' Take a list of tidied files, likely produced by the tidy_raw_lookup
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
#' @noRd
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

  # Get the column names from the first data set as we know they all share the
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
        "first_available_year_included" =
          min(.data$first_available_year_included),
        "most_recent_year_included" =
          max(.data$most_recent_year_included),
        .by = dplyr::all_of(join_cols)
      )
  }

  # Final tidy up of the output file ==========================================
  # Pull out code columns
  code_cols <- names(lookup %>% dplyr::select(tidyselect::ends_with("_code")))

  # Order the file by year and then code columns
  sorted_lookup <- lookup %>%
    dplyr::mutate(
      "first_available_year_included" = as.integer(
        .data$first_available_year_included
      ),
      "most_recent_year_included" = as.integer(
        .data$most_recent_year_included
      )
    ) %>%
    dplyr::arrange(dplyr::desc("most_recent_year_included"), !!!code_cols)

  return(sorted_lookup)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Get Ward-PCon-LAD-LA data
#'
#' Helper function to extract data from the Ward-PCon-LAD-UTLA file
#'
#' @param year last two digits of the year of the lookup, available years are:
#' 2017, 2019, 2020, 2021, 2022, 2023, 2024
#'
#' @return data.frame for the individual year of the lookup
#'
#' @keywords internal
#' @noRd
get_wd_pcon_lad_la <- function(year) {
  # Crude way to grab 2 digits, works for anything that isn't in the noughties
  year_end <- year %% 100

  # Adjusting to the varying ids that ONS have used ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If there's any issues with these, double check the queries match up
  # Use the ONS query explorer on each file to check this
  # https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
  id_end <- dplyr::case_when(
    year_end == 23 ~ "_UK_LU_v1",
    year_end == 20 ~ "_UK_LU_v2_d8cbab26914f4dc1980250dbca6409d4",
    year_end == 17 ~ "_UK_LU_7d674672d1be40fdb94f4f26527a937a",
    .default = "_UK_LU"
  )

  # Specify the columns we want ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  levels <- c("WD", "PCON", "LAD", "UTLA")
  cols <- c("CD", "NM")
  field_names <- paste(
    as.vector(outer(paste0(levels, year_end), cols, paste0)),
    collapse = ","
  )

  # Main API call ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (year_end == 21) {
    # 2021 was only published as an excel file
    # Get the URL by right clicking to get the link on their download button
    download_21_url <- paste0(
      "https://www.arcgis.com/sharing/rest/content/items/",
      "d097a503aa2c4ad8a86263e1b094b6b2/data"
    )

    local_file <- tempfile(fileext = ".xlsx")
    utils::download.file(
      download_21_url,
      destfile = local_file,
      mode = "wb",
      quiet = TRUE
    )
    output <- as.data.frame(readxl::read_excel(path = local_file))
  } else {
    output <- get_ons_api_data(
      data_id = paste0(
        "WD", year_end, "_PCON", year_end, "_LAD", year_end,
        "_UTLA", year_end, id_end
      ),
      query_params = list(
        where = "1=1", outFields = field_names,
        outSR = "4326", f = "json"
      )
    )
  }

  # Tidy up the output file (defined earlier in this script)
  tidy_output <- tidy_raw_lookup(output)

  return(tidy_output)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Get LAD to Region lookup
#'
#' Helper function to extract data from the Ward-LAD-Region-County-Country file
#'
#' @param year last two digits of the year of the lookup, available years are:
#' 2017, 2018, 2019, 2020, 2022, 2023
#'
#' @return data.frame for the individual year of the lookup
#'
#' @keywords internal
#' @noRd
get_lad_region <- function(year) {
  # Crude way to grab 2 digits, works for anything that isn't in the noughties
  year_end <- year %% 100

  # Adjusting to the varying ids that ONS have used ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If there's any issues with these, double check the queries match up
  # Use the ONS query explorer on each file to check this
  # https://geoportal.statistics.gov.uk/search?tags=LUP_WD_LAD_CTY_RGN_GOR_CTRY
  id_end <- dplyr::case_when(
    year_end == 20 ~ "_OTH_UK_LU_v2_27715a77546b4b5a9746baf703dd9a05",
    year_end == 19 ~ "_OTH_UK_LU_89ea1f028be347e7a44d71743c96b60d",
    year_end == 18 ~ "_OTH_UK_LU_971f977f4a444d09842fcfbfd51f8982",
    year_end == 17 ~ "_OTH_UK_LUv2_c8956eca906348fd9e3bb1f6af54f2ce",
    .default = "_OTH_UK_LU"
  )

  # Specify the columns we want ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  levels <- c("LAD", "RGN")
  cols <- c("CD", "NM")

  # In their first two years ONS used GOR10NM / CD for regions...
  if (year_end %in% c(17, 18)) {
    field_names <- paste(
      c(
        paste0("LAD", year_end, "CD"), "GOR10CD",
        paste0("LAD", year_end, "NM"), "GOR10NM"
      ),
      collapse = ","
    )
  } else {
    field_names <- paste(
      as.vector(outer(paste0(levels, year_end), cols, paste0)),
      collapse = ","
    )
  }

  # Main API call ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  output <- get_ons_api_data(
    data_id = paste0(
      "WD", year_end, "_LAD", year_end, "_CTY", year_end, id_end
    ),
    query_params = list(
      where = "1=1", outFields = field_names,
      outSR = "4326", f = "json"
    )
  )

  # Rename the GOR10 cols for earlier years
  if (year_end %in% c(17, 18)) {
    output <- output %>%
      dplyr::rename_with(
        ~ ifelse(. == "attributes.GOR10NM", paste0("RGN", year_end, "NM"), .),
        "attributes.GOR10NM"
      ) %>%
      dplyr::rename_with(
        ~ ifelse(. == "attributes.GOR10CD", paste0("RGN", year_end, "CD"), .),
        "attributes.GOR10CD"
      )
  }

  # Tidy up the output file (defined earlier in this script)
  tidy_output <- tidy_raw_lookup(output)

  return(tidy_output)
}
