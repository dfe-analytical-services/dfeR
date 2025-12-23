#' Determine decimal places for large numeric values
#'
#' This helper function calculates the appropriate number of decimal places
#' based on the value's magnitude. Values smaller than 1 million use the
#' supplied default decimal places (`dp`). For values of 1 million or more,
#' decimal places are conditionally applied: if the value normalized by a
#' million or billion is not a whole number, `dynamic_dp_value` decimal places
#' are used; otherwise, 0 decimal places are used. This ensures that only
#' non-integer millions or billions are shown with extra precision.
#'
#' @param value A single numeric value.
#' @param dp Integer. The default number of decimal places for values less than 1 million.
#' @param dynamic_dp_value Integer. Default is 2. Sets the number of decimal
#' places to use when the value is ≥ 1 million or ≥ 1 billion but not a whole number after scaling.
#' This adds precision only when needed, improving clarity without over-formatting for pretty_num().
#' @return An integer indicating the number of decimal places to use.
#' @keywords internal
#' @noRd
#' @examples
#' \dontrun{
#' determine_dp(999999) # Returns 0 (less than 1 million)
#' determine_dp(1e6) # Returns 0 (exactly 1 million)
#' determine_dp(2e6) # Returns 0 (exactly 2 million)
#' determine_dp(1.5e6) # Returns 2 (not a whole million)
#' determine_dp(10e6) # Returns 0 (exactly 10 million)
#' determine_dp(1e9) # Returns 0 (exactly 1 billion)
#' determine_dp(2e9) # Returns 0 (exactly 2 billion)
#' determine_dp(1.5e9) # Returns 2 (not a whole billion)
#' determine_dp(10e9) # Returns 0 (exactly 10 billion)
#' determine_dp(-1e6) # Returns 0 (absolute value logic)
#' determine_dp(1e6, dp = 0, dynamic_dp_value = 4) # Returns 0
#' determine_dp(500000, dp = 1, dynamic_dp_value = 3) # Returns 1
#' determine_dp(10e6, dp = 1, dynamic_dp_value = 3) # Returns 0
#' determine_dp(-2e6, dp = 3, dynamic_dp_value = 5) # Returns 0
#' }
determine_dp <- function(value, dp = 0, dynamic_dp_value = 2) {
  # Return dp if value is NA
  if (is.na(value)) {
    return(dp)
  }

  # Use absolute value for magnitude checks
  abs_val <- abs(value)

  # For billions: if value divided by 1e9 is not a whole number, use dynamic_dp_value; else 0
  if (abs_val >= 1e9) {
    return(ifelse((value / 1e9) %% 1 != 0, dynamic_dp_value, 0))
  }
  # For millions: if value divided by 1e6 is not a whole number, use dynamic_dp_value; else 0
  if (abs_val >= 1e6) {
    return(ifelse((value / 1e6) %% 1 != 0, dynamic_dp_value, 0))
  }

  # For values less than 1 million, use dp
  return(dp)
}
