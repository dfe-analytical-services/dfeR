#' Diagnostic testing
#'
#' @description
#' Run a set of diagnostic tests to check for common issues found when setting
#' up R on a DfE system. The function runs each `check_*()` helper in turn and
#' returns a combined list of detected settings. Problems can optionally be
#' fixed by passing `clean = TRUE`.
#'
#' The checks include:
#'   - Proxy settings in the Git configuration and system environment
#'     (`check_proxy_settings()`)
#'   - Git SSL-verify setting (`check_git_sslverify()`)
#'   - The location of the global `.gitconfig` file
#'     (`check_gitconfig_location()`)
#'   - The `GITHUB_PAT` system variable (`check_github_pat()`)
#'   - renv download method in `.Renviron` (`check_renv_download_method()`)
#'   - The `RENV_DOWNLOAD_FILE_METHOD` system variable
#'     (`check_renv_download_file_method()`)
#'   - Presence of an RTools/`make` toolchain (`check_rtools()`)
#'   - The location of `.Renviron` and `.Rprofile`
#'     (`check_renviron_rprofile_location()`)
#'
#' @param clean If `TRUE`, attempt to clean detected issues. Default `FALSE`.
#' @param verbose If `TRUE`, print extra detail for each check (current values,
#'   manual remediation steps, environment variables). Defaults to `FALSE`,
#'   which keeps PASS output to a single line per check and only shows detail
#'   when something needs the user's attention.
#' @param full If `TRUE`, append a session-dump section after the per-check
#'   output containing `renv::diagnostics()`, `Sys.getenv()` and `options()`.
#'   Useful for sharing a full diagnostic with support. Defaults to `FALSE`.
#'   Note: this output contains unmasked sensitive values such as `GITHUB_PAT`,
#'   so do not paste it into public channels.
#'
#' @return Invisibly, a named list keyed by check (`proxy`, `sslverify`,
#'   `gitconfig`, `github_pat`, `renv_download`, `renv_download_file`,
#'   `rtools`, `renviron_rprofile`). Each entry is the result list returned by
#'   the corresponding `check_*` helper, including a `status` field with one
#'   of `"pass"`, `"fail"`, `"fixed"` or `"info"`.
#' @export
#'
#' @examples
#' \dontrun{
#' diagnostic_test()
#' }
diagnostic_test <- function(
  clean = FALSE,
  verbose = FALSE,
  full = FALSE
) {
  cli::cli_h1("dfeR diagnostics")
  if (full) {
    cli::cli_alert_warning(
      paste(
        "The full dump contains unmasked sensitive values (e.g. GITHUB_PAT).",
        "Do not paste this output into public channels."
      )
    )
  }
  results <- list(
    proxy = check_proxy_settings(clean = clean, verbose = verbose),
    sslverify = check_git_sslverify(clean = clean, verbose = verbose),
    gitconfig = check_gitconfig_location(clean = clean, verbose = verbose),
    github_pat = check_github_pat(clean = clean, verbose = verbose),
    renv_download = check_renv_download_method(
      clean = clean,
      verbose = verbose
    ),
    renv_download_file = check_renv_download_file_method(
      clean = clean,
      verbose = verbose
    ),
    rtools = check_rtools(verbose = verbose),
    renviron_rprofile = check_renviron_rprofile_location(verbose = verbose)
  )
  summarise_diagnostic_results(results)
  if (full) {
    cli::cli_h1("Full diagnostic dump")
    cli::cli_h2("renv::diagnostics()")
    tryCatch(
      cli::cli_verbatim(utils::capture.output(print(renv::diagnostics()))),
      error = function(e) {
        cli::cli_alert_danger(
          "renv::diagnostics() failed: {conditionMessage(e)}"
        )
      }
    )
    cli::cli_h2("Sys.getenv()")
    cli::cli_verbatim(utils::capture.output(print(Sys.getenv())))
    cli::cli_h2("options()")
    cli::cli_verbatim(utils::capture.output(print(options())))
  }
  invisible(results)
}

