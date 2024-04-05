
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dfeR <a href="http://dfe-analytical-services.github.io/dfeR/"><img src="man/figures/logo.png" align="right" height="138" /></a>

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

1.  DfE specific formatting
2.  Working with Microsoft SQL Databases
3.  Templates for analytical projects
4.  Publication R Markdown Templates
5.  API wrappers for use internally

Documentation for what has been included in the package so far is on our
[pkgdown site](http://dfe-analytical-services.github.io/dfeR/).

We are also developing the
[dfeshiny](https://github.com/dfe-analytical-services/dfeshiny) package,
and expect any functions specific to public facing R Shiny dashboards
will live there.

------------------------------------------------------------------------

## Installation

dfeR is not currently available on CRAN. For the time being you can
install the development version from GitHub.

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
[Statistics Development Team](statistics.development@education.gov.uk)
to assist in cleaning out your system settings.

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

Here are some example formatting functions from within the package:

``` r
library(dfeR)

# Prettify large numbers
pretty_num(111111111, gbp = TRUE)
#> [1] "£111.11 million"
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
```

For more details on all the functions available in this package, and
examples of how to use them, please see our [dfeR package reference
documentation](https://dfe-analytical-services.github.io/dfeR/reference/index.html).
