# Check for an RTools / make toolchain

Some R packages require compilation, which on Windows means RTools must
be installed and on `PATH`. This function checks whether `make` is
available via `Sys.which("make")`. It does not attempt to install
RTools.

## Usage

``` r
check_rtools()
```

## Value

List object containing `rtools_make_path` plus a `status` field. Missing
RTools is reported as `"info"` rather than a failure because many users
will not need to compile packages from source.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
check_rtools()
} # }
```
