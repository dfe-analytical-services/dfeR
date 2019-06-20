# dfeR  [![Build Status](https://travis-ci.org/dfe-analytical-services/dfeR.svg?branch=master)](https://travis-ci.org/dfe-analytical-services/dfeR)

dfeR is an R package designed to help standardised R programming across the Department for Education and facilitate sharing of business specific functions.

Current functionality is focussed around the following:

1. Templates for analytical projects

2. Publication R Markdown Templates

3. Working with Microsoft SQL Databases

4. DfE specific formatting

5. Functions for setting up R for reproducible analysis

## Installation

dfeR is not currently available on CRAN. You can instead install the
development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("dfe-analytical-services/dfeR")
```
## Proxy

To install dfeR and more generally access web resources programmatically (R, Python, Git) within the Departmental network you need to set http and https proxy variables.

The following function will ask you for your password and set such variables for you to enable this functionality. Note: Any session including R Studio will need a restart for the proxy to take effect.

``` r
source("https://raw.githubusercontent.com/dfe-analytical-services/dfeR/master/R/proxy.R")
setup_proxy()
```


**Note:** You must substitute the *yourusername* and *yourwindowspassword* with your own details.