# Internal helper: render the trailing summary line for diagnostic_test().
summarise_diagnostic_results <- function(results) {
  statuses <- vapply(
    results,
    function(x) if (is.null(x$status)) "info" else x$status,
    character(1)
  )
  n_pass <- sum(statuses == "pass")
  n_fail <- sum(statuses == "fail")
  n_fixed <- sum(statuses == "fixed")
  n_info <- sum(statuses == "info")
  failed_names <- names(results)[statuses == "fail"]
  cli::cli_rule("Summary")
  parts <- c(
    if (n_pass > 0) paste0(n_pass, " PASS"),
    if (n_fixed > 0) paste0(n_fixed, " FIXED"),
    if (n_fail > 0) {
      paste0(
        n_fail,
        " FAIL (",
        paste(failed_names, collapse = ", "),
        ")"
      )
    },
    if (n_info > 0) paste0(n_info, " INFO")
  )
  summary_line <- paste(parts, collapse = ", ")
  if (n_fail > 0) {
    cli::cli_alert_danger(summary_line)
  } else {
    cli::cli_alert_success(summary_line)
  }
  invisible(statuses)
}

#' Check proxy settings
#'
#' @description
#' Prior to the pandemic, analysts in the DfE would need to add proxy settings
#' to either their Git configuration or system environment variables. These
#' settings now prevent Git from connecting to remote archives on GitHub and
#' Azure DevOps, so this function identifies them and (with `clean = TRUE`)
#' removes them.
#'
#' Both the Git configuration (keys `http.proxy`, `https.proxy` by default) and
#' the system environment variables (`http_proxy`, `https_proxy`, `no_proxy` by
#' default) are checked.
#'
#' @param proxy_setting_names Vector of Git-config keys to check for. Default:
#'   `c("http.proxy", "https.proxy")`
#' @param proxy_env_names Vector of system environment variable names to check
#'   for. Default: `c("http_proxy", "https_proxy", "no_proxy")`
#' @param clean Attempt to clean settings.
#' @param verbose Run in verbose mode.
#'
#' @return A list with three slots: `git` (named list of detected Git-config
#'   proxy entries, or `NULL`), `system` (named list of detected
#'   environment-variable proxy entries, or `NULL`) and `status` (one of
#'   `"pass"`, `"fail"` or `"fixed"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_proxy_settings()
#' }
check_proxy_settings <- function(
  proxy_setting_names = c("http.proxy", "https.proxy"),
  proxy_env_names = c("http_proxy", "https_proxy", "no_proxy"),
  clean = FALSE,
  verbose = FALSE
) {
  cli::cli_h2("Proxy settings")
  proxy_settings_detected <- FALSE
  any_cleaned <- FALSE
  any_left <- FALSE
  # Check for proxy settings in the Git configuration
  git_config <- git2r::config()
  proxy_config <- git_config[["global"]][proxy_setting_names]
  proxy_config <- proxy_config[!is.na(names(proxy_config))]
  if (length(proxy_config) > 0) {
    proxy_settings_detected <- TRUE
    if (verbose) {
      cli::cli_text("Found proxy settings in Git config:")
      cli::cli_verbatim(
        paste0("  ", names(proxy_config), " = ", unlist(proxy_config))
      )
    }
    if (clean) {
      proxy_args <- stats::setNames(
        rep(list(NULL), length(proxy_config)),
        names(proxy_config)
      )
      rlang::inject(git2r::config(!!!proxy_args, global = TRUE))
      cli::cli_alert_success("Git proxy settings have been cleared.")
      any_cleaned <- TRUE
    } else {
      cli::cli_alert_danger("Git proxy settings have been left in place.")
      any_left <- TRUE
    }
  } else {
    proxy_config <- NULL
  }
  # Check for proxy-related system environment variables
  proxy_system <- Sys.getenv(proxy_env_names) |>
    as.list()
  proxy_system <- proxy_system[proxy_system != ""]
  if (length(proxy_system) > 0) {
    proxy_settings_detected <- TRUE
    if (verbose) {
      cli::cli_text("Found proxy settings in system environment:")
      cli::cli_verbatim(
        paste0("  ", names(proxy_system), " = ", unlist(proxy_system))
      )
    }
    if (clean) {
      proxy_args <- stats::setNames(
        rep(list(""), length(proxy_system)),
        names(proxy_system)
      )
      rlang::inject(Sys.setenv(!!!proxy_args))
      cli::cli_alert_success(
        "System environment proxy settings have been cleared."
      )
      any_cleaned <- TRUE
    } else {
      cli::cli_alert_danger(
        "System environment proxy settings have been left in place."
      )
      any_left <- TRUE
    }
  } else {
    proxy_system <- NULL
  }
  if (!proxy_settings_detected) {
    cli::cli_alert_success(
      "No proxy settings found in your Git config or system environment."
    )
    status <- "pass"
  } else if (any_left) {
    status <- "fail"
  } else {
    status <- "fixed"
  }
  invisible(list(git = proxy_config, system = proxy_system, status = status))
}

