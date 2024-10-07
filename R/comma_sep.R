#' Comma separate
#'
#' @description
#' Adds separating commas to big numbers. If a value is not numeric it will
#' return the value unchanged and as a string.
#'
#' @param number number to be comma separated
#' @param nsmall minimum number of digits to the right of the decimal point
#'
#' @return string
#' @export
#'
#' @examples
#' comma_sep(100)
#' comma_sep(1000)
#' comma_sep(3567000)
comma_sep <- function(number,
                      nsmall = 0L) {
  format(number,
    big.mark = ",", nsmall = nsmall, trim = TRUE,
    scientific = FALSE
  )
}
