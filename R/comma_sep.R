#' Comma separate
#'
#' @description
#' Adds separating commas to big numbers.
#'
#' @param number number to be comma separated
#'
#' @return string containing comma separated number
#' @export
#'
#' @examples
#' comma_sep(100)
#' comma_sep(1000)
#' comma_sep(3567000)
comma_sep <- function(number) {
  if (!is.numeric(number)) {
    stop("number must be a numeric value")
  }

  format(number, big.mark = ",", trim = TRUE, scientific = FALSE)
}
