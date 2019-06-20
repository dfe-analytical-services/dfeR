# dfeR  [![Build Status](https://travis-ci.org/dfe-analytical-services/dfeR.svg?branch=master)](https://travis-ci.org/dfe-analytical-services/dfeR)

dfeR is an R package designed to help standardised R programming across the Department for Education and facilitate sharing of business specific functions.

Current functionality is focussed around the following:

1. Templates for analytical projects

2. Publication R Markdown Templates

3. Working with Microsoft SQL Databases

4. DfE specific formatting

## Installation

dfeR is not currently available on CRAN. You can instead install the
development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("dfe-analytical-services/dfeR")
```
## Proxy

To install dfeR and more generally access web resources within the Departmental network programatically, you need to set http and https proxy variables. 

The following function set such variables for you to enable this functionality on your machine.

**Note:** The required password is your windows logon password and you will need to restart R and/or your terminal session for the change to take effect.

``` r
source("https://raw.githubusercontent.com/dfe-analytical-services/dfeR/master/R/proxy.R")
setup_proxy()
```
