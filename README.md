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

When installing dfeR on your work laptop you will need to use the following code set the proxy before installation:

``` r
library(rstudioapi)
yourusername <- rstudioapi::showPrompt(title = "Username", message = "Username", default = "")
Sys.setenv(https_proxy = paste("http://ad\\",yourusername,":",
                               rstudioapi::askForPassword("AD account password"),
                               "@192.168.2.40:8080",sep=""))
```
