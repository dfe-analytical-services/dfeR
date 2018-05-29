# ============================================================================ #
# global.R - data loading, wrangling and global variables for your app
# ============================================================================ #

# This script is where all your data loading and wrangling should be done, prior
# to your app being launched. Any objects you create with <- here are usable in
# both ui.R and server.R

# Packages ----------------------------------------------------------------

# Use library() to load in packages you need for your app
library(shiny)

# Data wrangling - dplyr and other tidyverse packages are HIGHLY recommended.

library(dplyr)

# Data Connections
library(RODBC)

# dfeR

library(dfeR)

# Data Connections --------------------------------------------------------

# Use the following to create a database connection string from the config.yml
# and rodbc.yml files. This is required if you inted to publish your app on the
# internal DfE RSConnect Servers.

config <- config::get()
odbc_conf <- yaml::yaml.load_file(config$rodbc)$app_code
connection_string <- paste0("Driver={", odbc_conf$driver,
                            "};Server={", odbc_conf$server,
                            "};Database={", odbc_conf$database,
                            "};UID={", odbc_conf$uid,
                            "};PWD={", odbc_conf$pwd,
                            "};Trusted_Connection={", odbc_conf$trusted,
                            "}")

# Data Loading ------------------------------------------------------------

# Here, you should read in any raw data you need, with the `read_csv()` function,
# or by reading in SQL queries, and using your `connection_string` above to connect
# to a database.

# Data:
# my_csv_data <- read_csv("Data/filename.csv")

# Queries:
# my_connection <- odbcDriverConnect(connection_string)
# my_query <- read_sql_script("SQL/filename.sql")
# my_sql_data <- sqlQuery(my_connection, my_query, stringsAsFactors = FALSE)
# odbcClose(my_connection)

# Data Wrangling ----------------------------------------------------------

# This is where you should do any transformations you need, such as creating
# calculated columns, filtering, sorting and merging data.