#' Check Git sslverify setting
#'
#' @description
#' Checks the values of the SSL-verify settings in the global Git config. If
#' they're set to `false`, the function flips them back to `TRUE` when called
#' with `clean = TRUE`. By default it checks `http.sslVerify` and
#' `https.sslVerify`.
#'
#' @param ssl_verify_vars Vector of variables to check for in the Git config.
#' @param clean Attempt to clean settings.
#' @param verbose Run in verbose mode.
#'
#' @return List of sslverify settings plus a `status` field
#'   (`"pass"`, `"fail"` or `"fixed"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_git_sslverify()
#' }
check_git_sslverify <- function(
  ssl_verify_vars = c("http.sslverify", "https.sslverify"),
  clean = FALSE,
  verbose = FALSE
) {
  cli::cli_h2("Git sslverify")
  git_config <- git2r::config()[["global"]][ssl_verify_vars]
  git_config <- git_config[!is.na(names(git_config))]
  status <- "pass"
  if (length(git_config) > 0) {
    if (verbose) {
      cli::cli_text("Found specified settings in Git config:")
      cli::cli_verbatim(
        paste0("  ", names(git_config), " = ", unlist(git_config))
      )
    }
    if (any(tolower(git_config) == "false")) {
      if (clean) {
        to_fix <- git_config[tolower(git_config) == "false"]
        git_args <- stats::setNames(
          rep(list("true"), length(to_fix)),
          names(to_fix)
        )
        rlang::inject(git2r::config(!!!git_args, global = TRUE))
        cli::cli_alert_success("sslverify has been set back to true.")
        status <- "fixed"
      } else {
        cli::cli_alert_danger(
          "sslverify is set to FALSE. Setting has been left in place."
        )
        status <- "fail"
      }
    } else {
      cli::cli_alert_success("sslverify is set to TRUE.")
    }
  } else {
    git_config <- NULL
    cli::cli_alert_success("sslverify is not explicitly set.")
  }
  invisible(list(ssl_verify = git_config, status = status))
}

#' Check the location of the global .gitconfig file
#'
#' @description
#' Reports the location Git is using for its global config file. R, RStudio,
#' and the system Git can disagree on this location (e.g. when `HOME` is
#' redirected into OneDrive). The function flags non-standard locations and
#' prints the resolved path so users can sanity-check it against the file they
#' think they are editing.
#'
#' @param clean Currently has no effect. Reserved for future use so the
#'   function signature matches the other `check_*` helpers.
#' @param verbose Run in verbose mode.
#'
#' @return List object containing `gitconfig_path` (or `NA` if none found)
#'   plus a `status` field (`"info"` or `"fail"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_gitconfig_location()
#' }
check_gitconfig_location <- function(
  clean = FALSE,
  verbose = FALSE
) {
  cli::cli_h2("Global .gitconfig location")
  git_path <- Sys.which("git")
  if (!nzchar(git_path)) {
    cli::cli_alert_info(
      "git was not found on PATH. Cannot determine .gitconfig location."
    )
    return(invisible(list(gitconfig_path = NA_character_, status = "info")))
  }
  # Shell out to git (rather than git2r) because we need --show-origin to find
  # which file git actually parsed, and git2r::config() does not expose that.
  output <- suppressWarnings(
    system2(
      "git",
      c("config", "--global", "--list", "--show-origin"),
      stdout = TRUE,
      stderr = TRUE
    )
  )
  origin_lines <- grep("^file:", output, value = TRUE)
  if (length(origin_lines) == 0) {
    cli::cli_alert_info(
      "No entries found in your global .gitconfig (Git could not locate one)."
    )
    return(invisible(list(gitconfig_path = NA_character_, status = "info")))
  }
  path <- origin_lines[1] |>
    sub(pattern = "^file:", replacement = "") |>
    sub(pattern = "\\s.*$", replacement = "")
  status <- "info"
  if (grepl("OneDrive", path, ignore.case = TRUE)) {
    cli::cli_alert_danger(
      paste0(
        "Your global .gitconfig is inside OneDrive ({path}). This often ",
        "causes Git, R, and RStudio to disagree on which config is in ",
        "effect. We recommend moving it to the standard location: ",
        "{.path C:/Users/<username>/.gitconfig}"
      )
    )
    status <- "fail"
  } else if (verbose) {
    cli::cli_text("Global .gitconfig is at: {.path {path}}")
  }
  if (status == "info") {
    cli::cli_alert_info("Global .gitconfig is in a standard location.")
  }
  if (verbose) {
    cli::cli_text("All --show-origin entries:")
    cli::cli_verbatim(output)
  }
  invisible(list(gitconfig_path = path, status = status))
}

