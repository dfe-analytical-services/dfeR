#' Minimum supported Air version
#'
#' @description Air 0.10.0 changed the default `assignment-style` to
#' `"arrow"`, which affects the styled output that [air_style()] produces.
#' Versions of Air older than this will silently produce different (older)
#' formatting.
#'
#' @keywords internal
dfer_min_air_version <- "0.10.0"

#' Get the installed Air version
#'
#' @description returns the installed Air version as a
#' [numeric_version()], or `NA` if Air is not installed or its version
#' cannot be determined.
#'
#' @param air_path path to the air executable
#'
#' @keywords internal
get_air_version <- function(air_path) {
  if (!file.exists(air_path)) {
    return(NA)
  }

  version_output <- tryCatch(
    system(paste0(shQuote(air_path), " --version"), intern = TRUE),
    warning = function(w) NA_character_,
    error = function(e) NA_character_
  )

  version_string <- regmatches(
    version_output,
    regexpr("[0-9]+\\.[0-9]+\\.[0-9]+", version_output)
  )

  if (length(version_string) == 0 || identical(version_string, "")) {
    return(NA)
  }

  numeric_version(version_string[1])
}

#' Air Install
#'
#' @description checks for air installation status and installs it if
#' required (or if the installed version is older than the minimum
#' supported version), updating the global settings if selected
#'
#' @param update_rstudio_settings auto update RStudio settings
#' @param verbose Run in verbose mode
#' @param force force (re)installation of Air, even if an up to date
#' version is already installed
#'
#' @export
#'
#' @examples
#' \dontrun{
#' air_install()
#' }

air_install <- function(
  update_rstudio_settings = FALSE,
  verbose = TRUE,
  force = FALSE
) {
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
      "Looking for",
      air_executable,
      "in",
      user_home,
      "/.local/bin/",
      verbose = verbose
    )
  }

  installed_version <- get_air_version(air_path)
  needs_install <- force ||
    is.na(installed_version) ||
    installed_version < numeric_version(dfer_min_air_version)

  # Check for air and settings
  if (!needs_install) {
    toggle_message("Air is already installed on your system", verbose = verbose)
  } else {
    if (!force && !is.na(installed_version)) {
      toggle_message(
        "Installed Air version (",
        as.character(installed_version),
        ") is older than the minimum supported version (",
        dfer_min_air_version,
        "), reinstalling now",
        verbose = TRUE
      )
    } else {
      toggle_message(
        "Air does not appear to be installed, installing now",
        verbose = TRUE
      )
    }
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
  if (update_rstudio_settings == TRUE) {
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
    stop(
      "Air does not appear to be installed on your system.\n",
      "Run dfeR::install_air() before formatting again."
    )
  }
}
