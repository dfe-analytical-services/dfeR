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
#' Some of the output (e.g. the value of `GITHUB_PAT`) may be sensitive. Do not
#' paste the full output of this function into public channels.
#'
#' @param clean If `TRUE`, attempt to clean detected issues. Default `FALSE`.
#' @param verbose If `TRUE`, print extra information about detected settings.
#' @param full If `TRUE`, after running the per-check output also print
#'   `renv::diagnostics()`, `Sys.getenv()` and `options()`. Default `FALSE`.
#'
#' @return Invisibly, a named list keyed by check (`proxy`, `sslverify`,
#'   `gitconfig`, `github_pat`, `renv_download`, `renv_download_file`,
#'   `rtools`, `renviron_rprofile`). Each entry is the result list returned by
#'   the corresponding `check_*` helper.
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
  message(
    "Note: some of the output below may be sensitive (e.g. GITHUB_PAT). ",
    "Do not paste the full output of this function into public channels."
  )
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
  if (full) {
    message("--- Full diagnostic dump ---")
    message("renv::diagnostics():")
    tryCatch(
      print(renv::diagnostics()),
      error = function(e) {
        message("  renv::diagnostics() failed: ", conditionMessage(e))
      }
    )
    message("Sys.getenv():")
    print(Sys.getenv())
    message("options():")
    print(options())
  }
  invisible(results)
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
#' @return A list with two slots: `git` (named list of detected Git-config
#'   proxy entries, or `NULL`) and `system` (named list of detected
#'   environment-variable proxy entries, or `NULL`).
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
  proxy_settings_detected <- FALSE
  # Check for proxy settings in the Git configuration
  git_config <- git2r::config()
  proxy_config <- git_config[["global"]][proxy_setting_names]
  proxy_config <- proxy_config[!is.na(names(proxy_config))]
  if (length(proxy_config) > 0) {
    toggle_message(
      "Found proxy settings in Git config:",
      verbose = verbose
    )
    paste(names(proxy_config), "=", proxy_config, collapse = "\n") |>
      toggle_message(verbose = verbose)
    proxy_settings_detected <- TRUE
    if (clean) {
      proxy_args <- stats::setNames(
        rep(list(NULL), length(proxy_config)),
        names(proxy_config)
      )
      rlang::inject(git2r::config(!!!proxy_args, global = TRUE))
      message("FIXED: Git proxy settings have been cleared.")
    } else {
      message("FAIL: Git proxy setting have been left in place.")
    }
  } else {
    proxy_config <- NULL
  }
  # Check for proxy-related system environment variables
  proxy_system <- Sys.getenv(proxy_env_names) |>
    as.list()
  proxy_system <- proxy_system[proxy_system != ""]
  if (length(proxy_system) > 0) {
    toggle_message(
      "Found proxy settings in system environment:",
      verbose = verbose
    )
    paste(names(proxy_system), "=", proxy_system, collapse = "\n") |>
      toggle_message(verbose = verbose)
    proxy_settings_detected <- TRUE
    if (clean) {
      proxy_args <- stats::setNames(
        rep(list(""), length(proxy_system)),
        names(proxy_system)
      )
      rlang::inject(Sys.setenv(!!!proxy_args))
      message("FIXED: System environment proxy settings have been cleared.")
    } else {
      message(
        "FAIL: System environment proxy settings have been left in place."
      )
    }
  } else {
    proxy_system <- NULL
  }
  if (!proxy_settings_detected) {
    message(
      "PASS: No proxy settings found in your Git config or system environment."
    )
  }
  invisible(list(git = proxy_config, system = proxy_system))
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
#' @return List of sslverify settings.
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
  git_config <- git2r::config()[["global"]][ssl_verify_vars]
  git_config <- git_config[!is.na(names(git_config))]
  if (length(git_config) > 0) {
    toggle_message(
      "Found specified settings in Git config:",
      verbose = verbose
    )
    paste(names(git_config), "=", git_config, collapse = "\n") |>
      toggle_message(verbose = verbose)
    if (any(tolower(git_config) == "false")) {
      if (clean) {
        to_fix <- git_config[tolower(git_config) == "false"]
        git_args <- stats::setNames(
          rep(list("true"), length(to_fix)),
          names(to_fix)
        )
        rlang::inject(git2r::config(!!!git_args, global = TRUE))
        message("FIXED: Specified Git settings have been set")
      } else {
        message("FAIL: sslverify is set to FALSE.")
        message("Specified Git settings have been left in place.")
      }
    } else {
      message("PASS: sslverify is set to TRUE.")
    }
  } else {
    git_config <- NULL
    message("PASS: sslverify is not explicitly set.")
  }
  invisible(list(ssl_verify = git_config))
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
#' @return List object containing `gitconfig_path` (or `NA` if none found).
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
  git_path <- Sys.which("git")
  if (!nzchar(git_path)) {
    message(
      "FAIL: git was not found on PATH. Cannot determine .gitconfig location."
    )
    return(invisible(list(gitconfig_path = NA_character_)))
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
    message(
      "PASS: No entries found in your global .gitconfig (Git could not ",
      "locate one)."
    )
    return(invisible(list(gitconfig_path = NA_character_)))
  }
  path <- origin_lines[1] |>
    sub(pattern = "^file:", replacement = "") |>
    sub(pattern = "\\s.*$", replacement = "")
  message("Global .gitconfig is at: ", path)
  flagged <- FALSE
  if (grepl("OneDrive", path, ignore.case = TRUE)) {
    message(
      "FAIL: Your global .gitconfig is inside OneDrive (",
      path,
      "). ",
      "This often causes Git, R, and RStudio to disagree on which config ",
      "is in effect. We recommend moving it to the standard location:"
    )
    message("    C:/Users/<username>/.gitconfig")
    flagged <- TRUE
  }
  if (!flagged) {
    message("PASS: Global .gitconfig is in a standard location.")
  }
  toggle_message(
    paste(c("All --show-origin entries:", output), collapse = "\n"),
    verbose = verbose
  )
  invisible(list(gitconfig_path = path))
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
#' @return List object containing `GITHUB_PAT`.
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
    message(
      "FAIL: GITHUB_PAT is set (length ",
      nchar(github_pat),
      ", ending ",
      masked,
      "). This may cause issues with installing ",
      "packages from GitHub such as dfeR and dfeshiny."
    )
    message("Note: the GITHUB_PAT value is sensitive - do not share it.")
    if (clean) {
      message("Clearing GITHUB_PAT keyword from system settings.")
      Sys.unsetenv("GITHUB_PAT")
      message(
        "This issue may recur if you have some software that is ",
        "initialising the GITHUB_PAT keyword automatically."
      )
    }
  } else {
    message("PASS: The GITHUB_PAT system variable is clear.")
  }
  invisible(list(GITHUB_PAT = github_pat))
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
#' @return List object containing `RENV_DOWNLOAD_METHOD` — the value parsed
#'   from `.Renviron` with surrounding whitespace and any wrapping single or
#'   double quotes stripped, or `NA` if the variable is not set.
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
  if (file.exists(renviron_file)) {
    .renviron <- readLines(renviron_file)
  } else {
    .renviron <- c()
  }
  rdm_present <- .renviron |> stringr::str_detect("RENV_DOWNLOAD_METHOD")
  if (any(rdm_present)) {
    current_setting_message <- paste0(
      "RENV_DOWNLOAD_METHOD is currently set to:\n   ",
      .renviron[rdm_present]
    )
    detected_method <- .renviron[rdm_present] |>
      sub(pattern = "^[^=]*=\\s*", replacement = "") |>
      trimws() |>
      sub(pattern = '^"(.*)"$', replacement = "\\1") |>
      sub(pattern = "^'(.*)'$", replacement = "\\1")
  } else {
    current_setting_message <- "RENV_DOWNLOAD_METHOD is not currently set."
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
      message(
        "FIXED: The renv download method has been set to curl in your ",
        ".Renviron file."
      )
      readRenviron(renviron_file)
    } else {
      toggle_message(paste("FAIL:", current_setting_message), verbose = verbose)
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
  invisible(list(RENV_DOWNLOAD_METHOD = detected_method))
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
#' @return List object containing `RENV_DOWNLOAD_FILE_METHOD`.
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
  rdfm <- Sys.getenv("RENV_DOWNLOAD_FILE_METHOD")
  if (rdfm == "") {
    message("PASS: RENV_DOWNLOAD_FILE_METHOD is not set.")
  } else if (tolower(rdfm) == "wininet") {
    message(
      "FAIL: RENV_DOWNLOAD_FILE_METHOD is set to '",
      rdfm,
      "'. This breaks renv outside the DfE network."
    )
    if (clean) {
      Sys.unsetenv("RENV_DOWNLOAD_FILE_METHOD")
      message(
        "FIXED: RENV_DOWNLOAD_FILE_METHOD has been unset for the current ",
        "R session."
      )
      message(
        "If the variable was set permanently via `setx`, also run this in ",
        "a Windows terminal to remove it permanently:"
      )
      message("    setx RENV_DOWNLOAD_FILE_METHOD \"\"")
    }
  } else {
    toggle_message(
      paste0(
        "RENV_DOWNLOAD_FILE_METHOD is set to '",
        rdfm,
        "'. This is unusual but not necessarily a problem."
      ),
      verbose = verbose
    )
    message("PASS: RENV_DOWNLOAD_FILE_METHOD is not set to wininet.")
  }
  invisible(list(RENV_DOWNLOAD_FILE_METHOD = rdfm))
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
#' @return List object containing `rtools_make_path`.
#' @export
#'
#' @examples
#' \dontrun{
#' check_rtools()
#' }
check_rtools <- function(verbose = FALSE) {
  make_path <- unname(Sys.which("make"))
  if (nzchar(make_path)) {
    message("PASS: Found 'make' at ", make_path)
  } else {
    message(
      "FAIL: 'make' was not found on PATH. On Windows this usually means ",
      "RTools is not installed. Install it from ",
      "https://cran.r-project.org/bin/windows/Rtools/"
    )
  }
  toggle_message(
    paste0("Sys.which('make') = '", make_path, "'"),
    verbose = verbose
  )
  invisible(list(rtools_make_path = make_path))
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
#' @param verbose Run in verbose mode.
#'
#' @return List object containing the resolved paths, existence flags and
#'   relevant environment variables.
#' @export
#'
#' @examples
#' \dontrun{
#' check_renviron_rprofile_location()
#' }
check_renviron_rprofile_location <- function(verbose = FALSE) {
  renviron_path <- normalizePath("~/.Renviron", mustWork = FALSE)
  rprofile_path <- normalizePath("~/.Rprofile", mustWork = FALSE)
  renviron_exists <- file.exists(renviron_path)
  rprofile_exists <- file.exists(rprofile_path)
  home <- Sys.getenv("HOME")
  r_user <- Sys.getenv("R_USER")
  tilde <- path.expand("~")
  message(
    ".Renviron: ",
    renviron_path,
    " (",
    if (renviron_exists) "exists" else "missing",
    ")"
  )
  message(
    ".Rprofile: ",
    rprofile_path,
    " (",
    if (rprofile_exists) "exists" else "missing",
    ")"
  )
  toggle_message(paste0("HOME = '", home, "'"), verbose = verbose)
  toggle_message(paste0("R_USER = '", r_user, "'"), verbose = verbose)
  toggle_message(paste0("path.expand('~') = '", tilde, "'"), verbose = verbose)
  if (grepl("OneDrive", tilde, ignore.case = TRUE)) {
    message(
      "Note: your home directory is inside OneDrive. R, RStudio and Git ",
      "may resolve '~' inconsistently in that case."
    )
  }
  invisible(list(
    renviron_path = renviron_path,
    renviron_exists = renviron_exists,
    rprofile_path = rprofile_path,
    rprofile_exists = rprofile_exists,
    HOME = home,
    R_USER = r_user,
    tilde = tilde
  ))
}
