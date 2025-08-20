# Helper function for mocking the odbc package in tests.
# See the "Namespaced Calls" section in the testthat documentation:
# https://testthat.r-lib.org/reference/local_mocked_bindings.html
get_odbc_version <- function() {
  utils::packageVersion("odbc")
}

#' Check Databricks ODBC connection variables
#'
#' Checks if the required environment variables for connecting to
#' Databricks are set, and if the `odbc` package version is sufficient.
#'
#' Prints instructions for fixing common problems to the console.
#' @export
#' @return TRUE if the connection is set up correctly, FALSE otherwise.
#' @examples
#' check_databricks_odbc()
check_databricks_odbc <- function() {
  # odbc::databricks is introduced in odbc 1.4.0
  if (get_odbc_version() < "1.4.0") {
    cli::cli_alert_danger(
      "The odbc::databricks() function is not available
      in your version of the odbc package.
      \n \n
      Please update your packages by running:
      \n \n
      {.code devtools::update_packages().} "
    )
    return(invisible(FALSE))
  }

  required_vars <- c(
    "DATABRICKS_TOKEN",
    "DATABRICKS_HOST",
    "DATABRICKS_SQL_PATH"
  )

  missing_vars <- character()

  for (var in required_vars) {
    # Sys.getenv() returns "" for unset variables
    if (nchar(Sys.getenv(var)) == 0) {
      missing_vars <- c(missing_vars, var)
    }
  }

  if (length(missing_vars) > 0) {
    cli::cli_alert_danger(
      paste0(
        "The following environment variables are missing: \n \n",
        paste0("{.file ", missing_vars, "}", collapse = ", \n"),
        "\n \n"
      )
    )
    cli::cli_ul(
      "Please set them in your {.file .Renviron} file
      or in your Windows account environment variables.
      Follow the instructions on the linked DfE Analyst guide below: \n
      {.url https://shorturl.at/SCHru }"
    )
    return(invisible(FALSE))
  }

  # Check for invisible non-ASCII characters.
  # These sometimes appear when copying from PowerPoint or Teams.
  for (var in required_vars) {
    if (stringr::str_detect(Sys.getenv(var), "[^\\x00-\\x7F]")) {
      cli::cli_alert_danger(paste0(
        "The environment variable ",
        var,
        " contains non-ASCII characters.
        Please remove any invisible characters, by pasting the variable
        in again directly from the Databricks website."
      ))
      return(invisible(FALSE))
    }
  }

  cli::cli_alert_success("Your Databricks connection is set up correctly.")
  cli::cli_alert_info(
    "You should be able to connect to Databricks using this code: \n"
  )

  # Verbatim preserves line breaks and tabs
  cli::cli_verbatim(
    '
  con <- DBI::dbConnect(
    odbc::databricks(),
    httpPath = Sys.getenv("DATABRICKS_SQL_PATH")
  )

  tbl(
    con,
    I("catalog_10_gold.conformed_dimensions.dim_postcode_geography")
  )'
  )

  invisible(TRUE)
}
