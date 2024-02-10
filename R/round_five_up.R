#' Round five up
#'
#' Round any number to a specified number of places, with 5's being rounded up.
#'
#' Rounds to 0 decimal places by default.
#'
#' You can use a negative value for the decimal places. For example:
#' -1 would round to the nearest 10
#' -2 would round to the nearest 100
#' and so on.
#'
#' This is as an alternative to round in base R, which uses a bankers round.
#' For more information see the [round() documentation
#' ](https://www.rdocumentation.org/packages/base/versions/3.6.2/topics/Round).
#'
#'
#' @param value number to be rounded
#' @param dp number of decimal places to round to, default is 0
#'
#' @return Rounded number
#' @export
#'
#' @examples
#' round_five_up(2495.85)
#' round_five_up(2495.85, 1)
#' round_five_up(2495.85, 0)
#' round_five_up(2495.85, -1)
#' round_five_up(2495.85, -2)
#'
round_five_up <- function(value, dp = 0) {
  if (!is.numeric(value) && !is.numeric(dp)) {
    stop("both input arguments must be numeric")
  }
  if (!is.numeric(value)) {
    stop("the value argument must be numeric")
  }
  if (!is.numeric(dp)) {
    stop("the decimal places argument must be numeric")
  }

  z <- abs(value) * 10^dp
  z <- z + 0.5 + sqrt(.Machine$double.eps)
  z <- trunc(z)
  z <- z / 10^dp
  return(z * sign(value))
}
