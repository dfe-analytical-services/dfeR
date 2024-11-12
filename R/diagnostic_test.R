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
#' diagnostic_test()
diagnostic_test <- function(
    clean = FALSE,
    verbose = FALSE) {
  results <- c(
    check_proxy_settings(clean = clean, verbose = verbose),
    check_github_pat(clean = clean, verbose = verbose),
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
#' check_proxy_settings()
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
    proxy_config <- as.list(rep("", length(proxy_setting_names))) |>
      stats::setNames(proxy_setting_names)
  }
  return(proxy_config)
}

#' Check GITHUB_PAT setting
#'
#' @description
#' If the GITHUB_PAT keyword is set, then it can cause issues with R installing
#' packages from GitHub (usually with an error of "ERROR \[curl: (22) The
#' requested URL returned error: 401\]"). This script checks whether the keyword
#' is set and can then clear it (if clear=TRUE).
#' The user will then need to identify where the "GITHUB_PAT" variable is being
#' set from and remove it to permanently fix the issue.
#'
#' @inheritParams check_proxy_settings
#'
#' @return List object containing the github_pat keyword content.
#' @export
#'
#' @examples
#' check_github_pat()
check_github_pat <- function(clean = FALSE,
                             verbose = FALSE) {
  github_pat <- Sys.getenv("GITHUB_PAT") |>
    stringr::str_replace_all(stringr::regex("\\W+"), "")
  # Replace above to remove non alphanumeric characters when run on GitHub
  # Actions
  print(github_pat)
  if(github_pat == "***"){print("Found *** GITHUB_PAT")}
  cat("==================================")
  if (github_pat != "") {
    message(
      "FAIL: GITHUB_PAT is set to ",
      github_pat,
      ". This may cause issues with installing packages from GitHub",
      " such as dfeR and dfeshiny."
    )
    if (clean) {
      message("Clearing GITHUB_PAT keyword from system settings.")
      Sys.unsetenv("GITHUB_PAT")
      message(
        "This issue may recur if you have some software that is",
        "initialising the GITHUB_PAT keyword automatically."
      )
    }
  } else {
    message("PASS: The GITHUB_PAT system variable is clear.")
  }
  return(list(GITHUB_PAT = github_pat))
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
    current_setting_message <- paste0(
      "RENV_DOWNLOAD_METHOD is currently set to:\n   ",
      .renviron[rdm_present]
    )
    detected_method <- .renviron[rdm_present] |>
      stringr::str_split("=") |>
      unlist() |>
      magrittr::extract(2)
  } else {
    current_setting_message <- "RENV_DOWNLOAD_METHOD is not currently set."
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
      dfeR::toggle_message(paste("FAIL:", current_setting_message),
        verbose = verbose
      )
      message("If you wish to manually update your .Renviron file:")
      message("  - Run the command in the R console to open .Renviron:")
      message("      usethis::edit_r_environ()")
      if (any(rdm_present)) {
        message("  - Remove the following line from .Renviron:")
        message("      ", .renviron[rdm_present])
      }
      message("  - Add the following line to .Renviron:")
      message("      RENV_DOWNLOAD_METHOD=\"curl\"")
      message("Or run `dfeR::check_renv_download_method(clean=TRUE)`")
    }
  } else {
    message("PASS: Your RENV_DOWNLOAD_METHOD is set to curl.")
  }
  return(list(RENV_DOWNLOAD_METHOD = detected_method))
}
