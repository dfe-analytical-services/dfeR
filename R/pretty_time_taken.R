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
#' @family prettying functions
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
