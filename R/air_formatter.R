#' Air Install
#'
#' @description checks for air installation status and installs it if
#' required, updating the global settings if selected
#'
#' @param update_global_settings auto update global settings, or don't
#' @param verbose Run in verbose mode
#'
#' @importFrom data.table like
#' @export
#'
#' @examples
#' \dontrun{
#' air_install()
#' }

air_install <- function(update_global_settings = TRUE, verbose = FALSE) {
  platform <- Sys.info()[1]

  if (platform == "Windows") {
    air_executable <- "air.exe"
    user_home <- Sys.getenv("USERPROFILE")
  } else {
    air_executable <- "air"
    user_home <- Sys.getenv("HOME")
  }

  if (verbose) {
    message("Looking for", air_executable, "in", user_home, "/.local/bin/")
  }

  # Check for air and settings - need package data.table to do this
  if (file.exists(paste0(user_home, "/.local/bin/", air_executable))) {
    message("Air is already installed on your system")
  } else {
    message("Air does not appear to be installed, installing now")
    if (platform == "Windows") {
      system(
        paste(
          "powershell -ExecutionPolicy Bypass",
          "-c \"irm https://github.com/posit-dev/air/releases/latest/download/air-installer.ps1",
          " | iex\""
        )
      )
    } else {
      system(
        paste(
          "curl -LsSf ",
          "https://github.com/posit-dev/air/releases/latest/download/air-installer.sh",
          "| sh"
        )
      )
    }
  }
  if (update_global_settings == TRUE) {
    rstudio.prefs::use_rstudio_prefs(
      code_formatter = "external",
      code_formatter_external_command = paste0(
        user_home,
        "\\.local\\bin\\",
        air_executable,
        " format "
      ),
      reformat_on_save = TRUE
    )
  }
}

#' Air - style code in scripts
#'
#' @description styles the whole project or single file using air
#'
#' @param target single file target for formatting
#' @param verbose Run in verbose mode
#'
#' @export
#'
#' @examples
#' \dontrun{
#' air_style()
#' }
air_style <- function(target = ".", verbose = FALSE) {
  platform <- Sys.info()[1]

  if (platform == "Windows") {
    air_executable <- "air.exe"
    user_home <- Sys.getenv("USERPROFILE")
  } else {
    air_executable <- "air"
    user_home <- Sys.getenv("HOME")
  }

  air_path <- paste0(user_home, "/.local/bin/", air_executable)
  if (verbose) {
    message("Expecting air executable to be in", air_path)
  }

  # check air is installed
  if (file.exists(air_path)) {
    if (file.exists(target)) {
      system(
        paste0(air_path, " format ", target)
      )
    } else {
      message(paste0("Target file ", target, " does not exist"))
    }
  } else {
    message(
      "Air does not appear to be installed on your system.\n",
      "Run install_air() before formatting again"
    )
  }
  return(NULL)
}
