# Check the location of .Renviron and .Rprofile

Reports where R will read the user-level `.Renviron` and `.Rprofile`
files from, listing every location R consults in precedence order: the
`R_ENVIRON_USER` / `R_PROFILE_USER` override, the current working
directory, and the home directory. Each file that exists is listed, and
the one R actually uses is tagged, so you can spot when more than one
copy exists (for example a project-level file shadowing the one in your
home directory).

This check is purely informational and never reports a failure.

## Usage

``` r
check_renv_rprof_location()
```

## Value

List object with a `renviron` and an `rprofile` entry (each a list of
the `used` path and the `found` paths that exist), plus a `status` field
which is always `"info"`.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
check_renv_rprof_location()
} # }
```
