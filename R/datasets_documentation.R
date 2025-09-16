#' Lookup for ONS geography columns shorthands
#'
#' A lookup of ONS geography shorthands and their respective column names in
#' line with DfE open data standards.
#'
#' GOR (Government Office Region) was the predecessor to RGN.
#'
#' @format ## `ons_geog_shorthands`
#' A data frame with 8 rows and 3 columns:
#' \describe{
#'   \item{ons_level_shorthands}{ONS shorthands used in their lookup files}
#'   \item{name_column}{DfE names for geography name columns}
#'   \item{code_column}{DfE names for geography code columns}
#' }
#' @source curated by explore.statistics@@education.gov.uk
"ons_geog_shorthands"

#' Geography hierarchy lookup
#'
#' A lookup showing the hierarchy of ward to Westminster parliamentary
#' constituency to local authority district to local authority to
#' combined mayoral authority to region to
#' country for years 2017, 2019, 2020, 2021, 2022, 2023, 2024 and 2025.
#'
#' Note that combined mayoral authorities only exist in England, and we use
#' `cauth_name` and `cauth_code` to refer to the relevant columns following
#' ONS conventions. If you are publishing using explore education statistics,
#' these are combined with other bodies into `english_devolved_area_name`
#' and `english_devolved_area_code`.
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
#' @format ## `geo_hierarchy`
#' A data frame with 25,678 rows and 17 columns:
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
#'   \item{cauth_name}{Combined authority name, where applicable}
#'   \item{region_name}{Region name}
#'   \item{country_code}{Country name}
#'   \item{ward_code}{9 digit ward code}
#'   \item{pcon_code}{9 digit westminster constituency code}
#'   \item{lad_code}{9 digit local authority district code}
#'   \item{old_la_code}{old 3 digit local authority code}
#'   \item{new_la_code}{9 digit local authority code}
#'   \item{cauth_code}{9 digit combined authority code, where applicable}
#'   \item{region_code}{9 digit region code}
#'   \item{country_code}{9 digit country code}
#' }
#' @source https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
#' https://geoportal.statistics.gov.uk/search?q=lup_wd_lad_cty_rgn_gor_ctry
#' https://geoportal.statistics.gov.uk/search?tags=LUP_LAD_CAUTH
#' https://get-information-schools.service.gov.uk/Guidance/LaNameCodes and
#' https://tinyurl.com/EESScreenerLAs
"geo_hierarchy"

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

#' Ward to Constituency to LAD to LA to Region to Country lookup
#'
#' `r lifecycle::badge("deprecated")`
#' 
#' `wd_pcon_lad_la_rgn_ctry` has been superseded by `geo_hierarchy`.
#'  
#' `geo_hierarchy` contains all the columns in this data set plus more, and is
#' what we will be maintaining moving forwards. `wd_pcon_lad_la_rgn_ctry` will
#' be removed in the next major release of the package.
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
#'   \item{old_la_code}{old 3 digit local authority code}
#'   \item{new_la_code}{9 digit local authority code}
#'   \item{region_code}{9 digit region code}
#'   \item{country_code}{9 digit country code}
#' }
#' @source https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
#' https://geoportal.statistics.gov.uk/search?q=lup_wd_lad_cty_rgn_gor_ctry
#' https://get-information-schools.service.gov.uk/Guidance/LaNameCodes and
#' https://tinyurl.com/EESScreenerLAs
"wd_pcon_lad_la_rgn_ctry"