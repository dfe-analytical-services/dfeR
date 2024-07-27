#' fetch_ons_api_data
#'
#' Helper function that takes a dataset id and parameters to query and parse data from the ONS API
#' TODO: link to documentation
#'
#' @param data_id the id of the dataset to query, can be found from the Open Geography portal
#' @param query_params query parameters to pass into the API
#'
#' @export
#' @return parsed data.frame of geographic names and codes
#'
#' @examples
#' fetch_ons_api_data(
#'   data_id = "LAD23_RGN23_EN_LU",
#'   query_params = list(where = "1=1", outFields = "*", outSR = "4326", f = "json")
#' )
fetch_ons_api_data <- function(data_id, query_params) {
  # Known URL for ONS API
  part_1 <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"

  # Split in two parts so that the data_id can be smushed in the middle
  part_2 <- "/FeatureServer/0/query"

  # Stitch the data_id in and give the query parameters
  response <- httr::POST(paste0(part_1, data_id, part_2), query = query_params)

  # Get the body of the response
  body <- httr::content(response, "text")

  # Parse the JSON
  parsed <- jsonlite::fromJSON(body)

  # Return flattened data.frame
  return(jsonlite::flatten(parsed$features))
}

# TODO: clean this up

# Examples ----
lad_reg <- fetch_ons_api_data(
  data_id = "LAD23_RGN23_EN_LU",
  query_params = list(where = "1=1", outFields = "*", outSR = "4326", f = "json")
)


ward_lad_utla_reg_ctry <- fetch_ons_api_data(
  data_id = "WD23_LAD23_CTY23_OTH_UK_LU",
  query_params = list(
    where = "1=1",
    outFields = "*", # Could do this instead c("WD23CD", "WD23NM", "LAD23CD", "LAD23NM", "CTY23CD", "CTY23NM", "RGN23CD", "RGN23NM", "CTRY23CD", "CTRY23NM")
    outSR = "4326",
    f = "json"
  )
)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE FULL LOOKUP OF WARD-PCON-LAD-LA-REG-CTRY
fetch_full_wd_pcon_lad_la <- function(levels, year) {
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #' get_wd_pcon_lad_la
  #'
  #' Helper function to extract data from the Ward-PCon-LAD-UTLA file
  #'
  #' @param year last two digits of the year of the lookup
  #'
  #' @return data.frame for the individual year of the lookup
  #'
  #' @examples
  #' get_wd_pcon_lad_la("23")
  get_wd_pcon_lad_la <- function(year) {
    year <- 23
    levels <- c("WD", "PCON", "LAD", "UTLA")
    cols <- c("CD", "NM")

    field_names <- paste(as.vector(outer(paste0(levels, year), cols, paste0)), collapse = ",")

    fetch_ons_api_data(
      data_id = paste0("WD", year, "_PCON", year, "_LAD", year, "_UTLA", year, "_UK_LU"),
      query_params = list(where = "1=1", outFields = field_names, outSR = "4326", f = "json")
    )
  }
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



  year_16 <- get_wd_pcon_lad_la(23) # TODO: hitting a token issue with this dataset but not the others, have emailed ONS Geography about it
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

# fetch_wd_pcon_lad_la
# fetch_lsip_lad
