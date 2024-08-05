# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Created: 05/08/2024, Cam Race
#
# This script creates the wd_pcon_lad_la data set
#
# If updating the data, follow these steps:
# 1. Load the package using `devtools::load_all(".")`
# 2. Add in an extra year for the new year into this script
# 3. Run this script
#
# If you hit any errors or issues with the new year, ONS may have used
# different data set ids, edit the `case_when()` in the `get_wd_pcon_lad_la()`
# function as needed
#
# Files are documented, including source information in the R/ folder
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library(readxl)

#' get_wd_pcon_lad_la
#'
#' Helper function to extract data from the Ward-PCon-LAD-UTLA file
#'
#' @param year last two digits of the year of the lookup, available years are:
#' 2017, 2019, 2020, 2021, 2022, 2023, 2024
#'
#' @return data.frame for the individual year of the lookup
#'
#' @keywords internal
get_wd_pcon_lad_la <- function(year) {
  # Adjusting to the varying ids that ONS have used ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # If there's any issues with these, double check the queries match up
  # Use the ONS query explorer on each file to check this
  # https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
  id_end <- dplyr::case_when(
    year == 23 ~ "_UK_LU_v1",
    year == 20 ~ "_UK_LU_v2_d8cbab26914f4dc1980250dbca6409d4",
    year == 17 ~ "_UK_LU_7d674672d1be40fdb94f4f26527a937a",
    .default = "_UK_LU"
  )

  # Specify the columns we want ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  levels <- c("WD", "PCON", "LAD", "UTLA")
  cols <- c("CD", "NM")
  field_names <- paste(
    as.vector(outer(paste0(levels, year), cols, paste0)),
    collapse = ","
  )

  # Main API call ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (year == 21) {
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
    output <- fetch_ons_api_data(
      data_id = paste0(
        "WD", year, "_PCON", year, "_LAD", year, "_UTLA", year, id_end
      ),
      query_params = list(
        where = "1=1", outFields = field_names,
        outSR = "4326", f = "json"
      )
    )
  }

  # Tidy up the output file (using a helper function)
  return(tidy_raw_lookup(output))
}

# wd_pcon_lad_la --------------------------------------------------------------
# Started publishing in 2017, but didn't publish a 2018 file
wd_pcon_lad_la <- create_time_series_lookup(
  lapply(c(17, 19:24), get_wd_pcon_lad_la)
)

# Write the data into the package
usethis::use_data(wd_pcon_lad_la, overwrite = TRUE)
