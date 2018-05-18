#' Format academic year
#'
#' This function formats academic year variables for reporting purposes. It
#' will convert an academic year input from 201516 format to 2015/16 format. \cr\cr
#'
#' It accepts both numerical and character arguments.
#'
#' @param year Academic year
#' @return Character vector of formatted academic year
#' @export
#' @examples
#' format_ay(201617)
#' format_ay("201617")
format_ay <- function(year){

  if (!grepl("^[0-9]{6,6}$",year)) stop("year parameter must be a six didgit number e.g. 201617")

  sub("(.{4})(.*)", "\\1/\\2", year)

}



#' Round to nearest
#'
#' This function rounds a number (x) to the nearest specified multiple (n).\cr\cr
#'
#' It accepts both numerical and character arguments.
#'
#' @param x The number to be rounded
#' @param n the multiple to use when rounding
#' @return Character vector of rounded number
#' @export
#' @examples
#' round_nearest(1337,10)
#' round_nearest("1337",10)
round_nearest  <- function(x,n){

  if (!grepl("[[:digit:]]",x)) stop("x must be a number")

  if (!grepl("[[:digit:]]",n)) stop("n must be a number")

  round(as.numeric(x) / as.numeric(n), 0) * as.numeric(n)

}


