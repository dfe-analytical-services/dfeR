#' Get clean SQL
#'
#' @description
#' This function cleans a SQL script, ready for using within R in the DfE.
#'
#' @param filepath path to a SQL script
#' @param additional_settings TRUE or FALSE boolean for the addition of
#' settings at the start of the SQL script
#' @return Cleaned string containing SQL query
#' @export
#' @examples
#' # This assumes you have already set up a database connection
#' # and have assigned to 'con'
#'
#' # For more details see [vignette]
#'
#' # Pull a cleaned version of the SQL file into R
#' \dontrun{
#' sql_query <- get_clean_sql("path_to_sql_file.sql")
#' }
#'
#' # Use the cleaned SQL query to query the database
#' \dontrun{
#' dbGetQuery(con, statement = sql_query)
#' }
get_clean_sql <- function(filepath, additional_settings = FALSE) {
  if (!additional_settings %in% c(TRUE, FALSE)) {
    stop(
      "additional_settings must be either TRUE or FALSE"
    )
  }

  # check filepath leads to a SQL file
  if (tolower(tools::file_ext(filepath)) != "sql") {
    stop("filepath must point to a SQL script, with a .sql extension")
  }

  # The file() function will error if the file can't be found
  # Open a connection to the file
  con <- file(filepath, "r")
  sql_string <- ""

  while (TRUE) {
    line <- readLines(con, n = 1)

    if (length(line) == 0) {
      break
    }

    line <- gsub("\\t", " ", line)
    line <- gsub("\\n", " ", line)

    if (grepl("--", line) == TRUE) {
      line <- paste(sub("--", "/*", line), "*/")
    }

    sql_string <- paste(sql_string, line)
  }

  # Close connection to the file
  close(con)

  if (additional_settings == TRUE) {
    # Prefix with settings that sometimes help
    sql_string <- paste(
      "SET ANSI_PADDING OFF",
      "SET NOCOUNT ON;"
    )
  }

  return(sql_string)
}
