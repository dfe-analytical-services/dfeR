#' Diagnostic testing
#'
#' @description
#' Run a set of diagnostic tests to check for common issues found when setting
#' up R on a DfE
#' system. This includes:
#'   - Checking for proxy settings in the Git configuration
#'   - Checking for correct download method used by renv (curl)
#'
#' @inheritParams check_proxy_settings
#'
#' @return List object of detected parameters
#' @export
#'
#' @examples
#' \dontrun{
#' diagnostic_test()
#' }
diagnostic_test <- function(
    clean = FALSE,
    verbose = FALSE) {
  results <- c(
    check_proxy_settings(clean = clean, verbose = verbose),
    check_renv_download_method(clean = clean, verbose = verbose)
  )
  return(results)
}

#' Check proxy settings
#'
#' @description
#' This script checks for "bad" proxy settings. Prior to the pandemic, analysts
#' in the DfE would need to add some proxy settings to their GitHub config.
#' These settings now prevent Git from connecting to remote archives on GitHub
#' and Azure DevOps if present, so this script identifies and (if clean=TRUE is
#' set) removes them.
#'
#' @param proxy_setting_names Vector of proxy parameters to check for. Default:
#' c("http.proxy", "https.proxy")
#' @param clean Attempt to clean settings
#' @param verbose Run in verbose mode
#'
#' @return List of problem proxy settings
#' @export
#'
#' @examples
#' \dontrun{
#' check_proxy_settings()
#' }
check_proxy_settings <- function(
    proxy_setting_names = c("http.proxy", "https.proxy"),
    clean = FALSE,
    verbose = FALSE) {
  git_config <- git2r::config()
  proxy_config <- git_config |>
    magrittr::extract2("global") |>
    magrittr::extract(proxy_setting_names)
  proxy_config <- purrr::keep(proxy_config, !is.na(names(proxy_config)))
  if (any(!is.na(names(proxy_config)))) {
    dfeR::toggle_message("Found proxy settings:", verbose = verbose)
    paste(names(proxy_config), "=", proxy_config, collapse = "\n") |>
      toggle_message(verbose = verbose)
    if (clean) {
      proxy_args <- proxy_config |>
        lapply(function(list) {
          NULL
        })
      rlang::inject(git2r::config(!!!proxy_args, global = TRUE))
      message("FIXED: Git proxy settings have been cleared.")
    } else {
      message("FAIL: Git proxy setting have been left in place.")
    }
  } else {
    message("PASS: No proxy settings found in your Git configuration.")
  }
  return(proxy_config)
}

#' Check renv download method
#'
#' @description
#' The renv package can retrieve packages either using curl or wininet, but
#' wininet doesn't work from within the DfE network. This script checks for
#' the parameter controlling which of these is used (RENV_DOWNLOAD_METHOD) and
#' sets it to use curl.
#'
#' @param renviron_file Location of .Renviron file. Default: ~/.Renviron
#' @inheritParams check_proxy_settings
#'
#' @return List object containing RENV_DOWNLOAD_METHOD
#' @export
#'
#' @examples
#' check_renv_download_method()
check_renv_download_method <- function(
    renviron_file = "~/.Renviron",
    clean = FALSE,
    verbose = FALSE) {
  if (file.exists(renviron_file)) {
    .renviron <- readLines(renviron_file)
  } else {
    .renviron <- c()
  }
  rdm_present <- .renviron %>% stringr::str_detect("RENV_DOWNLOAD_METHOD")
  if (any(rdm_present)) {
    dfeR::toggle_message(
      "Found RENV_DOWNLOAD_METHOD in .Renviron:",
      verbose = verbose
    )
    dfeR::toggle_message("   ", .renviron[rdm_present], verbose = verbose)
    detected_method <- .renviron[rdm_present] |>
      stringr::str_split("=") |>
      unlist() |>
      magrittr::extract(2)
  } else {
    detected_method <- NA
  }
  if (is.na(detected_method) || detected_method != "\"curl\"") {
    if (clean) {
      if (any(rdm_present)) {
        .renviron <- .renviron[!rdm_present]
      }
      .renviron <- c(
        .renviron,
        "RENV_DOWNLOAD_METHOD=\"curl\""
      )
      cat(.renviron, file = renviron_file, sep = "\n")
      message(
        paste0(
          "FIXED: The renv download method has been set to curl in your ",
          ".Renviron file."
        )
      )
      readRenviron(renviron_file)
    } else {
      message("If you wish to manually update your .Renviron file:")
      message("  - Run the command in the R console to open .Renviron:")
      message("      usethis::edit_r_environ()")
      if (any(rdm_present)) {
        message("  - Remove the following line from .Renviron:")
        message("      ", .renviron[rdm_present])
      }
      message("  - Add the following line to .Renviron:")
      message("      RENV_DOWNLOAD_METHOD=\"curl\"")
    }
  } else {
    message("PASS: Your RENV_DOWNLOAD_METHOD is set to curl.")
  }
  return(list(RENV_DOWNLOAD_METHOD = detected_method))
}
