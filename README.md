
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dfeR

<!-- badges: start -->

[![R-CMD-check](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml)
[![Codecov test
coverage](https://codecov.io/gh/dfe-analytical-services/dfeR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/dfe-analytical-services/dfeR?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of dfeR is to help standardise R programming across the
Department for Education (DfE) and facilitate sharing of business
specific functions.

## Scope

This package is open to all of DfE and anything we think could be useful
to other programmers and analysts can be contributed.

Functionality for dfeR is expected to focus around the following:

1.  DfE specific formatting
2.  Working with Microsoft SQL Databases
3.  Templates for analytical projects
4.  Publication R Markdown Templates
5.  API wrappers for use internally

Documentation for what has been included in the package so far is
available at <http://dfe-analytical-services.github.io/dfeR/>.

We are also developing the
[dfeshiny](https://github.com/dfe-analytical-services/dfeshiny) package,
and expect any functions specific to public facing R Shiny dashboards
will live there.

------------------------------------------------------------------------

## Installation

`dfeR` is not currently available on CRAN. For the time being you can
install the development version from GitHub.

If you are using `renv` in your project (recommended):

``` r
renv::install("dfe-analytical-services/dfeR")
```

Otherwise:

``` r
# install.packages("devtools)
devtools::install_github("dfe-analytical-services/dfeR")
```

------------------------------------------------------------------------

## Proxy

The need for setting proxy settings in order to be able to work with R
and Git within the DfE estate has now ended. If you previously run the
proxy script in previous versions of the `dfeR` package, then contact
the [Statistics Development
Team](statistics.development@education.gov.uk) to assist in cleaning out
your system settings.

------------------------------------------------------------------------

## Contributing

Ideas for `dfeR` should first be raised as a [GitHub
issue](https://github.com/dfe-analytical-services/dfeR) after which
anyone is free to write the code and create a pull request for review.

When contributing to dfeR you should work on a new branch and, where
applicable, you will be asked to:

1.  Follow code standards
2.  Write relevant package documentation
3.  Write appropriate tests

Your pull request should then be reviewed and approved by at least one
admin user before it can be merged.

Once your changes have been merged they should appear almost
immediately, though users will need to re-install the package locally to
see them.

### Recommended workflows

Handy keyboard shortcuts for the `devtools` package to use while in
RStudio: - `load_all()` (Ctrl-Shift-L): Load code with dfeR package -
`test()` (Ctrl-Shift-T): Run tests - `document()` (Ctrl-Shift-D):
Rebuild docs and NAMESPACE - `check()` (Ctrl-Shift-E): Check complete
package

We recommend using the [usethis](https://usethis.r-lib.org/index.html)
package where possible for consistency and simplicity.

Add any packages the package users will need with:

``` r
usethis::use_package(pkgname, type = "imports")
```

Add any packages that package developers only may need with:

``` r
usethis::use_package(pkgname, type = "suggests")
```

### Updating the package version

Once changes have been completed, reviewed and are ready for use in the
wild, you can increment the package version using:

``` r
usethis::use_version()
```

Once you’ve incremented the version number, it’ll offer to perform a
commit on your behalf, so all you then need to do is push to GitHub.

------------------------------------------------------------------------

## Code of Conduct

Please note that the dfeR project is released with a [Contributor Code
of
Conduct](https://dfe-analytical-services.github.io/dfeR/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

------------------------------------------------------------------------

## Example

This is a basic example showing the `formatAY()` function:

``` r
library(dfeR)
formatAY(202425)
#> [1] "2024/25"
```
