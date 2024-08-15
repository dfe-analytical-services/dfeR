#' Lookup for ONS geography columns shorthands
#'
#' A lookup of ONS geography shorthands and their respective column names in
#' line with DfE open data standards
#'
#' @format ## `ons_geog_shorthands`
#' A data frame with 4 rows and 3 columns:
#' \describe{
#'   \item{ons_level_shorthands}{ONS shorthands used in their lookup files}
#'   \item{name_column}{DfE names for geography name columns}
#'   \item{code_column}{DfE names for geography code columns}
#' }
#' @source curated by explore.statistics@@education.gov.uk
"ons_geog_shorthands"

#' Ward to Constituency to LAD to LA lookup
#'
#' A lookup showing the hierarchy of ward to Westminster parliamentary
#' constituency to local authority district to local authority for years
#' 2017, 2019, 2020, 2021, 2022, 2023 and 2024
#'
#' Changes we've made to the lookup:
#' 1. The original lookup from ONS uses the Upper Tier Local Authority, we then
#' update this so that where there is a metropolitan local authority we use the
#' local authority district we use that as the local authority to match how
#' DfE use local authorities.
#'
#' 2. We have noticed that in the 2017 version, the Glasgow East constituency
#' had a code of S1400030 instead of the usual S14000030, we've assumed this
#' was an error and have change this in our data so that Glasgow East is
#' S14000030 in 2017.
#'
#' @format ## `wd_pcon_lad_la`
#' A data frame with 24,629 rows and 10 columns:
#' \describe{
#'   \item{first_available_year_included}{
#'   First year in the lookups that we see this location
#'   }
#'   \item{most_recent_year_included}{
#'   Last year in the lookups that we see this location
#'   }
#'   \item{ward_name}{Ward name}
#'   \item{pcon_name}{Parliamentary constituency name}
#'   \item{lad_name}{Local authority district name}
#'   \item{la_name}{Local authority name}
#'   \item{ward_code}{9 digit ward code}
#'   \item{pcon_code}{9 digit westminster constituency code}
#'   \item{lad_code}{9 digit local authority district code}
#'   \item{new_la_code}{9 digit local authority code}
#' }
#' @source https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
"wd_pcon_lad_la"