#' Check GITHUB_PAT setting
#'
#' @description
#' If the `GITHUB_PAT` system variable is set, it can cause issues with R
#' installing packages from GitHub (usually with an error of
#' "ERROR \[curl: (22) The requested URL returned error: 401\]"). This function
#' checks whether the variable is set and (with `clean = TRUE`) clears it for
#' the current R session.
#'
#' The function masks the PAT value when reporting - only its length and last
#' four characters are shown - but the value itself is still in the returned
#' list, so callers should be careful when sharing the return value.
#'
#' @inheritParams check_proxy_settings
#'
#' @return List object containing `GITHUB_PAT` plus a `status` field
#'   (`"pass"`, `"fail"` or `"fixed"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_github_pat()
#' }
check_github_pat <- function(
  clean = FALSE,
  verbose = FALSE
) {
  cli::cli_h2("GITHUB_PAT")
  github_pat <- Sys.getenv("GITHUB_PAT")
  if (github_pat != "") {
    masked <- if (nchar(github_pat) > 4) {
      paste0(
        "...",
        substr(github_pat, nchar(github_pat) - 3, nchar(github_pat))
      )
    } else {
      "..."
    }
    cli::cli_alert_danger(
      paste0(
        "GITHUB_PAT is set (length ",
        nchar(github_pat),
        ", ending ",
        masked,
        "). This may cause issues with installing packages from GitHub ",
        "such as dfeR and dfeshiny. The GITHUB_PAT value is sensitive - ",
        "do not share it."
      )
    )
    if (clean) {
      Sys.unsetenv("GITHUB_PAT")
      cli::cli_alert_success(
        "GITHUB_PAT has been cleared from the current R session."
      )
      if (verbose) {
        cli::cli_text(
          paste(
            "This issue may recur if you have software that initialises the",
            "GITHUB_PAT keyword automatically."
          )
        )
      }
      status <- "fixed"
    } else {
      status <- "fail"
    }
  } else {
    cli::cli_alert_success("The GITHUB_PAT system variable is clear.")
    status <- "pass"
  }
  invisible(list(GITHUB_PAT = github_pat, status = status))
}

