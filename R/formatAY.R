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
#' formatAY(201617)
#' formatAY("201617")
formatAY <- function(year) {
  if (!grepl("^[0-9]{6,6}$", year)) stop("year parameter must be a six digit number e.g. 201617")

  sub("(.{4})(.*)", "\\1/\\2", year)
}
