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
if (FALSE) { # \dontrun{
check_renv_download_method()
} # }
```
