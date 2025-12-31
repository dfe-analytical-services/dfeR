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
    "^attributes\\.",
    "",
    colnames(raw_lookup_file)
  )

  # Extract the year from columns ---------------------------------------------
  # Remove all non-digits from column names
  new_year <- unique(gsub("[^0-9]", "", names(raw_lookup_file)))

  # Check there is only one year available -------------------------------------
  # If more than one, just take the latest but with a warning
  if (length(new_year) != 1) {
    new_year <- max(new_year)
    warning(
      paste0(
        "There appears to be either zero or multiple years of data in the ",
        "selected lookup, the function doesn't know which year to pick. ",
        "Taking the latest year and hoping! Latest year end: ",
        new_year
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

      new_name # Return replaced name
    } else {
      message("No match found for ", col_name, ", returning original name")

      col_name # Keep original name if no match
    }
  }

  # Apply the function to rename columns
  names(raw_lookup_file) <- unlist(
    lapply(names(raw_lookup_file), generate_new_name)
  )

  # Add columns showing years for the codes
  lookup_with_time <- raw_lookup_file |>
    dplyr::distinct() |>
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
  lookup_met_la |>
    dplyr::mutate(
      dplyr::across(
        tidyselect::ends_with("_name"),
        ~ stringr::str_replace_all(.x, "\\s+", " ")
      )
    ) |>
    # Also strip out leading and trailing whitespace for belts and braces
    dplyr::mutate(dplyr::across(dplyr::everything(), ~ stringr::str_trim(.x)))
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
    lookup <- lookup |>
      # Stack the next data frame on
      rbind(lookups_list[[lookup_number]]) |>
      # Then condense the rows, rewriting the first and last years for each row
      dplyr::summarise(
        "first_available_year_included" = min(
          .data$first_available_year_included
        ),
        "most_recent_year_included" = max(.data$most_recent_year_included),
        .by = dplyr::all_of(join_cols)
      )
  }

  # Final tidy up of the output file ==========================================
  # Pull out code columns
  code_cols <- names(lookup |> dplyr::select(tidyselect::ends_with("_code")))

  # Order the file by year and then code columns
  lookup |>
    dplyr::mutate(
      "first_available_year_included" = as.integer(
        .data$first_available_year_included
      ),
      "most_recent_year_included" = as.integer(
        .data$most_recent_year_included
      )
    ) |>
    dplyr::arrange(dplyr::desc("most_recent_year_included"), !!!code_cols)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lengthen a timeseries table to have rows for every year
