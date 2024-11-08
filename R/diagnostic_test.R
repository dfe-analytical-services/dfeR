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
