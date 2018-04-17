# dfeR  [![Build Status](https://travis-ci.org/dfe-analytical-services/dfeR.svg?branch=master)](https://travis-ci.org/dfe-analytical-services/dfeR)

dfeR is an R package designed to help standardised R programming accross the Department for Education and facilitate sharing of business specific functions.

Current functionality is focussed around the following:

1. Templates for analytical projects

2. Working with Microsoft SQL Datbabases

3. DfE specific formatting

## Installation

dfeR is not currently available on CRAN. You can instead install the
development version from github with:

``` r
# install.packages("devtools")
devtools::install_github("dfe-analytical-services/dfeR")
```
## Proxy

When installing dfeR on your work laptop you will need to use the following code set the proxy before installation:

``` r
library(httr)
library(XML)

set_config(use_proxy(url = "http://ad\\yourusername:yourwindowspassword@192.168.2.40:8080", port = 8080))
```

**Note:** You must substiture the *yourusername* and *yourwindowspassword* with your own details.
