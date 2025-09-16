
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dfeR <a href="https://dfe-analytical-services.github.io/dfeR/"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml)
[![Codecov test
coverage](https://codecov.io/gh/dfe-analytical-services/dfeR/graph/badge.svg)](https://app.codecov.io/gh/dfe-analytical-services/dfeR)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![](https://cranlogs.r-pkg.org/badges/dfeR)](https://cran.r-project.org/package=dfeR)
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
[eesyapi](https://github.com/dfe-analytical-services/eesyapi.R) package.

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
#> Note: The dataset `wd_pcon_lad_la_rgn_ctry` is deprecated and will be removed in the next major release. Use `geo_hierarchy` instead.

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

# Get hierachical lookup file for common geographies
my_data <- dfeR::geo_hierarchy
head(my_data) # show first 5 rows in console
#>   first_available_year_included most_recent_year_included ward_name
#> 1                          2017                      2021     Abbey
#> 2                          2022                      2023     Abbey
#> 3                          2024                      2025     Abbey
#> 4                          2017                      2017     Abbey
#> 5                          2024                      2025     Abbey
#> 6                          2017                      2023     Abbey
#>       pcon_name                     lad_name                      la_name
#> 1       Barking         Barking and Dagenham         Barking and Dagenham
#> 2       Barking         Barking and Dagenham         Barking and Dagenham
#> 3       Barking         Barking and Dagenham         Barking and Dagenham
#> 4          Bath Bath and North East Somerset Bath and North East Somerset
#> 5 Belfast North      Antrim and Newtownabbey      Antrim and Newtownabbey
#> 6 Belfast North      Antrim and Newtownabbey      Antrim and Newtownabbey
#>        cauth_name      region_name     country_name ward_code pcon_code
#> 1  Not applicable           London          England E05000026 E14000540
#> 2  Not applicable           London          England E05014053 E14000540
#> 3  Not applicable           London          England E05014053 E14001073
#> 4 West of England       South West          England E05001935 E14000547
#> 5  Not applicable Northern Ireland Northern Ireland N08000101 N05000002
#> 6  Not applicable Northern Ireland Northern Ireland N08000101 N06000002
#>    lad_code old_la_code new_la_code cauth_code region_code country_code
#> 1 E09000002         301   E09000002          z   E12000007    E92000001
#> 2 E09000002         301   E09000002          z   E12000007    E92000001
#> 3 E09000002         301   E09000002          z   E12000007    E92000001
#> 4 E06000022         800   E06000022  E47000009   E12000009    E92000001
#> 5 N09000001           z   N09000001          z   N92000002    N92000002
#> 6 N09000001           z   N09000001          z   N92000002    N92000002

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
#> # A tibble: 6 × 2
#>   pcon_code pcon_name            
#>   <chr>     <chr>                
#> 1 E14001073 Barking              
#> 2 N05000002 Belfast North        
#> 3 E14001149 Cambridge            
#> 4 E14001193 Derby North          
#> 5 E14001194 Derby South          
#> 6 S14000073 Dumfries and Galloway

# Get All LADs in Scotland in 2017
fetch_lads(2017, "Scotland") |>
  head() # show first 5 rows only
#> # A tibble: 6 × 2
#>   lad_code  lad_name             
#>   <chr>     <chr>                
#> 1 S12000006 Dumfries and Galloway
#> 2 S12000034 Aberdeenshire        
#> 3 S12000017 Highland             
#> 4 S12000044 North Lanarkshire    
#> 5 S12000033 Aberdeen City        
#> 6 S12000036 City of Edinburgh

# Get all LAs in Scotland and Northern Ireland in 2022
fetch_las(2022, c("Scotland", "Northern Ireland")) |>
  head() # show first 5 rows only
#> # A tibble: 6 × 3
#>   new_la_code la_name                  old_la_code
#>   <chr>       <chr>                    <chr>      
#> 1 N09000001   Antrim and Newtownabbey  z          
#> 2 S12000006   Dumfries and Galloway    z          
#> 3 N09000010   Newry, Mourne and Down   z          
#> 4 S12000034   Aberdeenshire            z          
#> 5 N09000008   Mid and East Antrim      z          
#> 6 N09000004   Causeway Coast and Glens z

# Get all Welsh wards for 2021
fetch_wards(2021, "Wales") |>
  head() # show first 5 rows only
#> # A tibble: 6 × 2
#>   ward_code ward_name     
#>   <chr>     <chr>         
#> 1 W05000720 Aber Valley   
#> 2 W05000284 Aber-craf     
#> 3 W05000357 Aberaeron     
#> 4 W05000655 Aberaman North
#> 5 W05001017 Aberaman South
#> 6 W05000551 Aberavon

# Get all combined mayoral authorities for 2025
fetch_mayoral(2025) |>
  head() # show first 5 rows only
#> # A tibble: 6 × 2
#>   cauth_code cauth_name                     
#>   <chr>      <chr>                          
#> 1 E47000009  West of England                
#> 2 E47000008  Cambridgeshire and Peterborough
#> 3 E47000013  East Midlands                  
#> 4 E47000017  Greater Lincolnshire           
#> 5 E47000007  West Midlands                  
#> 6 E47000001  Greater Manchester

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
