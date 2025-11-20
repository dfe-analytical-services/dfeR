# Lookup for valid region names and codes

A lookup of ONS geography region names and codes for England. In their
lookups Northern Ireland, Scotland and Wales are regions.

## Usage

``` r
regions
```

## Format

### `regions`

A data frame with 16 rows and 2 columns:

- region_name:

  Region name

- region_code:

  Region code

## Source

curated by explore.statistics@education.gov.uk, ONS codes sourced from
https://geoportal.statistics.gov.uk/search?q=NAC_RGN

## Details

Also included inner and outer London county split as DfE frequently
publish those as regions, as well as some custom DfE names and codes.
This is used as the definitive list for the screening of open data
before it is published by the DfE.
