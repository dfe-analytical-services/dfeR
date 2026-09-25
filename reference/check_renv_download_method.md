# Check renv download method

The renv package can retrieve packages either using `curl` or `wininet`,
but `wininet` doesn't work from within the DfE network. This function
checks for the parameter controlling which of these is used
(`RENV_DOWNLOAD_METHOD`) in the user's `.Renviron` and sets it to `curl`
when called with `clean = TRUE`.

## Usage

``` r
check_renv_download_method(renviron_file = "~/.Renviron", clean = FALSE)
```

## Arguments

- renviron_file:

  Location of `.Renviron` file. Default: `~/.Renviron`

- clean:

  If `TRUE`, attempt to clean detected issues. Default `FALSE`.

## Value

List object containing `RENV_DOWNLOAD_METHOD` (with surrounding
whitespace and any wrapping quotes stripped, or `NA` if the variable is
not set) plus a `status` field.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
check_renv_download_method()
#> 
#> ── renv download method ──
#> 
#> ✖ RENV_DOWNLOAD_METHOD is not currently set.
#> To manually update your .Renviron file:
#> • Run `usethis::edit_r_environ()` in the R console.
#> • Add the following line to .Renviron: `RENV_DOWNLOAD_METHOD="curl"`
#> Or run `dfeR::check_renv_download_method(clean = TRUE)`.
```
