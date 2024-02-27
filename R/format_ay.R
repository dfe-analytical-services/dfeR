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
    stop("year parameter must be a six digit number e.g. 201617")
  }
  sub("(.{4})(.*)", "\\1/\\2", year)
}

# function to reverse the change back to e.g. 201617
format_ay_reverse <- function(year) {
  if (!grepl("^\\d{4}/\\d{2}.*", year)) {
    stop("year parameter must be a seven digit string e.g. '2016/17'")
  }
  gsub("/", "", year)
}

 format_ay_reverse("2016/17")
