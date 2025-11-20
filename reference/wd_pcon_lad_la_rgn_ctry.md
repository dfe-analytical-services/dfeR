# Ward to Constituency to LAD to LA to Region to Country lookup

**\[deprecated\]**

## Usage

``` r
wd_pcon_lad_la_rgn_ctry
```

## Format

### `wd_pcon_lad_la_rgn_ctry`

A data frame with 24,629 rows and 14 columns:

- first_available_year_included:

  First year in the lookups that we see this location

- most_recent_year_included:

  Last year in the lookups that we see this location

- ward_name:

  Ward name

- pcon_name:

  Parliamentary constituency name

- lad_name:

  Local authority district name

- la_name:

  Local authority name

- region_name:

  Region name

- country_code:

  Country name

- ward_code:

  9 digit ward code

- pcon_code:

  9 digit westminster constituency code

- lad_code:

  9 digit local authority district code

- old_la_code:

  old 3 digit local authority code

- new_la_code:

  9 digit local authority code

- region_code:

  9 digit region code

- country_code:

  9 digit country code

## Source

https://geoportal.statistics.gov.uk/search?tags=lup_wd_pcon_lad_utla
https://geoportal.statistics.gov.uk/search?q=lup_wd_lad_cty_rgn_gor_ctry
https://get-information-schools.service.gov.uk/Guidance/LaNameCodes and
https://tinyurl.com/EESScreenerLAs

## Details

`wd_pcon_lad_la_rgn_ctry` has been superseded by `geo_hierarchy` and
will no longer receive any updates. It will be removed in the next major
version.

`geo_hierarchy` contains all the columns in this data set plus more, and
is what we will be maintaining moving forwards.
`wd_pcon_lad_la_rgn_ctry` will be removed in the next major release of
the package.

A lookup showing the hierarchy of ward to Westminster parliamentary
constituency to local authority district to local authority to region to
country for years 2017, 2019, 2020, 2021, 2022, 2023 and 2024.

Changes we've made to the original lookup:

1.  The original lookup from ONS uses the Upper Tier Local Authority, we
    then update this so that where there is a metropolitan local
    authority we use the local authority district as the local authority
    to match how DfE publish data for local authorities.

2.  We have noticed that in the 2017 version, the Glasgow East
    constituency had a code of S1400030 instead of the usual S14000030,
    we've assumed this was an error and have change this in our data so
    that Glasgow East is S14000030 in 2017.

3.  We have joined on regions using the Ward to LAD to County to Region
    file.

4.  We have joined on countries based on the E / N / S / W at the start
    of codes.

5.  Scotland had no published regions in 2017, so given the rest of the
    years have Scotland as the region, we've forced that in for 2017 too
    to complete the data set.
