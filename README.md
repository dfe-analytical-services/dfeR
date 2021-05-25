# dfeR  [![Build Status](https://travis-ci.org/dfe-analytical-services/dfeR.svg?branch=master)](https://travis-ci.org/dfe-analytical-services/dfeR)


<h1 align="center">
  <br>
  dfeR 
  <br>
</h1>

<p align="center">
  <a href="#introduction">Introduction</a> |
  <a href="#requirements">Installation</a> |
  <a href="#how-to-use">Contributing</a> 
</p>

---

## Introduction

dfeR is an R package designed to help standardise R programming across the Department for Education (DfE) and facilitate sharing of business specific functions.

**Scope**

dfeR is open to all of DfE and anything we think could be useful to other programmers / analysts can be contributed. 

Functionality is expected to focus around the following:

1. Templates for analytical projects
2. Publication R Markdown Templates
3. Working with Microsoft SQL Databases
4. DfE specific formatting

Documentation for what has been included in the package so far is available at http://dfe-analytical-services.github.io/dfeR/ 

---

## Installation

dfeR is not currently available on CRAN. You can instead install the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("dfe-analytical-services/dfeR")
```

### Proxy

To install dfeR and more generally access web resources within the Departmental network programatically, you need to set http and https proxy variables.

The following function set such variables for you to enable this functionality on your machine.


**Notes** 

1. This code will need to be re-run whenever you change your windows password.
2. You will need to restart R and/or your terminal session for the change to take effect. 
3. When using APIs to Java, such as RSelenium, the proxy will need to be disabled using `Sys.setenv(no_proxy = "*")`.
4. If setup_proxy fails due to not having rstudioapi installed then simply install it with `install.packages("rstudioapi")` and re-run `setup_proxy()`.
5. This also sets pypi.python.org as a trusted host so that python and pip should work out of the box outside of R.

``` r
source("https://raw.githubusercontent.com/dfe-analytical-services/dfeR/master/R/proxy.R")
setup_proxy()
```

---

## Contributing

Ideas for dfeR should first be raised as a [github issue](https://github.com/dfe-analytical-services/dfeR) after which anyone is free to write the code and create a pull request for review. 

When contributing to dfeR you should work on a new branch and, where applicable, you will be asked to: 

1. Follow code standards - [consistency across functions, can we nick from existing guidance? Function names and arguments follow similar format. Standardising where we can.] 
2. Write relevant package documentation
3. Write appropriate tests [(detail on what we expect for testing and what we test automatically) - link off to other guidance]

Your pull request should then be reviewed and approved by at least one other person before it can be merged. 

Once your changes have been merged they should appear almost immediately, though users will need to reinstall the package locally to see them. 
