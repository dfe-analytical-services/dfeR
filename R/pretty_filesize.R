#' Pretty file size
#'
#' @description
#' Converts a raw file size from bytes to a more readable format.
#'
#' @details
#' Designed to be used in conjunction with the file.size()
#' function in base R.
#'
#' Presents in kilobytes, megabytes or gigabytes.
#'
#' Shows as bytes until 1 KB, then kilobytes up to 1 MB, then megabytes
#' until 1GB, then it will show as gigabytes for anything larger.
#'
#' Rounds the end result to 2 decimal places.
#'
#' Using base 10 (decimal), so 1024 bytes is 1,024 KB.
#'
#' @param filesize file size in bytes
#'
#' @return string containing prettified file size
#' @family prettying functions
#' @seealso [comma_sep()] [round_five_up()]
#' @export
#' @examples
#' pretty_filesize(2)
#' pretty_filesize(549302)
#' pretty_filesize(9872948939)
#' pretty_filesize(1)
#' pretty_filesize(1000)
#' pretty_filesize(1000^2)
#' pretty_filesize(10^9)
pretty_filesize <- function(filesize) {
  if (!is.numeric(filesize)) {
    stop("file size must be a numeric value")
  } else {
    if (round_five_up(filesize / 10^9, 2) >= 1) {
      return(paste0(comma_sep(round_five_up(filesize / 10^9, 2)), " GB"))
    } else {
      if (round_five_up(filesize / 1000^2, 2) >= 1) {
        return(paste0(round_five_up(filesize / 1000^2, 2), " MB"))
      } else {
        if (round_five_up(filesize, 2) >= 1000) {
          return(paste0(round_five_up(filesize / 1000, 2), " KB"))
        } else {
          if (filesize == 1) {
            "1 byte"
          } else {
            return(paste0(round_five_up(filesize, 2), " bytes"))
          }
        }
      }
    }
  }
}
