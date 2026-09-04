# Shared parameters and return values for diagnostic helpers

Internal documentation object that holds the parameters and return-value
wording reused across
[`diagnostic_test()`](https://dfe-analytical-services.github.io/dfeR/reference/diagnostic_test.md)
and the `check_*()` helpers. It is not exported and is not intended to
be called - it exists only as a single source of truth for
roxygen2::roxygen2-package to inherit from via `@inheritParams` and
`@inherit`.

## Arguments

- clean:

  If `TRUE`, attempt to clean detected issues. Default `FALSE`.

## Details

Each check returns a list including a `status` field, one of `"pass"`,
`"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.
