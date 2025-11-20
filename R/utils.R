#' Determine decimal places for large numeric values
#'
#' This helper function calculates the appropriate number of decimal places
#' based on the value's magnitude. Values smaller than 1 million use the
#' supplied default decimal places. For values over 1 million or 1 billion,
#' decimal places are conditionally applied if the value normalised by a
#' million or billion is not divisible by 10.
#'
#' @param value A single numeric value.
#' @param dp Integer. The default number of decimal places for values
#' over 1 million or 1 billion.
#' @param dynamic_dp_value Integer. Default is 2. Sets the number of decimal
#' places to use when the value is ≥ 1 million or ≥ 1 billion but not
#' divisible by 10 after scaling. This adds precision only when needed,
#' improving clarity without over-formatting fo pretty_num().
#' @return An integer indicating the number of decimal places to use.
#' @keywords internal
#' @noRd
#' @examples
#' \dontrun{
#' determine_dp(999999) # Returns 0 (less than 1 million)
#' determine_dp(1e6) # Returns 2 (not divisible by 10 after scaling)
#' determine_dp(10e6) # Returns 0 (divisible by 10 after scaling)
#' determine_dp(1e9) # Returns 2 (not divisible by 10 after scaling)
#' determine_dp(10e9) # Returns 0 (divisible by 10 after scaling)
#' determine_dp(-1e6) # Returns 2 (absolute value logic)
#' determine_dp(1e6, dp = 0, dynamic_dp_value = 4) # Returns 4
#' determine_dp(500000, dp = 1, dynamic_dp_value = 3) # Returns 1
#' determine_dp(10e6, dp = 1, dynamic_dp_value = 3) # Returns 0
#' determine_dp(-2e6, dp = 3, dynamic_dp_value = 5) # Returns 5
#' }
determine_dp <- function(value,
                         dp = 0,
                         dynamic_dp_value = 2) {
  # Check if value is NA and return dp as is in that case
  if (is.na(value)) {
    return(dp)
  }

  # make the value absolute for comparison
  abs_val <- abs(value)
  # if the value is bigger or equal to 1 billion
  if (abs_val >= 1e9) {
    # do an ifelse to check if the value divided by
    # 1 billion is not divisible by 10
    # if it is not divisible by 10 return 2 else return 0

    return(ifelse((value / 1e9) %% 10 != 0, dynamic_dp_value, 0))
  }
  # if the value is bigger or equal to 1 million
  # do an ifelse to check if the value divided by
  # 1 million is not divisible by 10
  # if it is not divisible by 10 return 2 else return 0
  if (abs_val >= 1e6) {
    return(ifelse((value / 1e6) %% 10 != 0, dynamic_dp_value, 0))
  }

  return(dp)
}
