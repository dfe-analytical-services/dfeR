#' Pretty numbers into readable file size
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
#' @family prettying
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

#' Calculate elapsed time between two points and present prettily
#'
#' @description
#' Converts a start and end value to a readable time format.
#'
#' @details
#' Designed to be used with Sys.time() when tracking start and end times.
#'
#' Shows as seconds up until 119 seconds, then minutes until 119 minutes,
#' then hours for anything larger.
#'
#' Input start and end times must be convertible to POSIXct format.
#' @param start_time start time readable by as.POSIXct
#' @param end_time end time readable by as.POSIXct
#' @return string containing prettified elapsed time
#' @family prettying
#' @seealso [comma_sep()] [round_five_up()] [as.POSIXct()]
#' @export
#' @examples
#' pretty_time_taken(
#'   "2024-03-23 07:05:53 GMT",
#'   "2024-03-23 12:09:56 GMT"
#' )
#'
#' # Track the start and end time of a process
#' start <- Sys.time()
#' Sys.sleep(0.1)
#' end <- Sys.time()
#'
#' # Use this function to present it prettily
#' pretty_time_taken(start, end)
pretty_time_taken <- function(start_time, end_time) {
  # Convert start and end times to seconds since 1970
  tryCatch(
    {
      start_secs <- as.numeric(
        difftime(
          time1 = as.POSIXct(start_time, tz = "UTC"),
          time2 = as.POSIXct("1970-01-01", tz = "UTC"),
          units = "secs"
        )
      )
    },
    error = function(msg) {
      stop("start and end times must be convertible to POSIXct format")
    }
  )

  tryCatch(
    {
      end_secs <- as.numeric(
        difftime(
          time1 = as.POSIXct(end_time, tz = "UTC"),
          time2 = as.POSIXct("1970-01-01", tz = "UTC"),
          units = "secs"
        )
      )
    },
    error = function(msg) {
      stop("start and end times must be convertable to POSIXct format")
    }
  )

  # Find the elapsed time in seconds
  raw_time <- round_five_up(end_secs - start_secs, 2)

  # Format elapsed time neatly
  # This section could be broken into its own function
  # ...that takes in raw seconds
  if (raw_time < 120) {
    if (raw_time == 1) {
      return("1 second")
    } else {
      return(paste0(raw_time, " seconds"))
    }
  } else {
    if (raw_time < 7140) {
      mins <- raw_time %/% 60
      secs <- round_five_up(raw_time %% 60)

      min_desc <- ifelse(mins == 1, " minute ", " minutes ")
      sec_desc <- ifelse(secs == 1, " second", " seconds")

      return(
        paste0(
          mins, min_desc, secs, sec_desc
        )
      )
    } else {
      hours <- raw_time %/% 3600
      mins <- raw_time %/% 60 - hours * 60
      secs <- round_five_up(raw_time %% 60)

      hour_desc <- ifelse(hours == 1, " hour ", " hours ")
      min_desc <- ifelse(mins == 1, " minute ", " minutes ")
      sec_desc <- ifelse(secs == 1, " second", " seconds")

      return(
        paste0(
          comma_sep(hours), hour_desc, mins, min_desc, secs, sec_desc
        )
      )
    }
  }
}

#' Prettify big numbers into a readable format
#'
#' @description
#' Uses `as.numeric()` to force a numeric value and then formats prettily
#' for easy presentation in console messages, reports, or dashboards.
#'
#' This rounds to 0 decimal places by default, and adds in comma separators.
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
#' @param dp number of decimal places to round to, 0 by default.
#' @param ignore_na whether to skip function for strings that can't be
#' converted and return original value
#' @param alt_na alternative value to return in place of NA, e.g. "x"
#' @param nsmall minimum number of digits to the right of the decimal point.
#' If NULL, the value of `dp` will be used.
#' If the value of `dp` is less than 0, then `nsmall` will
#' automatically be set to 0.
#'
#' @return string featuring prettified value
#' @family prettying
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
#' pretty_num(43.3, dp = 1, nsmall = 2)
#' pretty_num("56.089", suffix = "%")
#' pretty_num("x")
#' pretty_num("x", ignore_na = TRUE)
#' pretty_num("nope", alt_na = "x")
#'
#' # Applied over an example vector
#' vector <- c(3998098008, -123421421, "c", "x")
#' pretty_num(vector)
#' pretty_num(vector, prefix = "+/-", gbp = TRUE)
#'
#' # Return original values if NA
#' pretty_num(vector, ignore_na = TRUE)
#'
#' # Return alternative value in place of NA
#' pretty_num(vector, alt_na = "z")
pretty_num <- function(
    value,
    prefix = "",
    gbp = FALSE,
    suffix = "",
    dp = 0,
    ignore_na = FALSE,
    alt_na = FALSE,
    nsmall = NULL) {
  # use lapply to use the function for singular value or a vector

  result <- lapply(value, function(value) {
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


    # If nsmall is not given, make same value as dp
    # if dp is smaller than 0, make nsmall 0
    # if nsmall is specified, use that value

    if (!is.null(nsmall)) {
      nsmall <- nsmall
    } else if (dp > 0 & is.null(nsmall)) {
      nsmall <- dp
    } else {
      nsmall <- 0
    }


    if (abs(num_value) >= 1.e9) {
      paste0(
        prefix,
        currency,
        comma_sep(round_five_up(abs(num_value) / 1.e9, dp = dp),
          nsmall = nsmall
        ),
        " billion",
        suffix
      )
    } else if (abs(num_value) >= 1.e6) {
      paste0(
        prefix,
        currency,
        comma_sep(round_five_up(abs(num_value) / 1.e6, dp = dp),
          nsmall = nsmall
        ),
        " million",
        suffix
      )
    } else {
      paste0(
        prefix,
        currency,
        comma_sep(round_five_up(abs(num_value), dp = dp),
          nsmall = nsmall
        ),
        suffix
      )
    }
  }) # lapply bracket

  # unlisting the results so that they're all on one line
  return(unlist(result))
}

