#' Format academic year
#'
#' This function formats academic year variables for reporting purposes. It
#' will convert an academic year input from 201516 format to 2015/16 format.
#'
#' It accepts both numerical and character arguments.
#'
#' @param year Academic year
#' @return Character vector of formatted academic year
#' @export
#' @examples
#' format_ay(201617)
#' format_ay("201617")
format_ay <- function(year) {
  if (!grepl("^[0-9]{6,6}$", year)) {
    stop("year parameter must be a six digit number or string e.g. 201617")
  }
  sub("(.{4})(.*)", "\\1/\\2", year)
}

#' Undo academic year formatting
#'
#' This function converts academic year variables back into 201617 format.
#'
#' It accepts character arguments.
#'
#' @param year Academic year
#' @return Unformatted 6 digit year as string
#' @export
#' @examples
#' format_ay_reverse("2016/17")
format_ay_reverse <- function(year) {
  if (!grepl("^\\d{4}/\\d{2}.*", year)) {
    stop("year parameter must be a seven digit string in an academic
         year format, e.g. '2016/17'")
  }
  gsub("/", "", year)
}

format_ay_reverse("2016/17")