#' Check renv download method
#'
#' @description
#' The renv package can retrieve packages either using `curl` or `wininet`, but
#' `wininet` doesn't work from within the DfE network. This function checks
#' for the parameter controlling which of these is used
#' (`RENV_DOWNLOAD_METHOD`) in the user's `.Renviron` and sets it to `curl`
#' when called with `clean = TRUE`.
#'
#' @param renviron_file Location of `.Renviron` file. Default: `~/.Renviron`
#' @inheritParams check_proxy_settings
#'
#' @return List object containing `RENV_DOWNLOAD_METHOD` (with surrounding
#'   whitespace and any wrapping quotes stripped, or `NA` if the variable is
#'   not set) plus a `status` field (`"pass"`, `"fail"` or `"fixed"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_renv_download_method()
#' }
check_renv_download_method <- function(
  renviron_file = "~/.Renviron",
  clean = FALSE,
  verbose = FALSE
) {
  cli::cli_h2("renv download method")
  if (file.exists(renviron_file)) {
    .renviron <- readLines(renviron_file)
  } else {
    .renviron <- c()
  }
  rdm_present <- .renviron |> stringr::str_detect("RENV_DOWNLOAD_METHOD")
  if (any(rdm_present)) {
    current_value <- .renviron[rdm_present]
    detected_method <- current_value |>
      sub(pattern = "^[^=]*=\\s*", replacement = "") |>
      trimws() |>
      sub(pattern = '^"(.*)"$', replacement = "\\1") |>
      sub(pattern = "^'(.*)'$", replacement = "\\1")
  } else {
    current_value <- character()
    detected_method <- NA
  }
  if (is.na(detected_method) || detected_method != "curl") {
    if (clean) {
      if (any(rdm_present)) {
        .renviron <- .renviron[!rdm_present]
      }
      .renviron <- c(
        .renviron,
        "RENV_DOWNLOAD_METHOD=\"curl\""
      )
      cat(.renviron, file = renviron_file, sep = "\n")
      cli::cli_alert_success(
        "The renv download method has been set to curl in your .Renviron."
      )
      readRenviron(renviron_file)
      status <- "fixed"
    } else {
      if (any(rdm_present)) {
        cli::cli_alert_danger(
          "RENV_DOWNLOAD_METHOD is currently set to: {current_value}"
        )
      } else {
        cli::cli_alert_danger("RENV_DOWNLOAD_METHOD is not currently set.")
      }
      if (verbose) {
        cli::cli_text("To manually update your .Renviron file:")
        cli::cli_ul()
        cli::cli_li("Run {.code usethis::edit_r_environ()} in the R console.")
        if (any(rdm_present)) {
          cli::cli_li(
            paste0(
              "Remove the following line from .Renviron: ",
              "{.code {current_value}}"
            )
          )
        }
        cli::cli_li(
          "Add the following line to .Renviron: {.code RENV_DOWNLOAD_METHOD=\"curl\"}"
        )
        cli::cli_end()
        cli::cli_text(
          "Or run {.code dfeR::check_renv_download_method(clean = TRUE)}."
        )
      }
      status <- "fail"
    }
  } else {
    cli::cli_alert_success("Your RENV_DOWNLOAD_METHOD is set to curl.")
    status <- "pass"
  }
  invisible(list(RENV_DOWNLOAD_METHOD = detected_method, status = status))
}

#' Check RENV_DOWNLOAD_FILE_METHOD system variable
#'
#' @description
#' The legacy `proxy.R` script used `setx RENV_DOWNLOAD_FILE_METHOD wininet` to
#' route renv downloads through Windows wininet. This breaks renv outside the
#' DfE network and is no longer needed. This function checks the
#' `RENV_DOWNLOAD_FILE_METHOD` system environment variable and (with
#' `clean = TRUE`) unsets it for the current R session.
#'
#' Removing the variable for the current R session does not undo a permanent
#' Windows `setx` registry entry. If the variable was set permanently the
#' function prints instructions for clearing it from the user's environment.
#'
#' @inheritParams check_proxy_settings
#'
#' @return List object containing `RENV_DOWNLOAD_FILE_METHOD` plus a `status`
#'   field (`"pass"`, `"fail"` or `"fixed"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_renv_download_file_method()
#' }
check_renv_download_file_method <- function(
  clean = FALSE,
  verbose = FALSE
) {
  cli::cli_h2("RENV_DOWNLOAD_FILE_METHOD")
  rdfm <- Sys.getenv("RENV_DOWNLOAD_FILE_METHOD")
  if (rdfm == "") {
    cli::cli_alert_success("RENV_DOWNLOAD_FILE_METHOD is not set.")
    status <- "pass"
  } else if (tolower(rdfm) == "wininet") {
    cli::cli_alert_danger(
      paste0(
        "RENV_DOWNLOAD_FILE_METHOD is set to '",
        rdfm,
        "'. This breaks renv outside the DfE network."
      )
    )
    if (clean) {
      Sys.unsetenv("RENV_DOWNLOAD_FILE_METHOD")
      cli::cli_alert_success(
        "RENV_DOWNLOAD_FILE_METHOD has been unset for the current R session."
      )
      if (verbose) {
        cli::cli_text(
          paste(
            "If the variable was set permanently via {.code setx}, also run",
            "this in a Windows terminal to remove it permanently:"
          )
        )
        cli::cli_verbatim("    setx RENV_DOWNLOAD_FILE_METHOD \"\"")
      }
      status <- "fixed"
    } else {
      status <- "fail"
    }
  } else {
    if (verbose) {
      cli::cli_text(
        paste0(
          "RENV_DOWNLOAD_FILE_METHOD is set to '",
          rdfm,
          "'. This is unusual but not necessarily a problem."
        )
      )
    }
    cli::cli_alert_success("RENV_DOWNLOAD_FILE_METHOD is not set to wininet.")
    status <- "pass"
  }
  invisible(list(RENV_DOWNLOAD_FILE_METHOD = rdfm, status = status))
}

