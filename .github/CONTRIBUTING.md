# Contributing to dfeR

Ideas for `dfeR` should first be raised as a [GitHub issue](https://github.com/dfe-analytical-services/dfeR) after which anyone is free to write the code and create a pull request for review. 

For a detailed discussion on contributing to R packages in the tidyverse, please see the [development contributing guide](https://rstd.io/tidy-contrib) and their [code review principles](https://code-review.tidyverse.org/). Full knowledge of this isn't needed, though some awareness of general principles will be useful.

## Basics

When contributing to dfeR you should work on a new branch taken from main.

Any pull request must be reviewed and approved by at least one admin user before it can be merged. 

### Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file. 
This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. 
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

### Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure someone from the team agrees that it’s needed. 

- If you’ve found a bug, please file an issue that illustrates the bug with a minimal 
[reprex](https://www.tidyverse.org/help/#reprex) (this will also help you write a unit test, if needed).

- See the tidyverse guide on [how to create a great issue](https://code-review.tidyverse.org/issues/) for more advice.

Where possible, we'd recommend following the [Test Driven Development (TDD)](https://testdriven.io/test-driven-development/) approach:

- Write tests for the behaviour you want
- Write just enough code so that the tests pass
- Continue to improve code while keeping tests passing

## Handy workflows

Keyboard shortcuts for the `devtools` package to use while in RStudio:
- `load_all()` (Ctrl-Shift-L): Load code with dfeR package
- `test()` (Ctrl-Shift-T): Run tests
- `document()` (Ctrl-Shift-D): Rebuild docs and NAMESPACE
- `check()` (Ctrl-Shift-E): Check complete package

We recommend using the [usethis](https://usethis.r-lib.org/index.html) package where possible for consistency and simplicity.

## Adding package dependencies

Add any packages the package users will need with:
``` r
usethis::use_package(pkgname, type = "imports")
```

Add any packages that package developers only may need with:
``` r
usethis::use_package(pkgname, type = "suggests")
```

## Updating the README

There are two README files that are linked with a pre-commit-hook to ensure are kept in sync.

Make all changes to the `README.Rmd` file and then run the following line to rebuild:

``` r
devtools::build_readme()
```

## Updating the package version

Once changes have been completed, reviewed and are ready for use in the wild, you can increment the package version using:
``` r
usethis::use_version()
```

Once you've incremented the version number, it'll offer to perform a commit on your behalf, so all you then need to do is push to GitHub.

### Code style

New code should follow the tidyverse [style guide](https://style.tidyverse.org). 

You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles.  

We use [testthat](https://cran.r-project.org/package=testthat) for unit tests, we expect all new functions to have some level of test coverage.  

## Code of Conduct

Please note that the dfeR project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project you agree to abide by its terms.
