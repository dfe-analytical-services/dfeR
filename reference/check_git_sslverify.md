# Check Git sslverify setting

Checks the values of the SSL-verify settings in the global Git config.
If they're set to `false`, the function flips them back to `TRUE` when
called with `clean = TRUE`. By default it checks `http.sslVerify` and
`https.sslVerify`.

## Usage

``` r
check_git_sslverify(
  ssl_verify_vars = c("http.sslverify", "https.sslverify"),
  clean = FALSE
)
```

## Arguments

- ssl_verify_vars:

  Vector of variables to check for in the Git config.

- clean:

  If `TRUE`, attempt to clean detected issues. Default `FALSE`.

## Value

List of sslverify settings plus a `status` field.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
check_git_sslverify()
} # }
```
