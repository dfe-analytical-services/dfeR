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
#' @param dp_by_magnitude_value The default is 3.
#' Value for decimal places to use for values
#' over 1 million or 1 billion that are not divisible by 10.
#'
#'
#' @return An integer indicating the number of decimal places to use.
#' @examples
#' determine_dp(999, dp = 2) # Returns 2
#' determine_dp(1234567, dp = 3) # Returns 3
#' determine_dp(10000000, dp = 2) # Returns 0
#' determine_dp(5000000000, dp = 3) # Returns 3
#' @export
#' @keywords internal
determine_dp <- function(value,
                         dp = 0,
                         dynamic_dp_value = 3) {
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
    # if it is not divisible by 10 return 3 else return 0

    return(ifelse((value / 1e9) %% 10 != 0, dynamic_dp_value, 0))
  }
  # if the value is bigger or equal to 1 million
  # do an ifelse to check if the value divided by
  # 1 million is not divisible by 10
  # if it is not divisible by 10 return 3 else return 0
  if (abs_val >= 1e6) {
    return(ifelse((value / 1e6) %% 10 != 0, dynamic_dp_value, 0))
  }

  return(dp)
}
