#' Lookup for ONS geography columns shorthands
#'
#' A lookup of ONS geography shorthands and their respective column names in
#' line with DfE open data standards.
#'
#' GOR (Government Office Region) was the predecessor to RGN.
#'
#' @format ## `ons_geog_shorthands`
#' A data frame with 7 rows and 3 columns:
#' \describe{
#'   \item{ons_level_shorthands}{ONS shorthands used in their lookup files}
#'   \item{name_column}{DfE names for geography name columns}
#'   \item{code_column}{DfE names for geography code columns}
#' }
#' @source curated by explore.statistics@@education.gov.uk
"ons_geog_shorthands"

#' Ward to Constituency to LAD to LA to Region to Country lookup
#'
#' A lookup showing the hierarchy of ward to Westminster parliamentary
#' constituency to local authority district to local authority to region to
#' country for years 2017, 2019, 2020, 2021, 2022, 2023 and 2024.
#'
#' Changes we've made to the original lookup:
#' 1. The original lookup from ONS uses the Upper Tier Local Authority, we then
#' update this so that where there is a metropolitan local authority we use the
#' local authority district as the local authority to match how
#' DfE publish data for local authorities.
#'
#' 2. We have noticed that in the 2017 version, the Glasgow East constituency
#' had a code of S1400030 instead of the usual S14000030, we've assumed this
#' was an error and have change this in our data so that Glasgow East is
#' S14000030 in 2017.
#'
#' 3. We have joined on regions using the Ward to LAD to County to Region file.
#'
#' 4. We have joined on countries based on the E / N / S / W at the start of
#' codes.
#'
#' 5. Scotland had no published regions in 2017, so given the rest of the years
#' have Scotland as the region, we've forced that in for 2017 too to complete
#' the data set.
#'
#' @format ## `wd_pcon_lad_la_rgn_ctry`
#' A data frame with 24,629 rows and 14 columns:
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
#'   \item{region_name}{Region name}
#'   \item{country_code}{Country name}
#'   \item{ward_code}{9 digit ward code}
#'   \item{pcon_code}{9 digit westminster constituency code}
#'   \item{lad_code}{9 digit local authority district code}
#'   \item{new_la_code}{9 digit local authority code}
#'   \item{region_code}{9 digit region code}
#'   \item{country_code}{9 digit country code}
#' }
#' @source https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
#' and https://geoportal.statistics.gov.uk/search?q=lup_wd_lad_cty_rgn_gor_ctry
"wd_pcon_lad_la_rgn_ctry"

#' Lookup for valid country names and codes
#'
#' A lookup of ONS geography country names and codes, as well as some custom
#' DfE names and codes. This is used as the definitive list for the screening
#' of open data before it is published by the DfE.
#'
#' @format ## `countries`
#' A data frame with 10 rows and 2 columns:
#' \describe{
#'   \item{country_name}{Country name}
#'   \item{country_code}{Country code}
#' }
#' @source curated by explore.statistics@@education.gov.uk, ONS codes sourced
#' from
#' https://geoportal.statistics.gov.uk/search?q=countries%20names%20and%20codes
"countries"

#' Lookup for valid region names and codes
#'
#' A lookup of ONS geography region names and codes for England. In their
#' lookups Northern Ireland, Scotland and Wales are regions.
#'
#' Also included inner and outer London county split as DfE frequently publish
#' those as regions, as well as some custom DfE names and codes. This is used
#' as the definitive list for the screening of open data before it is published
#' by the DfE.
#'
#' @format ## `regions`
#' A data frame with 16 rows and 2 columns:
#' \describe{
#'   \item{region_name}{Region name}
#'   \item{region_code}{Region code}
#' }
#' @source curated by explore.statistics@@education.gov.uk, ONS codes sourced
#' from
#' https://geoportal.statistics.gov.uk/search?q=NAC_RGN
"regions"

#' Potential names for geography and time columns
#'
#' Potential names for geography and time columns in line with the ones used for
#' the explore education statistics data screener.
#'
#'
#' @format ## `geog_time_identifiers`
#' A character vector with 38 potential column names in snake case format.
#' @source curated by explore.statistics@@education.gov.uk.
#' \href{https://www.shorturl.at/j4532}{Guidance on time and geography data.}
"geog_time_identifiers"
