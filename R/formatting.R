#' Format academic year
#'
#' This function formats academic year variables for reporting purposes. It
#' will convert an academic year input from 201516 format to 2015/16 format.
#'
#' @param year Academic year
#' @return A formatted academic year
#' @export
format_ay <- function(year){

  if (!is.numeric(year)) stop("year parameter must be a number e.g. 201617")

  if (nchar(year)!=6) stop("year parameter should be 6 digits long e.g. 201617")

  sub("(.{4})(.*)", "\\1/\\2", year)

}


