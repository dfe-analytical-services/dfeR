# Check RENV_DOWNLOAD_FILE_METHOD system variable

The legacy `proxy.R` script used
`setx RENV_DOWNLOAD_FILE_METHOD wininet` to route renv downloads through
Windows wininet. This breaks renv outside the DfE network and is no
longer needed. This function checks the `RENV_DOWNLOAD_FILE_METHOD`
system environment variable and (with `clean = TRUE`) unsets it for the
current R session.

On Windows, `clean = TRUE` also clears the variable permanently from
your user environment (via `setx`), so it does not come back the next
time you start R. Windows only applies the change to new processes, so
close and reopen RStudio afterwards.

## Usage

``` r
check_renv_dl_file_method(clean = FALSE)
```

## Arguments

- clean:

  If `TRUE`, attempt to clean detected issues. Default `FALSE`.

## Value

List object containing `RENV_DOWNLOAD_FILE_METHOD` plus a `status`
field.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
check_renv_dl_file_method()
} # }
```
