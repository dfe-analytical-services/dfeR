<!-- badges: start -->
[![R-CMD-check](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/pkgdown.yaml)
[![test-coverage](https://github.com/dfe-analytical-services/dfeR/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/dfe-analytical-services/dfeR/actions/workflows/test-coverage.yaml)
<!-- badges: end -->
  
# dfeR

---

## Introduction

dfeR is an R package designed to help standardise R programming across the Department for Education (DfE) and facilitate sharing of business specific functions.

**Scope**

dfeR is open to all of DfE and anything we think could be useful to other programmers and analysts can be contributed. 

Functionality is expected to focus around the following:

1. Templates for analytical projects
2. Publication R Markdown Templates
3. Working with Microsoft SQL Databases
4. DfE specific formatting

Documentation for what has been included in the package so far is available at http://dfe-analytical-services.github.io/dfeR/ 

---

## Installation

dfeR is not currently available on CRAN. For the time being you can install the development version from GitHub.

If you are using `renv` in your project (recommended):

``` r
renv::install("dfe-analytical-services/dfeR")
```

Otherwise:

``` r
devtools::install_github("dfe-analytical-services/dfeR")
```

---

## Proxy

The need for setting proxy settings in order to be able to work with R and git within the DfE estate has now ended. If you previously run the proxy script in previous versions of the DfE R package, then contact the [Statistics Development team](statistics.development@education.gov.uk) to assist in cleaning out your system settings.

---

## Contributing

Ideas for dfeR should first be raised as a [GitHub issue](https://github.com/dfe-analytical-services/dfeR) after which anyone is free to write the code and create a pull request for review. 

When contributing to dfeR you should work on a new branch and, where applicable, you will be asked to: 

1. Follow code standards
2. Write relevant package documentation
3. Write appropriate tests 

Your pull request should then be reviewed and approved by at least one admin user before it can be merged. 

Once your changes have been merged they should appear almost immediately, though users will need to re-install the package locally to see them. 

---

## Code of Conduct

Please note that the dfeR project is released with a [Contributor Code of Conduct](https://dfe-analytical-services.github.io/dfeR/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

