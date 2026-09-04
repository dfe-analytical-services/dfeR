# Check GITHUB_PAT setting

If the `GITHUB_PAT` system variable is set, it can cause issues with R
installing packages from GitHub (usually with an error of "ERROR \[curl:
(22) The requested URL returned error: 401\]"). This function checks
whether the variable is set and (with `clean = TRUE`) clears it for the
current R session.

The function masks the PAT value both in console output and in the
returned list (only its length and last four characters are shown). The
raw value is never returned, so it is safe to share the result of
[`diagnostic_test()`](https://dfe-analytical-services.github.io/dfeR/reference/diagnostic_test.md).

## Usage

``` r
check_github_pat(clean = FALSE)
```

## Arguments

- clean:

  If `TRUE`, attempt to clean detected issues. Default `FALSE`.

## Value

List object containing `GITHUB_PAT` (masked: empty string when unset,
otherwise `"..."` followed by the last four characters) plus a `status`
field.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
check_github_pat()
} # }
```
