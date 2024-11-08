#' Diagnostic testing
#'
#' @inheritParams check_proxy_settings
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#' diagnostic_test()
#' }
diagnostic_test <- function(user_input = TRUE) {
  check_proxy_settings(user_input = user_input)
}

#' Check proxy settings
#'
#' @param proxy_setting_names Vector of proxy parameters to check for. Default: c("http.proxy",
#' "https.proxy")
#' @param user_input Ask for user choices on cleaning actions (TRUE / FALSE)
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{
#' check_proxy_settings()
#' }
check_proxy_settings <- function(
    proxy_setting_names = c("http.proxy", "https.proxy"),
    user_input = FALSE) {
  git_config <- git2r::config()
  proxy_config <- git_config |>
    magrittr::extract2("global") |>
    magrittr::extract(proxy_setting_names)
  proxy_config <- purrr::keep(proxy_config, !is.na(names(proxy_config)))
  if (any(!is.na(names(proxy_config)))) {
    message("Found proxy settings:")
    paste(names(proxy_config), "=", proxy_config, collapse = "\n") |>
      message()
    if (user_input) {
      accept <- readline(
        prompt = "Do you wish to remove the proxy settings (Y/n)? "
      )
    } else {
      accept <- TRUE
    }
    if (accept %in% c("Y", "y", "Yes", "yes", "YES", "TRUE", "")) {
      proxy_args <- proxy_config |>
        lapply(function(list) {
          NULL
        })
      rlang::inject(git2r::config(!!!proxy_args, global = TRUE))
      message("Git proxy settings have been cleared.")
    } else {
      message("Git proxy setting have been left in place.")
    }
  } else {
    message("No proxy settings found in your Git configuration.")
  }
  return(proxy_config)
}

#' Check renv download method
#'
#' @return
#' @export
#'
#' @examples
check_renv_download_method <- function(renviron_file = "~/.Renviron", user_input = TRUE) {
  if (file.exists(renviron_file)) {
    .renviron <- readLines(renviron_file)
  } else {
    .renviron <- c()
  }
  rdm_present <- .renviron %>% stringr::str_detect("RENV_DOWNLOAD_METHOD")
  if (any(rdm_present)) {
    message("Found RENV_DOWNLOAD_METHOD in .Renviron:")
    message("   ", .renviron[rdm_present])
    detected_method <- .renviron[rdm_present] |>
      stringr::str_split("=") |>
      unlist() |>
      magrittr::extract(2)
  } else {
    detected_method <- NA
  }
  if (is.na(detected_method) || detected_method != "\"curl\"") {
    message("RENV_DOWNLOAD_METHOD is not set to curl. This may cause issues on DfE systems.")
    message("==============================================================================")
    if (user_input) {
      accept <- readline(prompt = "Do you wish to set the RENV_DOWNLOAD_METHOD in .Renviron (Y/n)? ")
    } else {
      accept <- "n"
    }
    if (accept %in% c("", "Y", "y", "Yes", "YES", TRUE)) {
      if (any(rdm_present)) {
        .renviron <- .renviron[!rdm_present]
      }
      .renviron <- c(
        .renviron,
        "RENV_DOWNLOAD_METHOD=\"curl\""
      )
      print(.renviron)
      cat(.renviron, file = renviron_file, sep = "\n")
      message("The curl download method has automatically been set in your .Renviron file.")
      readRenviron(renviron_file)
    } else {
      message("If you wish to manually update your .Renviron file, follow these steps:")
      message("  - Run the following command in the R console to open the .Renviron file:")
      message("      usethis::edit_r_environ()")
      if (any(rdm_present)) {
        message("  - Remove the following line from .Renviron:")
        message("      ", .renviron[rdm_present])
      }
      message("  - Add the following line to .Renviron:")
      message("      RENV_DOWNLOAD_METHOD=\"curl\"")
    }
  } else {
    message("Your RENV_DOWNLOAD_METHOD checks out as expected.")
  }
}
