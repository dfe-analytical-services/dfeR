# Check proxy settings

Prior to the pandemic, analysts in the DfE would need to add proxy
settings to either their Git configuration or system environment
variables. These settings now prevent Git from connecting to remote
archives on GitHub and Azure DevOps, so this function identifies them
and (with `clean = TRUE`) removes them.

Both the Git configuration (keys `http.proxy`, `https.proxy` by default)
and the system environment variables (`http_proxy`, `https_proxy`,
`no_proxy` by default) are checked.

On Windows, `clean = TRUE` clears the matching environment variables
permanently from your user environment (via `setx`) as well as from the
current R session, so they do not come back the next time you start R.
Windows only applies the change to new processes, so close and reopen
RStudio afterwards.

## Usage

``` r
check_proxy_settings(
  proxy_setting_names = c("http.proxy", "https.proxy"),
  proxy_env_names = c("http_proxy", "https_proxy", "no_proxy"),
  clean = FALSE
)
```

## Arguments

- proxy_setting_names:

  Vector of Git-config keys to check for. Default:
  `c("http.proxy", "https.proxy")`

- proxy_env_names:

  Vector of system environment variable names to check for. Default:
  `c("http_proxy", "https_proxy", "no_proxy")`

- clean:

  If `TRUE`, attempt to clean detected issues. Default `FALSE`.

## Value

A list with three slots: `git` (named list of detected Git-config proxy
entries, or `NULL`), `system` (named list of detected
environment-variable proxy entries, or `NULL`) and a `status` field.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
check_proxy_settings()
} # }
```
