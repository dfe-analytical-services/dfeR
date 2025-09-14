# Helper function for mocking the odbc package in tests.
# See the "Namespaced Calls" section in the testthat documentation:
# https://testthat.r-lib.org/reference/local_mocked_bindings.html
get_odbc_version <- function() {
  utils::packageVersion("odbc")
}

#' Check odbc package version for Databricks compatibility
#'
#' Extracted into own function to lower the cyclomatic complexity of
#' check_databricks_odbc(). This hushes the lintr warnings.
#'
#' @param odbc_version A character string or version object representing the installed `odbc` package version,
#'   or `NA` if the package is not installed.
#'
#' @keywords internal
#' @noRd
check_odbc_version <- function(odbc_version) {
  # Exit gracefully if odbc is not installed
  if (is.na(odbc_version)) {
    cli::cli_abort(
      "The {.pkg odbc} package is not installed.
    \n
    Please install it by running:
    \n
    {.code install.packages('odbc')}"
    )
    return(invisible(FALSE))
  }

  # odbc::databricks is introduced in odbc 1.4.0
  if (odbc_version < "1.4.0") {
    cli::cli_abort(
      "The odbc::databricks() function is not available
      in your version of the odbc package.
      \n \n
      Please update your packages by running:
      \n \n
      {.code devtools::update_packages().} "
    )
    return(invisible(FALSE))
  }
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
#' if(interactive()){
#'   check_databricks_odbc()
#' }
check_databricks_odbc <- function() {
  odbc_version <- tryCatch(
    get_odbc_version(),
    error = function(e) NA
  )

  check_odbc_version(odbc_version)

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
