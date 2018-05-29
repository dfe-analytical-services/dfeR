#' Function to create a blank shiny app in a folder of your choice.
#'
#' The folder and app_name arguments combine to produce a shiny app in folder/app_name/
#' @export
#' @param folder The parent folder of the shiny app
#' @param app_dir The app directory
#' @param data_connections Logical, should yml files for data connections be created
#' @param sql_queries Logical, should a SQL/ folder be created to hold .sql files
#' @param csv_data Logical, should a CSV/ folder be created to hold .csv files
#' @param css_style Logical, should a custom.css file be created
new_dfe_shiny_app <- function(folder = tempdir(),
                              app_dir = "New Shiny App",
                              data_connections = TRUE,
                              sql_queries = TRUE,
                              csv_data = TRUE,
                              css_style = TRUE) {

  app_folder <- file.path(folder, app_dir)
  if (!dir.exists(app_folder)) dir.create(app_folder)

  app_files <- c("global.R", "ui.R", "server.R")
  app_files <- file.path(app_folder, app_files[!file.exists(app_files)])

  file.create(app_files)

  www_dir <- file.path(app_folder, "www/")
  if (!dir.exists(www_dir)) dir.create(www_dir)

  if (data_connections) {
    yml_files <- c("config.yml", "rodbc.yml")
    yml_files <- file.path(app_folder, yml_files[!file.exists(yml_files)])
    file.create(yml_files)
  }

  if (sql_queries) {
    sql_dir <- file.path(app_folder, "SQL/")
    if (!dir.exists(sql_dir)) dir.create(sql_dir)
  }

  if (csv_data) {
    csv_dir <- file.path(app_folder, "CSV/")
    if (!dir.exists(csv_dir)) dir.create(csv_dir)
  }

  if (css_style) {
    css_file <- file.path(app_folder, "custom.css")
    if (!file.exists(css_file)) file.create(css_file)
  }

  writeLines(text = c(paste("# This is the global script of", app_dir), "",
                      "# Use library commands here to load packages",
                      "library(shiny)", "",
                      "#This script is where all your data loading and wrangling should be done, prior to your app being launched."),
             con = file.path(app_folder, "global.R"))

  writeLines(text = c(paste("# This is the ui script of", app_dir), "",
                      "# This script should create a user interface for your app.",
                      "ui <- fluidPage(", "",
                      "# This is where your inputs and outputs are placed", "",
                      ")"),
             con = file.path(app_folder, "ui.R"))

  writeLines(text = c(paste("# This is the server script of", app_dir), "",
                      "# This script should create a back-end for your app.",
                      "server <- function(input, output, session){", "",
                      "# This is where your app workings are placed, and your outputs are defined", "\n",
                      "}"),
             con = file.path(app_folder, "server.R"))

  if (data_connections) {

    writeLines(text = c("default:", "  rodbc: ./rodbc.yml", "",
                        "production:", "  rodbc: /etc/rodbc.yml"),
               con = file.path(app_folder, "config.yml"))

    writeLines(text = c("app_code:",
                        '  driver: "SQL Server Native Client 11.0',
                        '  server: "your/server/name/here"',
                        '  database: "your/database/name/here"',
                        '  uid: ""',
                        '  pwd: ""',
                        '  trusted: "yes"'),
               con = file.path(app_folder, "rodbc.yml"))

    global <- readLines(file.path(app_folder, "global.R"))
    writeLines(text = c(global, "# Use the following to create a connection string for your SQL queries.", "\n",
                        "library(RODBC)",
                        "config <- config::get()",
                        "odbc_conf <- yaml::yaml.load_file(config$rodbc)$app_code",
                        'connection_string <- paste0("Driver={", odbc_conf$driver,',
                        '                            "};Server={", odbc_conf$server,',
                        '                            "};Database={", odbc_conf$database,',
                        '                            "};UID={", odbc_conf$uid,',
                        '                            "};PWD={", odbc_conf$pwd,',
                        '                            "};Trusted_Connection={", odbc_conf$trusted,',
                        '                            "}")'),
               con = file.path(app_folder, "global.R"))

  }

}
