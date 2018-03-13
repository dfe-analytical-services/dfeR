#' Create a connection string for a Microsoft SQL database
#'
#' This function allows you to create a connection string to a Microsoft SQL Server database by specifying the
#' Server name and the Database name only.
#'
#' @param server Address of server that database is on. Note \ must be replaced with \\\\
#' @param database Name of database on the server
#' @keywords sql
#' @export

sql_conn_string <- function(server, database){
    paste0("driver={SQL Server};server=",server,";database=", database, ";trusted_connection=TRUE")
}

#' Read a clean SQL script for use with RODBC
#'
#' This function allows you to read in a clean .sql string that can be used directly with RODBC.
#' @param file The .sql file to be read in
#' @keywords sql
#' @export

read_sql_script <- function(file) {

  # Read in all lines from file
  sqlLines <- readLines(file)

  # set any use lines to blank
  sqlLines <- gsub("^Use+.*$", "", sqlLines, perl = TRUE, ignore.case = TRUE)

  # set any go lines to blank
  sqlLines <- gsub("^GO+.*$", "", sqlLines, perl = TRUE, ignore.case = TRUE)

  # remove all tabs
  sqlLines <- gsub("\t+", "", sqlLines, perl = TRUE)

  # remove leading whitespace
  sqlLines <- gsub("^\\s+", "", sqlLines, perl = TRUE)

  # remove trailing whitespace
  sqlLines <- gsub("\\s+$", "", sqlLines, perl = TRUE)

  # collapse multiple spaces to a single space
  sqlLines <- gsub("[ ]+", " ", sqlLines, perl = TRUE)

  # set any comments lines to blank
  sqlLines <- gsub("^[--]+.*$", "", sqlLines, perl = TRUE)

  # Filter out any blank lines
  sqlLines <- Filter(function(x) x != "", sqlLines)

  # Collapse into string
  sqlString <- paste(unlist(sqlLines) ,collapse = " ")

  # Return result
  sqlString

}
