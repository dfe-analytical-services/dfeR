# Air Install

checks for air installation status and installs it if required (or if
the installed version is older than the minimum supported version),
updating the global settings if selected

## Usage

``` r
air_install(update_rstudio_settings = FALSE, verbose = TRUE, force = FALSE)
```

## Arguments

- update_rstudio_settings:

  auto update RStudio settings

- verbose:

  Run in verbose mode

- force:

  force (re)installation of Air, even if an up to date version is
  already installed

## Examples

``` r
if (FALSE) { # \dontrun{
air_install()
} # }
```
