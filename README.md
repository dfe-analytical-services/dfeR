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

The need for setting proxy settings in order to be able to work with R and git within the DfE estate has now ended. If you previously run the proxy script in previous versions of the DfE R package, then contact the [Statistics Development team](statistics.development@education.gov.uk) to assist in cleaning out your system settings.

## Contributing

Ideas for dfeR should first be raised as a [github issue](https://github.com/dfe-analytical-services/dfeR) after which anyone is free to write the code and create a pull request for review. 

When contributing to dfeR you should work on a new branch and, where applicable, you will be asked to: 

1. Follow code standards 
2. Write relevant package documentation
3. Write appropriate tests 

Your pull request should then be reviewed and approved by at least one other person before it can be merged. 

Once your changes have been merged they should appear almost immediately, though users will need to reinstall the package locally to see them. 
