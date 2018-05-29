#' Function to create a blank shiny app in a folder of your choice.
#'
#' The folder and app_name arguments combine to produce a shiny app in folder/app_name/
#' @export
#' @param folder The parent folder of the shiny app
#' @param app_name The app directory name
#' @param app_type Should the app be a 'fluidPage' or a 'dashboardPage' structure
#' @param sql_queries Logical, should a SQL/ folder be created to hold .sql files
#' @param csv_data Logical, should a CSV/ folder be created to hold .csv files
#' @param css_style Logical, should a custom.css file be created
new_dfe_shiny_app <- function(folder = tempdir(),
                              app_name = "New Shiny App",
                              app_type = "fluid",
                              sql_queries = TRUE,
                              csv_data = TRUE,
                              css_style = TRUE) {

  if (!(app_type %in% c("fluid", "dashboard")))
    stop("app_type must be 'fluid' or 'dashboard'")

  app_folder <- file.path(folder, app_name)
  if (dir.exists(app_folder)) {
    app_folder <- paste0(app_folder, "_COPY_", round(runif(1, 1000, 9999)))
  }
  dir.create(app_folder)

  app_files <- c("global.R", "ui.R", "server.R", "config.yml", "rodbc.yml")

  app_files_to_copy <- system.file("shiny", app_type, app_files, package = "dfeR")
  destinations <- file.path(app_folder, app_files)

  file.copy(from = app_files_to_copy,
            to = destinations,
            overwrite = TRUE)

  www_dir <- file.path(app_folder, "www/")
  if (!dir.exists(www_dir)) dir.create(www_dir)

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

}
