#' Connect to Microsoft SQL Server database using Server and Database name
#'
#' This function allows you to connect to a Microsoft SQL Server database by specifying the
#' Server name and the Database name only.
#'
#' @param server Address of server that database is on. Note \ must be replaced with \\\\
#' @param database Name of database on the server
#' @keywords sql
#' @export

sql_server_connect <- function(server, database){
  # Open connection to database
  RODBC::odbcDriverConnect(
    paste0("driver={SQL Server};server=",server,";database=", database, ";trusted_connection=TRUE")
  )
}

#' Read and Clean SQL script to allow direct querying from R
#'
#' This function allows you to specify an .sql script read a clean version in that can be used with
#' RODBC and other packages to direct query a database.
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

#' Read SQL script and return result set from specified database
#'
#' This function allows you to specify an .sql script and return the result set of this on a specified
#' MS SQL Server database.
#' @param file The .sql file to be used as query
#' @param server Address of server that database is on. Note \ must be replaced with \\\\
#' @param database Name of database on the server
#' @keywords sql
#' @export
#'
run_sql_script <- function(file, server, database){

  # Read in SQL Script
  sqlString <- dfeR::read_sql_script(file)

  # Set up connection to database
  myconn <- dfeR::sql_server_connect(server, database)

  # Store output
  output <- RODBC::sqlQuery(myconn,sqlString)

  # Close connection
  RODBC::odbcClose(myconn)

  # Return Output
  output
}
