#' Shared parameters and return values for diagnostic helpers
#'
#' @description
#' Internal documentation object that holds the parameters and return-value
#' wording reused across [diagnostic_test()] and the `check_*()` helpers. It is
#' not exported and is not intended to be called - it exists only as a single
#' source of truth for [roxygen2::roxygen2-package] to inherit from via
#' `@inheritParams` and `@inherit`.
#'
#' @param clean If `TRUE`, attempt to clean detected issues. Default `FALSE`.
#'
#' @details
#' Each check returns a list including a `status` field, one of `"pass"`,
#' `"fail"`, `"fixed"` or `"info"`, depending on the outcome of the check.
#'
#' @name diagnostic_params
#' @keywords internal
NULL
