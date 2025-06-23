#' Air Install
#'
#' @description checks for air installation status and installs it if
#' required, updating the global settings if selected
#'
#' @param update_global_settings auto update global settings, or don't
#' @param verbose Run in verbose mode
#'
#' @export
#'
#' @examples
#' \dontrun{
#' air_install()
#' }

air_install <- function(update_global_settings = FALSE, verbose = TRUE) {
  platform <- Sys.info()[1]

  if (platform == "Windows") {
    air_executable <- "air.exe"
    user_home <- Sys.getenv("USERPROFILE")
  } else {
    air_executable <- "air"
    user_home <- Sys.getenv("HOME")
  }

  if (verbose) {
    toggle_message(
      "Looking for",
      air_executable,
      "in",
      user_home,
      "/.local/bin/",
      verbose = verbose
    )
  }

  # Check for air and settings
  if (file.exists(paste0(user_home, "/.local/bin/", air_executable))) {
    toggle_message("Air is already installed on your system", verbose = verbose)
  } else {
    toggle_message(
      "Air does not appear to be installed, installing now",
      verbose = TRUE
    )
    if (platform == "Windows") {
      system(
        paste0(
          "powershell -ExecutionPolicy Bypass ",
          "-c \"irm ",
          "https://github.com/posit-dev/air/releases/latest/download/",
          "air-installer.ps1",
          " | iex\""
        )
      )
    } else {
      system(
        paste0(
          "curl -LsSf ",
          "https://github.com/posit-dev/air/releases/latest/download/",
          "air-installer.sh ",
          "| sh"
        )
      )
    }
  }
  if (update_global_settings == TRUE) {
    warning(
      "Updating global RStudio settings to use Air and reformat scripts on",
      "save. You can turn this off from Tools > global options > Code > Saving",
      "Note that Air currently mis-formats yaml scripts, so reformatting on",
      "save should be avoided if you work with yaml."
    )
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
    toggle_message(
      "Expecting air executable to be in ",
      air_path,
      verbose = verbose
    )
  }

  # check air is installed
  if (file.exists(air_path)) {
    toggle_message("Found Air executable, running Air...", verbose = verbose)
    if (file.exists(target)) {
      system(
        paste0(air_path, " format ", target)
      )
      toggle_message("Styled file(s) at ", target, verbose = verbose)
    } else {
      stop(
        paste0("Target file ", target, " does not exist")
      )
    }
  } else {
    toggle_message(
      "Air does not appear to be installed on your system.\n",
      "Run install_air() before formatting again",
      verbose = verbose
    )
  }
}