#' Format a data frame with `dfeR::pretty_num()`.
#'
#' You can format number and character values in a data frame
#' by passing arguments to `dfeR::pretty_num()`.
#' Use parameters `include_columns` or `exclude_columns`
#' to specify columns for formatting.
#'
#' @param data A data frame containing the columns to be formatted.
#' @param include_columns A character vector specifying which columns to format.
#' If `NULL` (default), all columns will be considered for formatting.
#' @param exclude_columns A character vector specifying columns to exclude
#' from formatting.
#' If `NULL` (default), no columns will be excluded.
#' If both `include_columns` and `exclude_columns` are provided
#' , `include_columns` takes precedence.
#' @param ... Additional arguments passed to `dfeR::pretty_num()`
#' , such as `dp` (decimal places)
#' for controlling the number of decimal points.
#'
#' @return A data frame with columns formatted using `dfeR::pretty_num()`.
#'
#' @details
#' The function first checks if any columns are specified for inclusion
#' via `include_columns`.
#' If none are provided, it checks if columns are specified for exclusion
#' via `exclude_columns`.
#' If neither is specified, all columns in the data frame are formatted.
#' @family prettying
#' @seealso [pretty_num()]
#' @export
#' @examples
#' # Example data frame
#' df <- data.frame(
#'   a = c(1.234, 5.678, 9.1011),
#'   b = c(10.1112, 20.1314, 30.1516),
#'   c = c("A", "B", "C")
#' )
#'
#' # Apply formatting to all columns
#' pretty_num_table(df, dp = 2)
#'
#' # Apply formatting to only selected columns
#' pretty_num_table(df, include_columns = c("a"), dp = 2)
#'
#' # Apply formatting to all columns except specified ones
#' pretty_num_table(df, exclude_columns = c("b"), dp = 2)
#'
#' # Apply formatting to all columns except specified ones and
#' # provide alternative value for NAs
#' pretty_num_table(df, alt_na = "[z]", exclude_columns = c("b"), dp = 2)
#'
pretty_num_table <- function(data,
                             include_columns = NULL,
                             exclude_columns = NULL,
                             ...) {
  # Check data is a data frame and throw error if not
  if (!is.data.frame(data)) {
    stop(paste0(
      "Data has the class ", class(data),
      ", data must be a data.frame object"
    ))
  }

  # Check if the data frame has rows - if not, stop the process
  if (nrow(data) < 1) {
    stop("Data frame is empty or contains no rows.")
  }

  # Determine which columns to include based on the provided parameters

  # if the include_columns arg is specified
  if (!is.null(include_columns)) {
    # assign the names to the cols_to_include variable
    cols_to_include <- include_columns

    # if the exclude_columns arg is specified
  } else if (!is.null(exclude_columns)) {
    # we assign the cols_to_include to names of all columns
    # except for ones specified in exclude_columns
    cols_to_include <- setdiff(
      names(data),
      exclude_columns
    )
  } else {
    # if none of the previous conditions are met
    # all columns are assigned to cols_to_include
    cols_to_include <- names(data)
  }

  # Apply pretty_num() formatting to the selected columns
  data %>%
    dplyr::mutate(dplyr::across(
      .cols = dplyr::all_of(cols_to_include),
      ~ pretty_num(., ...)
    ))
}
