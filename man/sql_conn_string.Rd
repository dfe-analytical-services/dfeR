% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/loading_data.R
\name{sql_conn_string}
\alias{sql_conn_string}
\title{Create a connection string for a Microsoft SQL database}
\usage{
sql_conn_string(server, database)
}
\arguments{
\item{server}{Address of server that database is on. Note \ must be replaced with \\\\}

\item{database}{Name of database on the server}
}
\value{
Character vector of MSSQL Trusted Connection string
}
\description{
This function allows you to create a trusted connection string to a Microsoft SQL Server database by specifying the
Server name and the Database name only. This is the DfE standard.
}
\examples{
sql_conn_string("3DCPRI-PDB16\\\\ACSQLS", "SWFC_Project")
}
\keyword{sql}
