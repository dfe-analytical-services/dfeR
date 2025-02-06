#' Controllable console messages
#'
#' Quick expansion to the `message()` function aimed for use in functions for
#' an easy addition of a global verbose TRUE / FALSE argument to toggle the
#' messages on or off
#'
#' @param ... any message you would normally pass into `message()`. See
#' \code{\link{message}} for more details
#'
#' @param verbose logical, usually a variable passed from the function you are
#' using this within
#'
#' @return No return value, called for side effects
#'
#' @export
#'
#' @examples
#' # Usually used in a function
#' my_function <- function(count_fingers, verbose) {
#'   toggle_message("I have ", count_fingers, " fingers", verbose = verbose)
#'   fingers_thumbs <- count_fingers + 2
#'   toggle_message("I have ", fingers_thumbs, " digits", verbose = verbose)
#' }
#'
#' my_function(5, verbose = FALSE)
#' my_function(5, verbose = TRUE)
#'
#' # Can be used in isolation
#' toggle_message("I want the world to read this!", verbose = TRUE)
#' toggle_message("I ain't gonna show this message!", verbose = FALSE)
#'
#' count_fingers <- 5
#' toggle_message("I have ", count_fingers, " fingers", verbose = TRUE)
toggle_message <- function(..., verbose) {
  if (verbose) {
    message(...)
  }
}
