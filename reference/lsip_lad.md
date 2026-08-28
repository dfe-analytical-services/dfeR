# Local Skills Improvement Plan (LSIP) areas to Local Authority District (LAD) Lookup

A lookup table mapping Local Skills Improvement Plan (LSIP) areas to
Local Authority Districts (LADs) in England. This dataset provides a
mapping between LSIP areas and LADs as provided by the ONS Geography
Portal.

## Usage

``` r
lsip_lad
```

## Format

### `lsip_lad`

A data frame with one row per LAD to LSIP pairing per lookup, currently
466 rows covering 298 LADs and 51 LSIP codes. As codes are reused for
renamed areas, those 51 codes give 56 distinct code and name pairings,
which is what
[`fetch_lsips()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_lsips.md)
returns. The columns are:

- lsip_code:

  9-character code for the LSIP area

- lsip_name:

  Name of the Local Skills Improvement Plan (LSIP) area

- lad_code:

  9-character code for the Local Authority District

- lad_name:

  Name of the Local Authority District

- most_recent_year_included:

  The most recent year in which this location appears in the lookup

- first_available_year_included:

  The first year in which this location appears in the lookup

## Source

https://geoportal.statistics.gov.uk/search?q=lad%20lsip

## Details

- Within a given year, each LAD is assigned to a single LSIP area. The
  LSIP a LAD belongs to can change between lookups though, so across the
  data set as a whole a LAD may appear against more than one LSIP area.

- Mappings may change over time and can be tracked using the
  `most_recent_year_included` and `first_available_year_included`
  columns.

- LSIP codes are not stable over time. A code can be kept but the area
  renamed (E69000001 was 'Brighton and Hove, East Sussex, West Sussex'
  in 2023 and 'Sussex and Brighton' in 2025), and a name can be kept but
  the code changed ('North East' was E69000023 in 2023 and E69000045 in
  2025). Joining on `lsip_code` alone across years will silently
  mismatch, so use `lsip_code` and `lsip_name` together to identify an
  area within a lookup.

- ONS have published LSIP lookups for 2023 and 2025 only, there was no
  2024 lookup.
