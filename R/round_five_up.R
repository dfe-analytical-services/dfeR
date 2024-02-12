#' Round five up
#'
#' @description
#' Round any number to a specified number of places, with 5's being rounded up.
#'
#' @details
#' Rounds to 0 decimal places by default.
#'
#' You can use a negative value for the decimal places. For example:
#' -1 would round to the nearest 10
#' -2 would round to the nearest 100
#' and so on.
#'
#' This is as an alternative to round in base R, which uses a bankers round.
#' For more information see the
#' [round() documentation](https://rdrr.io/r/base/Round.html).
#'
#'
#' @param number number to be rounded
#' @param dp number of decimal places to round to, default is 0
#'
#' @return Rounded number
#' @export
#'
#' @examples
#' # No dp set
#' round_five_up(2485.85)
#'
#' # With dp set
#' round_five_up(2485.85, 2)
#' round_five_up(2485.85, 1)
#' round_five_up(2485.85, 0)
#' round_five_up(2485.85, -1)
#' round_five_up(2485.85, -2)
round_five_up <- function(number, dp = 0) {
  if (!is.numeric(number) && !is.numeric(dp)) {
    stop("both input arguments must be numeric")
  }
  if (!is.numeric(number)) {
    stop("the input number to be rounded must be numeric")
  }
  if (!is.numeric(dp)) {
    stop("the decimal places input must be numeric")
  }

  z <- abs(number) * 10^dp
  z <- z + 0.5 + sqrt(.Machine$double.eps)
  z <- trunc(z)
  z <- z / 10^dp
  return(z * sign(number))
}