#'
#' Takes a lookup table with first and last years included and creates rows for
#' every year.
#'
#' @param short_lookup_file data.frame of a lookup file created by using
#' create_time_series_lookup()
#'
#' @keywords internal
#' @noRd
#' @return an exploded data frame of a time series lookup file
explode_timeseries <- function(short_lookup_file) {
  if (
    !all(
      c("first_available_year_included", "most_recent_year_included") %in%
        names(short_lookup_file)
    )
  ) {
    stop(
      paste(
        "Input data frame must contain 'first_available_year_included'",
        "and 'most_recent_year_included' columns."
      )
    )
  }

  # Remove the two time columns for later re-adding
  base_cols <- setdiff(
    names(short_lookup_file),
    c("first_available_year_included", "most_recent_year_included")
  )

  # For each row, create a sequence of years and expand the data
  tidyr::uncount(
    short_lookup_file,
    weights = .data$most_recent_year_included -
      .data$first_available_year_included +
      1,
    .remove = FALSE
  ) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(base_cols))) |>
    dplyr::mutate(
      year = .data$first_available_year_included + dplyr::row_number() - 1
    ) |>
    dplyr::ungroup() |>
    dplyr::select(dplyr::all_of(base_cols), "year")
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Shorten a timeseries table to from having rows for every year
#'
#' Takes a lookup table with rows for every year in a year column and creates
#' rows with first and last years included.
#'
#' @param long_lookup_file data.frame of a lookup file that has a year column
#' with one row per year
#'
#' @keywords internal
#' @noRd
#' @return a collapsed data frame of a time series lookup file
collapse_timeseries <- function(long_lookup_file) {
  if (!"year" %in% names(long_lookup_file)) {
    stop("Input data frame must contain a 'year' column.")
  }

  base_cols <- setdiff(names(long_lookup_file), "year")

  long_lookup_file |>
    dplyr::group_by(dplyr::across(dplyr::all_of(base_cols))) |>
    dplyr::summarise(
      first_available_year_included = min(.data$year, na.rm = TRUE),
      most_recent_year_included = max(.data$year, na.rm = TRUE),
      .groups = "drop"
    )
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Get Ward-PCon-LAD-LA data
#'
#' Helper function to extract data from the Ward-PCon-LAD-UTLA file
#'
#' @param year last two digits of the year of the lookup, tested years are:
#' 2017, 2019, 2020, 2021, 2022, 2023, 2024, 2025
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
  if (year_end == 25) {
    # Changed UTLA to CTYUA in 25, if same for 2026, set as new default and
    # ...put the else under a if(year_end < 25) condition
    # In 2025 they still used 2024 PCons so harcoding for EES-e
    field_names <-
      "WD25CD,PCON24CD,LAD25CD,CTYUA25CD,WD25NM,PCON24NM,LAD25NM,CTYUA25NM"
  } else {
    levels <- c("WD", "PCON", "LAD", "UTLA")
    cols <- c("CD", "NM")
    field_names <- paste(
      as.vector(outer(paste0(levels, year_end), cols, paste0)),
      collapse = ","
    )
  }

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
        "WD",
        year_end,
        "_PCON",
        # 25 lookup uses 24 PCons...
        dplyr::if_else(year_end == 25, 24, year_end),
        "_LAD",
        year_end,
        # Format changed from UTLA to CTYUA in 25, if same in 26 then set as the
        # ...default moving forwards
        dplyr::if_else(year_end == 25, "_CTYUA", "_UTLA"),
        year_end,
        id_end
      ),
      query_params = list(
        where = "1=1",
        outFields = field_names,
        outSR = "4326",
        f = "json"
      )
    )
  }

  # Tidy up the output file (defined earlier in this script)
  tidy_raw_lookup(output)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Get LAD to Region lookup
