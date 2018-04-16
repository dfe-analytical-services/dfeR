#' Create a connection string for a Microsoft SQL database
#'
#' This function allows you to create a trusted connection string to a Microsoft SQL Server database by specifying the
#' Server name and the Database name only. This is the DfE standard.
#'
#' @param server Address of server that database is on. Note \ must be replaced with \\\\
#' @param database Name of database on the server
#' @return Character vector of MSSQL Trusted Connection string
#' @keywords sql
#' @export
#' @examples
#' sql_conn_string("3DCPRI-PDB16\\ACSQLS", "SWFC_Project")

sql_conn_string <- function(server, database){

  if (!is.character(server)) stop("server parmaeter must be of type character")

  if (!is.character(database)) stop("database parmaeter must be of type character")

    paste0("driver={SQL Server};server=",server,";database=", database, ";trusted_connection=TRUE")
}

#' Read and clean a .sql script for use with RODBC
#'
#' This function allows you to read in and clean .sql string that can be used directly with RODBC. \cr\cr
#' It removes statements such as USE and GO, all -- comments and ensures formatting is correct. Without this lots of scripts fail when read in and used with RODBC.
#' @param file The .sql file to be read in
#' @return Character vector of clean sql query
#' @keywords sql
#' @export
#' @examples
#' \dontrun{
#' read_sql_script("Queries/script_name.sql")
#' }

read_sql_script <- function(file) {

  if (!is.character(file)) stop("file parmaeter must be of type character")

  # Read in all lines from file
  sqlLines <- readLines(file)

  # set any use lines to blank
  sqlLines <- gsub("^Use+.*$", "", sqlLines, perl = TRUE, ignore.case = TRUE)

  # set any go lines to blank
  sqlLines <- gsub("^GO+.*$", "", sqlLines, perl = TRUE, ignore.case = TRUE)

  # set any comments lines to blank
  sqlLines <- gsub("--.*", "", sqlLines, perl = TRUE)

  # remove all tabs
  sqlLines <- gsub("\t+", "", sqlLines, perl = TRUE)

  # remove leading whitespace
  sqlLines <- gsub("^\\s+", "", sqlLines, perl = TRUE)

  # remove trailing whitespace
  sqlLines <- gsub("\\s+$", "", sqlLines, perl = TRUE)

  # collapse multiple spaces to a single space
  sqlLines <- gsub("[ ]+", " ", sqlLines, perl = TRUE)

  # Filter out any blank lines
  sqlLines <- Filter(function(x) x != "", sqlLines)

  # Collapse into string
  sqlString <- paste(unlist(sqlLines) ,collapse = " ")

  # Return result
  sqlString

}
