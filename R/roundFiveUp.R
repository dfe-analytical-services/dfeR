#' Round five up
#'
#' Round any number to a specified number of places, with 5's being rounded up.
#' This is as an alternative to round in base R, which sometimes rounds 5's down due to
#' an international standard. For more information see the round() documentation
#' https://stat.ethz.ch/R-manual/R-devel/library/base/html/Round.html
#'
#' You can use a negative value for the decimal places. For example:
#' -1 would round to the nearest 10
#' -2 would round to the nearest 100
#' and so on.
#'
#' @param value number to be rounded
#' @param dp number of decimal places to round to
#'
#' @return Rounded number
#' @export
#'
#' @examples
#' roundFiveUp(2495, -1)
#' roundFiveUp(2495.85, 1)
roundFiveUp <- function(value, dp) {

  if (!is.numeric(value) && !is.numeric(dp)) stop("both inputs must be numeric")
  if (!is.numeric(value)) stop("the value to be rounded must be numeric")
  if (!is.numeric(dp)) stop("the decimal places value must be numeric")

  z <- abs(value) * 10^dp
  z <- z + 0.5 + sqrt(.Machine$double.eps)
  z <- trunc(z)
  z <- z / 10^dp
  return(z * sign(value))
}
