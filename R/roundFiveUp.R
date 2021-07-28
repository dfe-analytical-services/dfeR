#' Round five up
#'
#' Round any number to a specified number of places, with 5's being rounded up.
#' This is as an alternative to round in base R, which rounds 5's down due to
#' an international standard I should reference here.
#'
#' This whole function could be refactored and documentation updated.
#'
#' @param x number to be rounded
#' @param n number of decimal places to round to
#'
#' @return Rounded number (should something else go in here?)
#' @export
#'
#' @examples
#' roundFiveUp(2495, -1)
#' roundFiveUp(2495.85, 1)
roundFiveUp <- function(value, roundTo) {

  if (!is.numeric(value) && !is.numeric(roundTo)) stop("both inputs must be numeric")
  if (!is.numeric(value)) stop("the value to be rounded must be numeric")
  if (!is.numeric(roundTo)) stop("the roundTo value must be numeric")

  z <- abs(value) * 10^roundTo
  z <- z + 0.5 + sqrt(.Machine$double.eps)
  z <- trunc(z)
  z <- z / 10^roundTo
  return(z * sign(value))
}