#' Check for an RTools / make toolchain
#'
#' @description
#' Some R packages require compilation, which on Windows means RTools must be
#' installed and on `PATH`. This function checks whether `make` is available
#' via `Sys.which("make")`. It does not attempt to install RTools.
#'
#' @param verbose Run in verbose mode.
#'
#' @return List object containing `rtools_make_path` plus a `status` field
#'   (`"pass"` or `"fail"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_rtools()
#' }
check_rtools <- function(verbose = FALSE) {
  cli::cli_h2("RTools / make toolchain")
  make_path <- unname(Sys.which("make"))
  if (nzchar(make_path)) {
    cli::cli_alert_success("Found 'make' at {.path {make_path}}.")
    status <- "pass"
  } else {
    cli::cli_alert_danger(
      paste(
        "'make' was not found on PATH. On Windows this usually means RTools",
        "is not installed. Install it from",
        "{.url https://cran.r-project.org/bin/windows/Rtools/}."
      )
    )
    status <- "fail"
  }
  if (verbose) {
    cli::cli_text("Sys.which('make') = '{make_path}'")
  }
  invisible(list(rtools_make_path = make_path, status = status))
}

#' Check the location of .Renviron and .Rprofile
#'
#' @description
#' Reports the resolved paths and existence of the user-level `.Renviron` and
#' `.Rprofile` files, plus the values of `HOME`, `R_USER` and
#' `path.expand("~")`. This is useful for diagnosing situations where R is
#' reading these files from a different location than expected (for example a
#' OneDrive-redirected home folder).
#'
#' The path lines are only printed when a file is missing, when the home
#' directory is OneDrive-redirected, or when `verbose = TRUE`.
#'
#' @param verbose Run in verbose mode.
#'
#' @return List object containing the resolved paths, existence flags,
#'   relevant environment variables and a `status` field (`"info"` or
#'   `"fail"`).
#' @export
#'
#' @examples
#' \dontrun{
#' check_renviron_rprofile_location()
#' }
check_renviron_rprofile_location <- function(verbose = FALSE) {
  cli::cli_h2(".Renviron / .Rprofile location")
  renviron_path <- normalizePath("~/.Renviron", mustWork = FALSE)
  rprofile_path <- normalizePath("~/.Rprofile", mustWork = FALSE)
  renviron_exists <- file.exists(renviron_path)
  rprofile_exists <- file.exists(rprofile_path)
  home <- Sys.getenv("HOME")
  r_user <- Sys.getenv("R_USER")
  tilde <- path.expand("~")
  onedrive <- grepl("OneDrive", tilde, ignore.case = TRUE)
  any_missing <- !renviron_exists || !rprofile_exists
  show_paths <- any_missing || onedrive || verbose
  if (show_paths) {
    cli::cli_text(
      ".Renviron: {.path {renviron_path}} ({if (renviron_exists) 'exists' else 'missing'})"
    )
    cli::cli_text(
      ".Rprofile: {.path {rprofile_path}} ({if (rprofile_exists) 'exists' else 'missing'})"
    )
  }
  if (verbose) {
    cli::cli_text("HOME = '{home}'")
    cli::cli_text("R_USER = '{r_user}'")
    cli::cli_text("path.expand('~') = '{tilde}'")
  }
  if (onedrive) {
    cli::cli_alert_danger(
      paste(
        "Your home directory is inside OneDrive. R, RStudio and Git may",
        "resolve '~' inconsistently in that case."
      )
    )
    status <- "fail"
  } else {
    cli::cli_alert_info(
      ".Renviron and .Rprofile locations resolve outside of OneDrive."
    )
    status <- "info"
  }
  invisible(list(
    renviron_path = renviron_path,
    renviron_exists = renviron_exists,
    rprofile_path = rprofile_path,
    rprofile_exists = rprofile_exists,
    HOME = home,
    R_USER = r_user,
    tilde = tilde,
    status = status
  ))
}
