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

# vignette potential?

#' # Pull a cleaned version of the SQL file into R
#' sql_query <- get_clean_sql("path_to_sql_file.sql")
#'
#' # Use the cleaned SQL query to query the database
#' \dontrun{dbGetQuery(con, statement = sql_query)}

get_clean_sql <- function(filepath, additional_settings = FALSE) {

  # check that additional_settings is always NULL or TRUE

  # check filepath can be found and is a SQL file?


  con <- file(filepath, "r")
  sql.string <- ""

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

    sql.string <- paste(sql.string, line)
  }

  close(con)

  if(is.null(additional_settings)){
    # clean up SQL - remove weird sign that appears sometimes
    sql.string <- gsub("ï»¿", " ", sql.string)

  } else if (additional_settings == TRUE){
    # Clean SQL and prefix with settings that sometimes help
    sql.string <- paste(
      "SET ANSI_PADDING OFF",
      "SET NOCOUNT ON;",
      gsub("ï»¿", " ", sql.string)
      )
  }

  return(sql.string)
}
