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

## R/ folder

In an R package you are not allowed to have any sub directories in the R/ folder. Where possible we should have one script per function or per function family if a function belongs to a wider family (for example the fetch_ functions). The script should share the name of the function or family. Given the ever growing number of functions in this package we have made a few specific scripts to contain multiple functions:

* R/internal_functions.R - this contains any internal, non-exported functions that are only for use in package code and not available to users
* R/helper_functions.R - this contains any functions that are used as helpers in other functions but still exported for users to use if they want
* R/all_datasets.R - this contains documentation for all data sets exported by the packages

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

## ONS API

Add some notes here about the fetch_geog script

## Code of Conduct

Please note that the dfeR project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project you agree to abide by its terms.
