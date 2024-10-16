# Contributing to dfeR

Ideas for dfeR should first be raised as a [GitHub issue](https://github.com/dfe-analytical-services/dfeR/issues) after which anyone is free to write the code and create a pull request for review. 

For a detailed discussion on contributing to R packages in the tidyverse, please see the [development contributing guide](https://rstd.io/tidy-contrib) and their [code review principles](https://code-review.tidyverse.org/). Full knowledge of this isn't needed, though some awareness of general principles may be useful.

## Support

We're keen for anyone at DfE to be able to feel comfortable contributing to this package. If you have any questions, or would like support in making changes, let the [Statistics Development Team](mailto:statistics.development@education.gov.uk) know.

## Basics

When contributing to dfeR you should work on a new branch taken from main.

Any pull request must be reviewed and approved by at least one admin user before it can be merged. 

- If you’ve found a bug, please file an issue that illustrates the bug with a minimal 
[reprex example](https://www.tidyverse.org/help/#reprex) (this will also help you write a unit test, if needed).

- See the tidyverse guide on [how to create a great issue](https://code-review.tidyverse.org/issues/) for more advice.

### Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file. 

This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. 
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

### Bigger changes

If you want to make a bigger change, it's a good idea to first [file an issue](https://github.com/dfe-analytical-services/dfeR/issues) and make sure someone from the team agrees with the change.

Packages worth installing to aid development are:

``` r
install.packages("devtools")
install.packages("usethis")
install.packages("pkgdown")
install.packages("roxygen2")
install.packages("spelling")
install.packages("lintr")
install.packages("styler")
```

Where possible, we'd recommend following the [Test Driven Development (TDD)](https://testdriven.io/test-driven-development/) approach. Though if you're new to package development, or already have code for a specific function feel free to start with step 2, to copy the function into the package and then go back to step 1 afterwards. 

1. Write tests using [testthat](https://r-pkgs.org/testing-basics.html) for the behaviour you want. Either edit an existing test script, or if adding a new function, create a test script using:

``` r
usethis::use_test("name_of_new_function")
```
Feel free to have a look in the /tests/test_that folder for some examples if you want to see example tests in practice.


2. Write just enough code so that the tests pass. Again, either edit an existing function, or add a new R script using:

``` r
usethis::use_r("name_of_new_function")
```

3. Add documentation for what you've done. Follow the [roxygen2](https://roxygen2.r-lib.org/articles/rd.html) pattern for comments. You can add a standard skeleton using `Code > Insert Roxygen Skeleton` or by `Ctrl+Shift+Alt+R` when in your R script. Here's an example of what it looks like for a basic `add()` function:

```
#' @description Add together two numbers
#'
#' @param x A number.
#' @param y A number.
#' @return A number.
#' @examples
#' add(1, 1)
#' add(10, 1)
add <- function(x, y) {
  x + y
}
```

4. Continue to improve code while keeping tests passing. 

5. Automatically style code using:

``` r
styler::style_pkg()
```

5. Run a full check of the package using the following functions:

``` r
devtools::check() # General package check, can also use Ctrl-Shift-E
lintr::lint_package() # Check formatting of code
spelling::spell_check() # Check for spelling mistakes
```

## Handy workflows

Keyboard shortcuts for the `devtools` package to use while in RStudio:

``` r
load_all() # (Ctrl-Shift-L): Load code with dfeR package
test() # (Ctrl-Shift-T): Run tests
document() # (Ctrl-Shift-D): Rebuild docs and NAMESPACE
check() # (Ctrl-Shift-E): Check complete package
```

We recommend using the [usethis](https://usethis.r-lib.org/index.html) package where possible for consistency and simplicity.

## Adding package dependencies

Add any packages the package users will need with:
``` r
usethis::use_package(pkgname)
```

Add any packages that package developers only may need with:
``` r
usethis::use_package(pkgname, type = "suggests")
```

## Updating the README

There are two README files that are linked with a pre-commit-hook to ensure they are kept in sync.

Make all changes to the `README.Rmd` file and then run the following line to rebuild:

``` r
devtools::build_readme()
```

## pkgdown site

Most of the `pkgdown` site is automatically generated. The theme is set in the `_pkgdown.yml` file. 

Custom CSS can be set in `pkgdown/extra.css` file. If you make any edits to this file you will need to re-initialise the site using the following line:

``` r
pkgdown::init_site()
```

The site is hosted on GitHub pages. You build and preview the pkgdown site locally by running:

```r
devtools::build_site()
```

## Updating the package version

Once changes have been completed, reviewed and are ready for use in the wild, you can increment the package version using:

``` r
usethis::use_version()
```

If you are unsure what kind of version to increment, have a look through [lifecycle's guidance on release types](https://r-pkgs.org/lifecycle.html#sec-lifecycle-release-type).

Once you've incremented the version number, it'll offer to perform a commit on your behalf. As this happens it will add an update to `NEWS.md`, which acts as the changelog for the package. Make sure this is updated correctly and then push to GitHub.

Once the version has been updated and pushed, create a new GitHub release version.

### Lifecyles

The package has [lifecycle](https://r-pkgs.org/lifecycle.html) imported, follow their guidance for the process around deprecating any functions or arguments.

## Code style

New code should follow the tidyverse [style guide](https://style.tidyverse.org). We use [lintr](https://lintr.r-lib.org/articles/lintr.html) to scan styling on pull requests, this will automatically run and add comments for any code that is failing the standards we'd expect. Where these happen, please proactively resolve these as we are unlikely to approve pull requests that have styling issues.

You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply most of the styling using:

``` r
styler::style_pkg()
```

To check for any further styling issues locally, use:

``` r
lintr::lint_package()
```

[styler](https://CRAN.R-project.org/package=styler) will not fix all linting issues, so we recommend using that first, then using [lintr](https://lintr.r-lib.org/articles/lintr.html) to check for places you may need to manually fix styling issues such as line length or not using snake_case.

## Folder and script structure conventions

In an R package you are not allowed to have any sub directories in the R/ folder. Where possible we should have:

* one script per function 
or 
* one script per function family if a function belongs to a family

The script should share the name of the function or family. If needed then a <family>_utils.R script should be used for 
internal only functions that relate to a specific family.

Documentation for all data shipped with the packages is kept in `R/datasets_documentation.R`. Scripts used for preparing 
data used in the package is not in the R folder, it is in the `data-raw/` folder, helper functions for this can be found 
in the `R/datasets_utils.R` folder, and more details on maintaining the data sets can be found under the [Package data](#package-data) header on this page.

`utils.R` should be used to hold any cross-package helpers that aren't exported as functions or specific to a family.

Every exported function or data set gets its own test script, called `test-<function-name>.R` or `test-data-<data-name>.R` if for a data set.

### Testing

We use [testthat](https://cran.r-project.org/package=testthat) for unit tests, we expect all new functions to have some level of test coverage. 

If you want to see examples of existing tests for inspiration, take a look inside the `tests/testthat/` folder.

### Test coverage

There are GitHub Actions workflows that check and link the package to [codecov.io](https://app.codecov.io/gh/dfe-analytical-services/), this runs automatic scans to check the % of lines in functions that we are testing. On the [dfeR codecov pages](https://app.codecov.io/gh/dfe-analytical-services/dfeR) you can preview the variation by branch and commit to see the impact of changes made.

You will need to create an account or login using GitHub to see the pages.

The current % of coverage is shown as a badge on the package [README on GitHub](https://github.com/dfe-analytical-services/dfeR).

It is worth noting that 100% coverage does not mean that the tests are perfect, it only means that all lines are ran in tests, so it's more a measure of quantity rather than quality. Interesting to see all the same though, and we'd recommend using it to spot any potential elements of more complicated functions that you may have forgotten to test.

### Spelling

The [spelling](https://docs.ropensci.org/spelling/) package is used to check spelling. A custom word list of exceptions for this package exists in the `inst/` folder. 

There will be messages in the `devtools::check()` output if there's potential spelling errors. Please review and fix any genuine errors.

You can run a check yourself using:

``` r
spelling::spell_check_package()
```

To automatically pick up genuine new words in the package and add to this list, use:

``` r
spelling::update_wordlist()
```

## Adding vignettes

Vignettes can be found in the `vignettes/` folder as .Rmd files. To start a new one use:

``` r
usethis::use_vignette("name_of_vignette")
```

## Package data

Our general workflow for data in the package is:

0. Make sure you have everything you need installed and the package is loaded with `devtools::load_all()`
1. Use the relevant script in data-raw/ to generate and save the data set
2. Document the data set in R/datasets_documentation.R
3. Update any relevant fetch_ functions that use the data if appropriate
4. Run all the usual package checks and re-documenting of the package as you would for any other update

Our general principle is that all data should be created through reproducible code, so if it's custom data you're defining, write it in code. If you're sourcing it from elsewhere, try to make use of API connections. This saves on unnecessary data storage bloat and makes our scripts nice and reproducible without external dependencies to worry about.

We try to keep the data-raw/ scripts as tidy as possible, so some helper functions have been created in R/datasets-utils.R. These are not exported for users of the package and are only used by scripts in the data-raw/ folder for the creation of data exported in the package.

Sometimes when running the scripts to create new data sets you might hit this error:

```
Error in `check_is_package()`:
i use_data() is designed to work with packages
X Project "some letters and numbers" is not an R package.

```

If you do, try restarting R, making sure you have the project open, and the package loaded using `devtools::load_all()` and then run again.

For more details on maintaining data with an R package generally, see [chapter 7 Data, from R packages by Hadley Wickham and Jennifer Bryan](https://r-pkgs.org/data.html).

### Geography data sets

In the package we export a number of data sets derived from the [ONS Open Geography portal](https://geoportal.statistics.gov.uk/) for easy reuse within DfE analysis. Whenever new data appears or we want to make updates to these we need to do those manually.

#### Source

Where we can, we use their API to get the data, so that we have completely reproducible pipelines for this (rather than saving static files manually and then having to check if updates have been made, or having to worry about file storage).

On the [ONS Open Geography portal](https://geoportal.statistics.gov.uk/), you will usually be looking for data published as a feature or feature layer, as these are the ones made available via the API connection. You'll be able to preview the data in the browser and do basic searching / filtering on the table if you want to visualise it. Any feature data should have an option somewhere for 'I want to use this data' (or something similar if they update their website design) where you can get to an API explorer that allows you to run a basic query in the browser. In here you can usually find the dataset_id and also the parameters you want to use to get the data you need.

We have a `get_ons_api_data()` function that acts as a wrapper to the ONS API, it does things like converting readable parameters into a query string and also handles batching and multiple requests if needed, so you get all of the data in one nice neat data frame (there's a limit on the rows per single query for the API). If you're looking to expand on this function at all, you should first check if the [boundr package](https://github.com/francisbarton/boundr) does what you need, as that gives a number of methods for extracting data from the portal as well.

The way ONS publish has varied over their first few years of publishing, and on top of that each data set has an individual API connection for every year of boundaries. As there's no link over time from the ONS side we have helper functions defined in R/datasets_utils.R that wrap these up into a single neat time series bundle for us. Given the likelihood of further variations, don't be too surprised if adding new years to the data sets results in errors first time around, some manual fudgery is often needed so roll up your sleeves and prepare to get elbow deep into the murky depths of the R/datasets_utils.R file!

There is also some data we just define ourselves in code as we curate that, like custom regions we publish in DfE or our own lookup table for the shorthands used in the column names by ONS.

#### Workflow for updating geography data

Our general workflow for data in the package is:

1. Add a new year into the relevant script in data-raw/ script
2. Run the script to create a new data set
3. Run all package checks to make sure the data hasn't gone all funky on you
4. Update any fetch_ functions that use the data if appropriate
5. Document any changes to the data set in R/datasets_documentation.R if appropriate

Most data sets have tests that will fail as soon as the number of rows or columns change, this is both to provide a reliable service to users, but also to catch and remind us to maintain the documentation as the row number and all column names are defined in R/datasets_documentation.R. If these tests fail, update the relevant documentation, and then (ONLY THEN!) update the test expectations to match the new documentation.

The fetch_ family of functions in R/fetch.R act as quick helpers that pull from the data sets we export, so users can ees-ily grab say a list of all Scottish Parliamentary Constituencies for 2024, rather than needing to pull in a whole data frame and process it.

Often if adding a new year of data in, you will need to edit the year variables set near the start of the data-raw/ file and then also in the relevant fetch_ function @param year, as well as updating the public documentation of the data set in R/datasets_documentation.R.

## Code of Conduct

Please note that the dfeR project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project you agree to abide by its terms.