#'
#' Helper function to extract data from the Ward-LAD-Region-County-Country file
#'
#' @param year last two digits of the year of the lookup, tested years are:
#' 2017, 2018, 2019, 2020, 2022, 2023, 2024, 2025
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
    year_end %in% c(21, 22, 23) ~ "_OTH_UK_LU",
    year_end == 20 ~ "_OTH_UK_LU_v2_27715a77546b4b5a9746baf703dd9a05",
    year_end == 19 ~ "_OTH_UK_LU_89ea1f028be347e7a44d71743c96b60d",
    year_end == 18 ~ "_OTH_UK_LU_971f977f4a444d09842fcfbfd51f8982",
    year_end == 17 ~ "_OTH_UK_LUv2_c8956eca906348fd9e3bb1f6af54f2ce",
    .default = "_UK_LU"
  )

  # Specify the columns we want ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  levels <- c("LAD", "RGN")
  cols <- c("CD", "NM")

  # In their first two years ONS used GOR10NM / CD for regions...
  if (year_end %in% c(17, 18)) {
    field_names <- paste(
      c(
        paste0("LAD", year_end, "CD"),
        "GOR10CD",
        paste0("LAD", year_end, "NM"),
        "GOR10NM"
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
  if (year == 2024) {
    # They changed it up in 2024
    data_id <- paste0(
      "WD",
      year_end,
      "_LAD",
      year_end,
      "_CTYUA_RGN_CTRY",
      id_end
    )
  } else if (year < 2024) {
    data_id <- paste0(
      "WD",
      year_end,
      "_LAD",
      year_end,
      "_CTY",
      year_end,
      id_end
    )
  } else {
    # 2025 onwards
    data_id <- paste0(
      "WD",
      year_end,
      "_LAD",
      year_end,
      "_CTYUA",
      year_end,
      "_RGN",
      year_end,
      "_CTRY",
      year_end,
      id_end
    )
  }

  output <- get_ons_api_data(
    data_id = data_id,
    query_params = list(
      where = "1=1",
      outFields = field_names,
      outSR = "4326",
      f = "json"
    )
  )

  # Rename the GOR10 cols for earlier years
  if (year_end %in% c(17, 18)) {
    output <- output |>
      dplyr::rename_with(
        ~ ifelse(. == "attributes.GOR10NM", paste0("RGN", year_end, "NM"), .),
        "attributes.GOR10NM"
      ) |>
      dplyr::rename_with(
        ~ ifelse(. == "attributes.GOR10CD", paste0("RGN", year_end, "CD"), .),
        "attributes.GOR10CD"
      )
  }

  # Tidy up the output file (defined earlier in this script)
  tidy_raw_lookup(output)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Get LAD to Combined Mayoral Authority lookup
#'
#' Helper function to extract data from the LAD-CMA files
#'
#' @param year last two digits of the year of the lookup, available years are:
#' 2017, 2018, 2019, 2020, 2021 2022, 2023, 2024, 2025
#'
#' @return data.frame for the individual year of the lookup
#'
#' @keywords internal
#' @noRd
get_cauth_lad <- function(year) {
  # Crude way to grab 2 digits, works for anything that isn't in the noughties
  year_end <- year %% 100

  # Adjusting to the varying ids that ONS have used ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If there's any issues with these, double check the queries match up
  # Use the ONS query explorer on each file to check this
  # https://geoportal.statistics.gov.uk/search?tags=LUP_LAD_CAUTH
  id_end <- dplyr::case_when(
    year_end == 20 ~ "_EN_LU_61359c2aabb7421caefd36c3516a823e",
    year_end == 19 ~ "_EN_LU_731e5d9e5787404c97dd8d8fb0e23854",
    year_end == 18 ~ "_EN_LU_v2_0e5ff75a9ac6484ab9164d493e459c88",
    year_end == 17 ~ "_EN_LU_db0ce93885064b5181fb325b7752de85",
    .default = "_EN_LU"
  )

  # Specify the columns we want ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  levels <- c("LAD", "CAUTH")
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
      "075f371689d6441f9369a1c3401af682/data"
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
        "LAD",
        year_end,
        "_CAUTH",
        year_end,
        id_end
      ),
      query_params = list(
        where = "1=1",
        outFields = field_names,
        outSR = "4326",
        f = "json"
      )
    )
  }

  # Tidy up the output file (defined earlier in this script)
  tidy_raw_lookup(output)
}

#' Fetch and combine LSIP-LAD lookup data for multiple years
#'
#' Downloads, binds, and tidies LSIP-LAD lookup data from ONS Geography portal API for multiple years.
#' The function constructs the correct URLs for each year, fetches the data, adds a year column, and combines all years into a single data frame.
#' It then collapses the time series to add `first_available_year_included` and `most_recent_year_included` columns, and removes duplicates.
#'
#' @return A data frame containing the combined LSIP-LAD lookup for all years, with columns for codes, names, year, and operational period.
#' @keywords internal
#' @noRd
get_lsip_lad <- function() {

  url_suffix <- "/FeatureServer/0/query?outFields=*&where=1%3D1&f=json"
  #Create an empty list to store data frames
  data_frames <- list()
  #Loop through each year and fetch data
  for (year in names(yr_specific_url)) {
    #Construct the full URL
    full_url <- paste0(url_prefix, yr_specific_url[[year]], url_suffix)

    #Make the GET request and parse the JSON response
    response <- httr::GET(full_url)
    # get the content and convert from json
    data <- jsonlite::fromJSON(httr::content(response, "text"))

    #Extract the attributes and convert to data frame
    df <- as.data.frame(data$features$attributes) |>
      #create a year column
      dplyr::mutate(year = as.integer(year)) |>
      #rename columns based on position so binding works
      dplyr::select(
        year,
        lad_code = 1,
        lad_name = 2,
        lsip_code = 3,
        lsip_name = 4
      )

    #put the data frame into the list
    data_frames[[year]] <- df
  }
  #Combine all data frames into one
  combined_df <- do.call(rbind, data_frames)
  #get first_available and most_recent year columns
  combined_df <- combined_df %>%
    collapse_timeseries() |>
    #make sure we remove duplicates
    dplyr::distinct()
    
  combined_df
}
