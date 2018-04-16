#' Format academic year
#'
#' This function formats academic year variables for reporting purposes. It
#' will convert an academic year input from 201516 format to 2015/16 format.
#'
#' It accepts both numerical and character arguments.
#'
#' @param year Academic year
#' @return A formatted academic year
#' @export
#' @examples
#' format_ay(201617)
#' format_ay("201617")
format_ay <- function(year){

  if (!grepl("^[0-9]{6,6}$",year)) stop("year parameter must be a six didgit number e.g. 201617")

  sub("(.{4})(.*)", "\\1/\\2", year)

}

