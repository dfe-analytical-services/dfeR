
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dfeR <a href="https://dfe-analytical-services.github.io/dfeR/"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml)
[![Codecov test
coverage](https://codecov.io/gh/dfe-analytical-services/dfeR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/dfe-analytical-services/dfeR?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of dfeR is to help standardise R programming across the
Department for Education (DfE), and facilitate sharing of business
specific functions, making our code easier to read and write.

Credit to [lauraselby](https://github.com/lauraselby) for the logo
featuring Frederick!

## Scope

This package is open to all of DfE and anything we think could be useful
to other programmers and analysts can be contributed.

Functionality for dfeR is expected to focus around the following:

1.  DfE specific formatting and helper functions
2.  Working with DfE databases
3.  Templates for analytical projects
4.  API wrappers commonly needed in DfE analysis (where they don’t have
    their own separate package)
5.  Geography lookup files and helper functions

Documentation for what has been included in the package so far is on our
[pkgdown site](https://dfe-analytical-services.github.io/dfeR/).

### Relevant other packages

We also maintain the
[dfeshiny](https://github.com/dfe-analytical-services/dfeshiny) package,
and expect any functions specific to R Shiny applications will live
there.

For connecting to data in the [explore education
statistics](https://explore-education-statistics.service.gov.uk/), we
are building the
[eesyapi](https://github.com/dfe-analytical-services/eesyapi) package.

There is a [giasr](https://github.com/dfe-analytical-services/giasr)
package, which has been developed for connecting to data in the [get
information about schools
service](https://get-information-schools.service.gov.uk/).

While we have some DfE specific data in the dfeR package taken from the
[Open Geography Portal](https://geoportal.statistics.gov.uk/). If you’re
looking at getting new data from the portal it is also worth looking at
the [boundr](https://github.com/francisbarton/boundr) package, as this
gives more functions for directly extracting data from there.

------------------------------------------------------------------------

## Installation

dfeR is available on CRAN and you can install directly from there:

``` r
install.packages("dfeR")
```

You can install the development version from GitHub.

If you are using
[renv](https://rstudio.github.io/renv/articles/renv.html) in your
project (recommended):

``` r
renv::install("dfe-analytical-services/dfeR")
```

Otherwise:

``` r
# install.packages("devtools")
devtools::install_github("dfe-analytical-services/dfeR")
```

------------------------------------------------------------------------

## Proxy

The need for setting proxy settings in order to be able to work with R
and Git within the DfE estate has now ended. If you previously run the
proxy script in previous versions of the dfeR package, then contact the
[Statistics Development
Team](mailto:statistics.development@education.gov.uk) to assist in
cleaning out your system settings.

------------------------------------------------------------------------

## Contributing

Ideas for dfeR should first be raised as a [GitHub
issue](https://github.com/dfe-analytical-services/dfeR) after which
anyone is free to write the code and create a pull request for review.

For more details on contributing to dfeR, see our [contributing
guidelines](https://dfe-analytical-services.github.io/dfeR/CONTRIBUTING.html).

------------------------------------------------------------------------

## Code of Conduct

Please note that the dfeR project is released with a [Contributor Code
of
Conduct](https://dfe-analytical-services.github.io/dfeR/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

------------------------------------------------------------------------

## Examples

Here are some example functions from within the package:

``` r
library(dfeR)

# Prettify large numbers
pretty_num(111111111, gbp = TRUE)
#> [1] "£111 million"
pretty_num(-11^8, dp = -1)
#> [1] "-210 million"

# Convert bytes to readable size
pretty_filesize(77777777)
#> [1] "77.78 MB"

# Calculate elapsed time and present prettily
start <- Sys.time()
end <- Sys.time() + 789890
pretty_time_taken(start, end)
#> [1] "219 hours 24 minutes 50 seconds"

# Round 5's up instead of bankers round used by round() in base R
round_five_up(2.5)
#> [1] 3
round(2.5) # base R
#> [1] 2

# Custom formatting for academic and financial years
format_ay(202425)
#> [1] "2024/25"
format_fy(202425)
#> [1] "2024-25"
format_ay_reverse("2024/25")
#> [1] "202425"
format_fy_reverse("2024-25")
#> [1] "202425"

# Get Ward to PCon to LAD to LA to Rgn to Ctry lookup file
my_data <- dfeR::wd_pcon_lad_la_rgn_ctry
head(my_data) # show first 5 rows in console
#>   first_available_year_included most_recent_year_included
#> 1                          2017                      2017
#> 2                          2017                      2017
#> 3                          2017                      2020
#> 4                          2017                      2017
#> 5                          2017                      2020
#> 6                          2017                      2017
#>                ward_name  pcon_name              lad_name               la_name
#> 1               Bastwell  Blackburn Blackburn with Darwen Blackburn with Darwen
#> 2                Ormesby     Redcar  Redcar and Cleveland  Redcar and Cleveland
#> 3            Burn Valley Hartlepool            Hartlepool            Hartlepool
#> 4 Beardwood with Lammack  Blackburn Blackburn with Darwen Blackburn with Darwen
#> 5               De Bruce Hartlepool            Hartlepool            Hartlepool
#> 6           St Germain's     Redcar  Redcar and Cleveland  Redcar and Cleveland
#>   region_name country_name ward_code pcon_code  lad_code new_la_code
#> 1  North West      England E05001621 E14000570 E06000008   E06000008
#> 2  North East      England E05001518 E14000891 E06000003   E06000003
#> 3  North East      England E05008942 E14000733 E06000001   E06000001
#> 4  North West      England E05001622 E14000570 E06000008   E06000008
#> 5  North East      England E05008943 E14000733 E06000001   E06000001
#> 6  North East      England E05001519 E14000891 E06000003   E06000003
#>   region_code country_code
#> 1   E12000002    E92000001
#> 2   E12000001    E92000001
#> 3   E12000001    E92000001
#> 4   E12000002    E92000001
#> 5   E12000001    E92000001
#> 6   E12000001    E92000001

# Get all countries
dfeR::countries
#>    country_code                              country_name
#> 1     E92000001                                   England
#> 2     K02000001                            United Kingdom
#> 3     K03000001                             Great Britain
#> 4     K04000001                         England and Wales
#> 5     N92000002                          Northern Ireland
#> 6     S92000003                                  Scotland
#> 7     W92000004                                     Wales
#> 8             z       England, Wales and Northern Ireland
#> 9             z            Outside of England and unknown
#> 10            z Outside of the United Kingdom and unknown

# Get all PCon names and codes for 2024
fetch_pcons(2024) |>
  head() # show first 5 rows only
#>   pcon_code                pcon_name
#> 1 S14000045               Midlothian
#> 2 S14000027     Na h-Eileanan an Iar
#> 3 S14000021        East Renfrewshire
#> 4 S14000048 North Ayrshire and Arran
#> 5 S14000051      Orkney and Shetland
#> 6 E14001440                   Redcar

# Get All LADs in Scotland in 2017
fetch_lads(2017, "Scotland") |>
  head() # show first 5 rows only
#>    lad_code           lad_name
#> 1 S12000019         Midlothian
#> 2 S12000015               Fife
#> 3 S12000014            Falkirk
#> 4 S12000013 Na h-Eileanan Siar
#> 5 S12000018         Inverclyde
#> 6 S12000011  East Renfrewshire

# Get all LAs in Scotland and Northern Ireland in 2022
fetch_las(2022, c("Scotland", "Northern Ireland")) |>
  head() # show first 5 rows only
#>   new_la_code                              la_name
#> 1   N09000003                              Belfast
#> 2   N09000004             Causeway Coast and Glens
#> 3   N09000002 Armagh City, Banbridge and Craigavon
#> 4   N09000005              Derry City and Strabane
#> 5   N09000001              Antrim and Newtownabbey
#> 6   N09000006                  Fermanagh and Omagh

# Get all Welsh wards for 2021
fetch_wards(2021, "Wales") |>
  head() # show first 5 rows only
#>   ward_code                   ward_name
#> 1 W05000981                      Aethwy
#> 2 W05000982               Bro Aberffraw
#> 3 W05000983                  Bro Rhosyr
#> 4 W05000107 Tregarth & Mynydd Llandygai
#> 5 W05000984                    Caergybi
#> 6 W05000985              Canolbarth Môn

# The following have no specific years available and return all values
fetch_regions()
#>    region_code                               region_name
#> 1    E12000001                                North East
#> 2    E12000002                                North West
#> 3    E12000003                  Yorkshire and The Humber
#> 4    E12000004                             East Midlands
#> 5    E12000005                             West Midlands
#> 6    E12000006                           East of England
#> 7    E12000007                                    London
#> 8    E12000008                                South East
#> 9    E12000009                                South West
#> 10   E13000001                              Inner London
#> 11   E13000002                              Outer London
#> 12           z            Outside of England and unknown
#> 13           z Outside of the United Kingdom and unknown
#> 14           z                        Outside of England
#> 15           z                 Outside of United Kingdom
#> 16           z                                   Unknown

fetch_countries()
#>    country_code                              country_name
#> 1     E92000001                                   England
#> 2     K02000001                            United Kingdom
#> 3     K03000001                             Great Britain
#> 4     K04000001                         England and Wales
#> 5     N92000002                          Northern Ireland
#> 6     S92000003                                  Scotland
#> 7     W92000004                                     Wales
#> 8             z       England, Wales and Northern Ireland
#> 9             z            Outside of England and unknown
#> 10            z Outside of the United Kingdom and unknown
```

For more details on all the functions available in this package, and
examples of how to use them, please see our [dfeR package reference
documentation](https://dfe-analytical-services.github.io/dfeR/reference/index.html).
