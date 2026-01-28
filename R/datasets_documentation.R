#' Lookup for ONS geography columns shorthands
#'
#' A lookup of ONS geography shorthands and their respective column names in
#' line with DfE open data standards.
#'
#' GOR (Government Office Region) was the predecessor to RGN.
#'
#' @format ## `ons_geog_shorthands`
#' A data frame with 9 rows and 3 columns:
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
#' `english_devolved_area_name` and `english_devolved_area_code` to refer
#' to mayoral authorities in line with the standards set in DfE official
#' statistics. Greater London Authority is not included in the ONS combined
#' authority lookup, we have added that in for all local authority districts
#' with codes that start with `E090...`.
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
#' 6. We've added the Greater London Authority as the overarching mayoral
#' authority (English devolved area) for all Local authority districts with
#' codes that start `E090...`.
#'
#' @format ## `geo_hierarchy`
#' A data frame with 26,057 rows and 17 columns:
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
#'   \item{english_devolved_area_name}{Mayoral authority name}
#'   \item{region_name}{Region name}
#'   \item{country_code}{Country name}
#'   \item{ward_code}{9 digit ward code}
#'   \item{pcon_code}{9 digit westminster constituency code}
#'   \item{lad_code}{9 digit local authority district code}
#'   \item{old_la_code}{old 3 digit local authority code}
#'   \item{new_la_code}{9 digit local authority code}
#'   \item{english_devolved_area_code}{9 digit combined authority code}
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
#' `wd_pcon_lad_la_rgn_ctry` has been superseded by `geo_hierarchy` and will no
#' longer receive any updates. It will be removed in the next major version.
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

#' Benchmarking Results for write_df_to_delta
#'
#' A named list containing microbenchmark results comparing `DBI::dbWriteTable`
#' and `dfeR::write_df_to_delta` across five data scales (100 to 1 million
#' rows).
#'
#' @details
#' The benchmarks were conducted using the \strong{DfE High Memory Desktop
#' (AVD)} to establish a performance baseline for large-scale data ingestion.
#'
#' \strong{Environment Specs:}
#' \itemize{
#'   \item \strong{Machine}: DfE High Memory Desktop (AVD)
#'   \item \strong{CPU}: AMD EPYC 7763 64-Core Processor (16 cores allocated)
#'   \item \strong{RAM}: 137 GB
#' }
#'
#' \strong{Test Data Schema:}
#' The benchmarks used a synthetic dataset with the following schema:
#' \itemize{
#'   \item \strong{int}: Random integers (1 to 10,000)
#'   \item \strong{numeric}: Standard normal distribution (\code{rnorm})
#'   \item \strong{character}: US State abbreviations
#'   \item \strong{factor}: Categorical levels ("High", "Medium", "Low")
#'   \item \strong{logical}: Booleans including \code{NA} values
#'   \item \strong{date}: Sequential dates starting from 2020-01-01
#'   \item \strong{time}: UTC timestamps starting from 2025-01-01 00:00:00
#' }
#'
#' @format A named list of 5 \code{microbenchmark} objects:
#' \describe{
#'   \item{100, 1000, 10000, 1e+05, 1e+06}{The names represent the row count
#'   (\code{n}) of the test data.}
#'   \item{Each object contains}{10 evaluations of both the DBI and dfeR
#'   methods.}
#' }
#' @source curated by explore.statistics@@education.gov.uk
"write_df_to_delta_benchmarks"

#' Stress Test Results for write_df_to_delta
#'
#' A list of microbenchmark results for extreme scales, ranging from
#' 100 to 1 billion rows.
#'
#' @details
#' The stress tests were conducted using the \strong{DfE High Memory
#' Desktop (AVD)}.
#'
#' \strong{Environment Specs:}
#' \itemize{
#'   \item \strong{Machine}: DfE High Memory Desktop (AVD)
#'   \item \strong{CPU}: AMD EPYC 7763 64-Core Processor (16 cores allocated)
#'   \item \strong{RAM}: 137 GB
#' }
#'
#' \strong{Test Data Schema:}
#' The benchmarks used a synthetic dataset with the following schema:
#' \itemize{
#'   \item \strong{int}: Random integers (1 to 10,000)
#'   \item \strong{numeric}: Standard normal distribution (\code{rnorm})
#'   \item \strong{character}: US State abbreviations
#'   \item \strong{factor}: Categorical levels ("High", "Medium", "Low")
#'   \item \strong{logical}: Booleans including \code{NA} values
#'   \item \strong{date}: Sequential dates starting from 2020-01-01
#'   \item \strong{time}: UTC timestamps starting from 2025-01-01 00:00:00
#' }
#'
#' @format A named list of 8 \code{microbenchmark} objects:
#' \describe{
#'   \item{100, 1000, 10000, 1e+05, 1e+06, 1e+07, 1e+08, 1e+09}{The names
#'   represent the row count (\code{n}) of the test data.}
#'   \item{Each object contains}{5 evaluations of `write_df_to_delta`.}
#' }
#' @source curated by explore.statistics@@education.gov.uk
"write_df_to_delta_stress_test"
