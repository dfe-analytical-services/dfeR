# Check the location of the global .gitconfig file

Reports the location Git is using for its global config file. R,
RStudio, and the system Git can disagree on this location (e.g. when
`HOME` is redirected into OneDrive). The function flags non-standard
locations and prints the resolved path so users can sanity-check it
against the file they think they are editing.

## Usage

``` r
check_gitconfig_location()
```

## Value

List object containing `gitconfig_path` (or `NA` if none found) plus a
`status` field.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.

## Examples

``` r
if (FALSE) { # \dontrun{
check_gitconfig_location()
} # }
```
