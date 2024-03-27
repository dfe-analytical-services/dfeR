#' Prettify big numbers into a readable format
#'
#' @description
#' Uses `as.numeric()` to force a numeric value and then formats prettily
#' for easy presentation in console messages, reports, or dashboards.
#'
#' This rounds to 2 decimal places by default, and adds in comma separators.
#'
#' Expect that this will commonly be used for adding the pound symbol,
#' the percentage symbol, or to have a +/- prefixed based on the value.
#'
#' If applying over multiple or unpredictable values and you want to preserve
#' a non-numeric symbol such as "x" or "c" for data not available, use the
#' `ignore_na = TRUE` argument to return those values unaffected.
#'
#' If you want to customise what NA values are returned as, use the `alt_na`
#' argument.
#'
#' This function silences the warning around NAs being introduced by coercion.
#' @param value value to be prettified
#' @param prefix prefix for the value, if "+/-" then it will automatically
#' assign + or - based on the value
#' @param gbp whether to add the pound symbol or not, defaults to not
#' @param suffix suffix for the value, e.g. "%"
#' @param dp number of decimal places to round to, 2 by default
#' @param ignore_na whether to skip function for strings that can't be
#' converted and return original value
#' @param alt_na alternative value to return in place of NA, e.g. "x"
#'
#' @return string featuring prettified value
#' @family prettying functions
#' @seealso [comma_sep()] [round_five_up()] [as.numeric()]
#' @export
#'
#' @examples
#' # On individual values
#' pretty_num(5789, gbp = TRUE)
#' pretty_num(564, prefix = "+/-")
#' pretty_num(567812343223, gbp = TRUE, prefix = "+/-")
#' pretty_num(11^9, gbp = TRUE, dp = 3)
#' pretty_num(-11^8, gbp = TRUE, dp = -1)
#' pretty_num("56.089", suffix = "%")
#' pretty_num("x")
#' pretty_num("x", ignore_na = TRUE)
#' pretty_num("nope", alt_na = "x")
#'
#' # Applied over an example vector
#' vector <- c(3998098008, -123421421, "c", "x")
#' unlist(lapply(vector, pretty_num))
#' unlist(lapply(vector, pretty_num, prefix = "+/-", gbp = TRUE))
#'
#' # Return original values if NA
#' unlist(lapply(vector, pretty_num, ignore_na = TRUE))
#'
#' # Return alternative value in place of NA
#' unlist(lapply(vector, pretty_num, alt_na = "z"))
pretty_num <- function(
    value,
    prefix = "",
    gbp = FALSE,
    suffix = "",
    dp = 2,
    ignore_na = FALSE,
    alt_na = FALSE) {
  # Check we're only trying to prettify a single value
  if (length(value) > 1) {
    stop("value must be a single value, multiple values were detected")
  }

  # Force to numeric
  num_value <- suppressWarnings(as.numeric(value))

  # Check if should skip function
  if (is.na(num_value)) {
    if (ignore_na == TRUE) {
      return(value) # return original value
    } else if (alt_na != FALSE) {
      return(alt_na) # return custom NA value
    } else {
      return(num_value) # return NA
    }
  }

  # Convert GBP to pound symbol
  if (gbp == TRUE) {
    currency <- "\U00a3"
  } else {
    currency <- ""
  }

  # Add + / - symbols depending on size of value
  if (prefix == "+/-") {
    if (value >= 0) {
      prefix <- "+"
    } else {
      prefix <- "-"
    }
    # Add in negative symbol if appropriate and not auto added with +/-
  } else if (value < 0) {
    prefix <- paste0("-", prefix)
  }

  # Add suffix and prefix, plus convert to million or billion
  if (abs(num_value) >= 1.e9) {
    paste0(
      prefix,
      currency,
      comma_sep(round_five_up(abs(num_value) / 1.e9, dp = dp)),
      " billion",
      suffix
    )
  } else if (abs(num_value) >= 1.e6) {
    paste0(
      prefix,
      currency,
      comma_sep(round_five_up(abs(num_value) / 1.e6, dp = dp)),
      " million",
      suffix
    )
  } else {
    paste0(
      prefix,
      currency,
      comma_sep(round_five_up(abs(num_value), dp = dp)),
      suffix
    )
  }
}
