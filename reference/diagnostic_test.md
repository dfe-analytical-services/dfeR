# Diagnostic testing

Run a set of diagnostic tests to check for common issues found when
setting up R on a DfE system. The function runs each `check_*()` helper
in turn and returns a combined list of detected settings. Problems can
optionally be fixed by passing `clean = TRUE`.

The checks include:

- Proxy settings in the Git configuration and system environment
  ([`check_proxy_settings()`](https://dfe-analytical-services.github.io/dfeR/reference/check_proxy_settings.md))

- Git SSL-verify setting
  ([`check_git_sslverify()`](https://dfe-analytical-services.github.io/dfeR/reference/check_git_sslverify.md))

- The location of the global `.gitconfig` file
  ([`check_gitconfig_location()`](https://dfe-analytical-services.github.io/dfeR/reference/check_gitconfig_location.md))

- The `GITHUB_PAT` system variable
  ([`check_github_pat()`](https://dfe-analytical-services.github.io/dfeR/reference/check_github_pat.md))

- renv download method in `.Renviron`
  ([`check_renv_download_method()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_download_method.md))

- The `RENV_DOWNLOAD_FILE_METHOD` system variable
  ([`check_renv_dl_file_method()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_dl_file_method.md))

- Presence of an RTools/`make` toolchain
  ([`check_rtools()`](https://dfe-analytical-services.github.io/dfeR/reference/check_rtools.md))

- The location of `.Renviron` and `.Rprofile`
  ([`check_renv_rprof_location()`](https://dfe-analytical-services.github.io/dfeR/reference/check_renv_rprof_location.md))

## Usage

``` r
diagnostic_test(clean = FALSE, full = FALSE)
```

## Arguments

- clean:

  If `TRUE`, attempt to clean detected issues. Default `FALSE`.

- full:

  If `TRUE`, append a session-dump section after the per-check output
  containing
  [`renv::diagnostics()`](https://rstudio.github.io/renv/reference/diagnostics.html),
  [`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html) and
  [`options()`](https://rdrr.io/r/base/options.html). Useful for sharing
  a full diagnostic with support. Defaults to `FALSE`. Environment
  variables whose names look sensitive (containing e.g. `TOKEN`,
  `SECRET`, `KEY`, `PAT`, `PASSWORD`, `CRED`) are masked, but the
  [`options()`](https://rdrr.io/r/base/options.html) and
  [`renv::diagnostics()`](https://rstudio.github.io/renv/reference/diagnostics.html)
  sections are printed as-is, so review the output before sharing it in
  public channels.

## Value

Invisibly, a named list keyed by check (`proxy`, `sslverify`,
`gitconfig`, `github_pat`, `renv_download`, `renv_download_file`,
`rtools`, `renviron_rprofile`). Each entry is the result list returned
by the corresponding `check_*` helper, plus a `status` field.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
diagnostic_test()
} # }
```
