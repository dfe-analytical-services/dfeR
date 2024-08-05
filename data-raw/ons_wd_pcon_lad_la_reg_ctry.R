# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Created: 05/08/2024, Cam Race
#
# TODO: update these notes
# This script has a number of helper functions and variables set at the start
# The main code that actually creates and updates the lookup is under the heading:
# - Create wd_pcon_lad_la_reg_ctry
#
# If updating the data, follow these steps:
# 1.
# 2.
# 3.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Dependencies ================================================================
library(dplyr)
library(stringr)

# Helpful variables ===========================================================
# Names of time columns
time_cols <- c(
  "first_available_year_included",
  "most_recent_year_included"
)

# Create a lookup table for shorthand to levels we care about
open_geog_shorthands <- c("WD", "PCON", "LAD", "UTLA")
name_column <- paste0(c("ward", "pcon", "lad", "la"), "_name")
code_column <- paste0(c("ward", "pcon", "lad", "new_la"), "_code")

open_geog_shorthand_lookup <- data.frame(
  open_geog_shorthands,
  name_column,
  code_column
)

# Create a vector of potential expected cols in lookups
potential_cols <- c(
  time_cols,
  unlist(open_geog_shorthand_lookup$name_column, use.names = FALSE),
  unlist(open_geog_shorthand_lookup$code_column, use.names = FALSE)
)

# Helper functions ============================================================

#########################################################################
# TESTING

# Pull in the different years
year_24 <- tidy_downloaded_lookup(get_wd_pcon_lad_la(24), open_geog_shorthand_lookup)
year_23 <- tidy_downloaded_lookup(get_wd_pcon_lad_la(23), open_geog_shorthand_lookup)
year_22 <- tidy_downloaded_lookup(get_wd_pcon_lad_la(22), open_geog_shorthand_lookup)
year_21 <- tidy_downloaded_lookup(get_wd_pcon_lad_la(21), open_geog_shorthand_lookup)
year_20 <- tidy_downloaded_lookup(get_wd_pcon_lad_la(20), open_geog_shorthand_lookup)
year_19 <- tidy_downloaded_lookup(get_wd_pcon_lad_la(19), open_geog_shorthand_lookup)
# Nothing published for 2018
year_17 <- tidy_downloaded_lookup(get_wd_pcon_lad_la(17), open_geog_shorthand_lookup)


wd_upwards_list <- list(
  year_24,
  year_23,
  year_22,
  year_21,
  year_20,
  year_19,
  year_17
)


# --------------------




create_wd_pcon_lad_la <- function(levels, year) {
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #' get_wd_pcon_lad_la
  #'
  #' Helper function to extract data from the Ward-PCon-LAD-UTLA file
  #'
  #' @param year last two digits of the year of the lookup, available years are:
  #' 2017, 2019, 2020, 2021, 2022, 2023, 2024
  #'
  #' @return data.frame for the individual year of the lookup
  #'
  #' @examples
  #' get_wd_pcon_lad_la("23")
  get_wd_pcon_lad_la <- function(year) {
    # Adjusting to the varying ids that ONS have used ~~~~~~~~~~~~~~~~~~~~~~~~~
    # If there's any issues with these, double check the queries match up
    # Use the ONS query explorer on each file to check this
    # https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
    id_end <- dplyr::case_when(
      year == 23 ~ "_UK_LU_v1",
      year == 20 ~ "_UK_LU_v2_d8cbab26914f4dc1980250dbca6409d4",
      year == 17 ~ "_UK_LU_7d674672d1be40fdb94f4f26527a937a",
      .default = "_UK_LU"
    )

    # Specify the columns we want ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    levels <- c("WD", "PCON", "LAD", "UTLA")
    cols <- c("CD", "NM")
    field_names <- paste(as.vector(outer(paste0(levels, year), cols, paste0)), collapse = ",")

    # Main API call ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (year == 21) {
      # 2021 was only published as an excel file
      # Get the URL by right clicking and saving the link on their download button
      download_21_url <-
        "https://www.arcgis.com/sharing/rest/content/items/d097a503aa2c4ad8a86263e1b094b6b2/data"
      local_file <- tempfile(fileext = ".xlsx")
      download.file(download_21_url, destfile = local_file, mode = "wb", quiet = TRUE)
      return(as.data.frame(readxl::read_excel(path = local_file)))
    } else {
      fetch_ons_api_data(
        data_id = paste0("WD", year, "_PCON", year, "_LAD", year, "_UTLA", year, id_end),
        query_params = list(
          where = "1=1", outFields = field_names,
          outSR = "4326", f = "json"
        )
      )
    }
  }
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  # Pull in the different years
  year_24 <- get_wd_pcon_lad_la(24)
  year_23 <- get_wd_pcon_lad_la(23)
  year_22 <- get_wd_pcon_lad_la(22)
  year_21 <- get_wd_pcon_lad_la(21)
  year_20 <- get_wd_pcon_lad_la(20)
  year_19 <- get_wd_pcon_lad_la(19)
  # Nothing published for 2018
  year_17 <- get_wd_pcon_lad_la(17)
  # Nothing published on pre-2017 boundaries
}



# Create wd_pcon_lad_la_reg_ctry ==============================================





usethis::use_data(ons_wd_pcon_lad_la_reg_ctry, overwrite = TRUE)
