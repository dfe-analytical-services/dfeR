#' fetch_ons_api_data
#'
#' Helper function that takes a dataset id and parameters to query and parse data from the ONS API
#'
#' On the ONS website, find the dataset you're interested in and then use the query explorer to
#' find the information for the query
#'
#' @param data_id the id of the dataset to query, can be found from the Open Geography portal
#' @param query_params query parameters to pass into the API
#'
#' @export
#' @return parsed data.frame of geographic names and codes
#'
#' @examples
#' if (interactive()) {
#'   fetch_ons_api_data(
#'     data_id = "LAD23_RGN23_EN_LU",
#'     query_params = list(where = "1=1", outFields = "*", outSR = "4326", f = "json")
#'   )
#' }
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



# Functions to create for unique locations by first and last available year
# fetch_countries
# fetch_regions
# fetch_las
# fetch_lads
# fetch_pcons
# fetch_wards
# fetch_leps
# fetch_eda?

# fetch_wd_pcon_lad_la_reg_ctry
# fetch_lsip_lad
