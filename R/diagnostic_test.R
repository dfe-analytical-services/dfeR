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
#'     (`check_renv_dl_file_method()`)
#'   - Presence of an RTools/`make` toolchain (`check_rtools()`)
#'   - The location of `.Renviron` and `.Rprofile`
#'     (`check_renv_rprof_location()`)
#'
#' @inheritParams diagnostic_params
#' @param full If `TRUE`, append a session-dump section after the per-check
#'   output containing `renv::diagnostics()`, `Sys.getenv()` and `options()`.
#'   Useful for sharing a full diagnostic with support. Defaults to `FALSE`.
#'   Note: this output contains unmasked sensitive values such as `GITHUB_PAT`,
#'   so do not paste it into public channels.
#'
#' @inherit diagnostic_params details
#' @return Invisibly, a named list keyed by check (`proxy`, `sslverify`,
#'   `gitconfig`, `github_pat`, `renv_download`, `renv_download_file`,
#'   `rtools`, `renviron_rprofile`). Each entry is the result list returned by
#'   the corresponding `check_*` helper, plus a `status` field.
#' @export
#'
#' @examples
#' \dontrun{
#' diagnostic_test()
#' }
diagnostic_test <- function(
  clean = FALSE,
  full = FALSE
) {
  cli::cli_h1("dfeR diagnostics")
  if (full) {
    cli::cli_alert_warning(
      paste(
        "The full dump may contain unmasked sensitive values",
        "(e.g. GITHUB_PAT). Do not paste this output into public channels."
      )
    )
  }
  results <- list(
    proxy = check_proxy_settings(clean = clean),
    sslverify = check_git_sslverify(clean = clean),
    gitconfig = check_gitconfig_location(),
    github_pat = check_github_pat(clean = clean),
    renv_download = check_renv_download_method(clean = clean),
    renv_download_file = check_renv_dl_file_method(clean = clean),
    rtools = check_rtools(),
    renviron_rprofile = check_renv_rprof_location()
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
    cli::cli_verbatim(
      utils::capture.output(print(mask_sensitive_env(Sys.getenv())))
    )
    cli::cli_h2("options()")
    cli::cli_verbatim(utils::capture.output(print(options())))
  }
  invisible(results)
}

# Internal helper: read selected keys from `git config --global --list`.
# Returns a named list of character values for keys present, in the order
# requested. Keys not present in the global config are omitted. Later
# assignments overwrite earlier ones, matching git's own resolution.
git_config_get_global <- function(keys) {
  if (!nzchar(Sys.which("git"))) {
    return(list())
  }
  out <- suppressWarnings(
    system2(
      "git",
      c("config", "--global", "--list"),
      stdout = TRUE,
      stderr = FALSE
    )
  )
  if (length(out) == 0) {
    return(list())
  }
  eq <- regexpr("=", out, fixed = TRUE)
  has_eq <- eq > 0
  out <- out[has_eq]
  eq <- eq[has_eq]
  names <- substr(out, 1, eq - 1)
  values <- substr(out, eq + 1, nchar(out))
  full <- stats::setNames(as.list(values), names)
  matched <- intersect(keys, names(full))
  full[matched]
}

# Internal helper: set or unset a single key in the global git config.
# `value = NULL` unsets the key (no-op if absent).
git_config_set_global <- function(key, value) {
  if (is.null(value)) {
    suppressWarnings(
      system2(
        "git",
        c("config", "--global", "--unset-all", key),
        stdout = FALSE,
        stderr = FALSE
      )
    )
  } else {
    system2(
      "git",
      c("config", "--global", key, value),
      stdout = FALSE,
      stderr = FALSE
    )
  }
  invisible(NULL)
}

# Internal helper: permanently clear a Windows User environment variable by
# setting it to an empty string with setx. No-op (returns FALSE) on
# non-Windows systems, where there is no equivalent persistent store to clear.
# setx only affects new processes, so callers should also Sys.unsetenv() to
# clear the value from the current session. Returns TRUE when setx was run.
#
# Note: setx sets the value to "" rather than deleting the registry key, so the
# variable still exists (empty) in the user environment. This is deliberate:
# Sys.getenv() treats "" as unset, so it is functionally equivalent and avoids
# a `reg delete /F` that manipulates the registry directly.
setx_clear <- function(var) {
  if (.Platform$OS.type != "windows") {
    return(FALSE)
  }
  suppressWarnings(
    system2("setx", c(var, '""'), stdout = FALSE, stderr = FALSE)
  )
  TRUE
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
  cli::cli_text("")
  cli::cli_rule("Summary")
  cli::cli_text("")
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
#' On Windows, `clean = TRUE` clears the matching environment variables
#' permanently from your user environment (via `setx`) as well as from the
#' current R session, so they do not come back the next time you start R.
#' Windows only applies the change to new processes, so close and reopen
#' RStudio afterwards.
#'
#' @param proxy_setting_names Vector of Git-config keys to check for. Default:
#'   `c("http.proxy", "https.proxy")`
#' @param proxy_env_names Vector of system environment variable names to check
#'   for. Default: `c("http_proxy", "https_proxy", "no_proxy")`
#' @inheritParams diagnostic_params
#'
#' @inherit diagnostic_params details
#' @return A list with three slots: `git` (named list of detected Git-config
#'   proxy entries, or `NULL`), `system` (named list of detected
#'   environment-variable proxy entries, or `NULL`) and a `status` field.
#' @export
#'
#' @examples
#' \dontrun{
#' check_proxy_settings()
#' }
check_proxy_settings <- function(
  proxy_setting_names = c("http.proxy", "https.proxy"),
  proxy_env_names = c("http_proxy", "https_proxy", "no_proxy"),
  clean = FALSE
) {
  cli::cli_h2("Proxy settings")
  proxy_settings_detected <- FALSE
  any_left <- FALSE
  # Check for proxy settings in the Git configuration
  proxy_config <- git_config_get_global(proxy_setting_names)
  if (length(proxy_config) > 0) {
    proxy_settings_detected <- TRUE
    if (clean) {
      for (key in names(proxy_config)) {
        git_config_set_global(key, NULL)
      }
      cli::cli_alert_success("Git proxy settings have been cleared.")
    } else {
      cli::cli_alert_danger("Git proxy settings have been left in place.")
      any_left <- TRUE
    }
  } else {
    proxy_config <- NULL
  }
  # Check for proxy-related system environment variables.
  # Sys.getenv() returns "" for both unset and empty-string proxies; treating
  # them the same is fine for the proxy use case.
  proxy_system <- Sys.getenv(proxy_env_names) |>
    as.list()
  proxy_system <- proxy_system[proxy_system != ""]
  if (length(proxy_system) > 0) {
    proxy_settings_detected <- TRUE
    if (clean) {
      Sys.unsetenv(names(proxy_system))
      permanent <- FALSE
      for (var in names(proxy_system)) {
        permanent <- setx_clear(var) || permanent
      }
      if (permanent) {
        cli::cli_alert_success(
          paste(
            "System environment proxy settings have been cleared for this R",
            "session and permanently in your Windows user environment."
          )
        )
      } else {
        cli::cli_alert_success(
          "System environment proxy settings have been cleared."
        )
      }
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
#' @inheritParams diagnostic_params
#'
#' @inherit diagnostic_params details
#' @return List of sslverify settings plus a `status` field.
#' @export
#'
#' @examples
#' \dontrun{
#' check_git_sslverify()
#' }
check_git_sslverify <- function(
  ssl_verify_vars = c("http.sslverify", "https.sslverify"),
  clean = FALSE
) {
  cli::cli_h2("Git sslverify")
  git_config <- git_config_get_global(ssl_verify_vars)
  status <- "pass"
  if (length(git_config) > 0) {
    if (any(tolower(unlist(git_config)) == "false")) {
      if (clean) {
        to_fix <- git_config[tolower(unlist(git_config)) == "false"]
        for (key in names(to_fix)) {
          git_config_set_global(key, "true")
        }
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
#' @inherit diagnostic_params details
#' @return List object containing `gitconfig_path` (or `NA` if none found)
#'   plus a `status` field.
#' @export
#'
#' @examples
#' \dontrun{
#' check_gitconfig_location()
#' }
check_gitconfig_location <- function() {
  cli::cli_h2("Global .gitconfig location")
  git_path <- Sys.which("git")
  if (!nzchar(git_path)) {
    cli::cli_alert_info(
      "git was not found on PATH. Cannot determine .gitconfig location."
    )
    return(invisible(list(gitconfig_path = NA_character_, status = "info")))
  }
  # --show-origin tells us which file git actually parsed.
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

  if (grepl("OneDrive", path, ignore.case = TRUE)) {
    cli::cli_alert_danger(
      c(
        "Your global .gitconfig is inside OneDrive ({.path {path}}). ",
        "This often causes Git, R, and RStudio to disagree on which config ",
        "is in effect. We recommend moving it to the standard location: ",
        "{.path C:/Users/<username>/.gitconfig}"
      )
    )
    status <- "fail"
  } else {
    cli::cli_alert_success("Global .gitconfig is in a standard location.")
    status <- "pass"
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
#' The function masks the PAT value both in console output and in the returned
#' list (only its length and last four characters are shown). The raw value is
#' never returned, so it is safe to share the result of `diagnostic_test()`.
#'
#' @inheritParams diagnostic_params
#'
#' @inherit diagnostic_params details
#' @return List object containing `GITHUB_PAT` (masked: empty string when
#'   unset, otherwise `"..."` followed by the last four characters) plus a
#'   `status` field.
#' @export
#'
#' @examples
#' \dontrun{
#' check_github_pat()
#' }
check_github_pat <- function(
  clean = FALSE
) {
  cli::cli_h2("GITHUB_PAT")
  github_pat <- Sys.getenv("GITHUB_PAT")
  masked <- mask_github_pat(github_pat)
  if (github_pat != "") {
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
      cli::cli_text(
        paste(
          "This issue may recur if you have software that initialises the",
          "GITHUB_PAT keyword automatically."
        )
      )
      status <- "fixed"
    } else {
      status <- "fail"
    }
  } else {
    cli::cli_alert_success("The GITHUB_PAT system variable is clear.")
    status <- "pass"
  }
  invisible(list(GITHUB_PAT = masked, status = status))
}

# Internal helper: mask a token to "..." + last 4 chars (or "" when unset).
mask_github_pat <- function(pat) {
  if (pat == "") {
    ""
  } else if (nchar(pat) > 4) {
    paste0("...", substr(pat, nchar(pat) - 3, nchar(pat)))
  } else {
    "..."
  }
}

# Internal helper: mask values whose key name matches a sensitive pattern.
# Used to sanitise Sys.getenv() before printing in the full diagnostic dump.
# Patterns are intentionally broad - "KEY" will also match vars like
# "..._KEYBOARD_LAYOUT", which is a deliberately conservative trade-off.
mask_sensitive_env <- function(
  env,
  patterns = c("TOKEN", "SECRET", "KEY", "PAT", "PASSWORD", "CRED")
) {
  if (length(env) == 0) {
    return(env)
  }
  re <- paste(patterns, collapse = "|")
  hits <- grepl(re, names(env), ignore.case = TRUE)
  if (any(hits)) {
    env[hits] <- vapply(env[hits], mask_github_pat, character(1))
  }
  env
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
#' @inheritParams diagnostic_params
#'
#' @inherit diagnostic_params details
#' @return List object containing `RENV_DOWNLOAD_METHOD` (with surrounding
#'   whitespace and any wrapping quotes stripped, or `NA` if the variable is
#'   not set) plus a `status` field.
#' @export
#'
#' @examples
#' \dontrun{
#' check_renv_download_method()
#' }
check_renv_download_method <- function(
  renviron_file = "~/.Renviron",
  clean = FALSE
) {
  cli::cli_h2("renv download method")
  if (file.exists(renviron_file)) {
    .renviron <- readLines(renviron_file)
  } else {
    .renviron <- c()
  }
  rdm_present <- grepl("^\\s*RENV_DOWNLOAD_METHOD\\s*=", .renviron)
  if (any(rdm_present)) {
    matched_lines <- .renviron[rdm_present]
    # .Renviron is evaluated top-to-bottom, so the last assignment wins.
    current_value <- utils::tail(matched_lines, 1)
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
      writeLines(.renviron, renviron_file)
      cli::cli_alert_success(
        "The renv download method has been set to curl in your .Renviron."
      )
      readRenviron(renviron_file)
      status <- "fixed"
    } else {
      if (any(rdm_present)) {
        cli::cli_alert_danger(
          "RENV_DOWNLOAD_METHOD is currently set to: {.code {current_value}}"
        )
      } else {
        cli::cli_alert_danger("RENV_DOWNLOAD_METHOD is not currently set.")
      }
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
        paste0(
          "Add the following line to .Renviron: ",
          "{.code RENV_DOWNLOAD_METHOD=\"curl\"}"
        )
      )
      cli::cli_end()
      cli::cli_text(
        "Or run {.code dfeR::check_renv_download_method(clean = TRUE)}."
      )
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
#' On Windows, `clean = TRUE` also clears the variable permanently from your
#' user environment (via `setx`), so it does not come back the next time you
#' start R. Windows only applies the change to new processes, so close and
#' reopen RStudio afterwards.
#'
#' @inheritParams diagnostic_params
#'
#' @inherit diagnostic_params details
#' @return List object containing `RENV_DOWNLOAD_FILE_METHOD` plus a `status`
#'   field.
#' @export
#'
#' @examples
#' \dontrun{
#' check_renv_dl_file_method()
#' }
check_renv_dl_file_method <- function(
  clean = FALSE
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
      permanent <- setx_clear("RENV_DOWNLOAD_FILE_METHOD")
      if (permanent) {
        cli::cli_alert_success(
          paste(
            "RENV_DOWNLOAD_FILE_METHOD has been cleared for this R session and",
            "permanently in your Windows user environment."
          )
        )
      } else {
        cli::cli_alert_success(
          "RENV_DOWNLOAD_FILE_METHOD has been unset for the current R session."
        )
      }
      status <- "fixed"
    } else {
      status <- "fail"
    }
  } else {
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
#' @inherit diagnostic_params details
#' @return List object containing `rtools_make_path` plus a `status` field.
#'   Missing RTools is reported as `"info"` rather than a failure because many
#'   users will not need to compile packages from source.
#' @export
#'
#' @examples
#' \dontrun{
#' check_rtools()
#' }
check_rtools <- function() {
  cli::cli_h2("RTools / make toolchain")
  make_path <- unname(Sys.which("make"))
  if (nzchar(make_path)) {
    cli::cli_alert_success("Found 'make' at {.path {make_path}}.")
    status <- "pass"
  } else {
    cli::cli_alert_warning(
      paste(
        "'make' was not found on PATH. On Windows this usually means RTools",
        "is not installed. If you need to install packages from source,",
        "install RTools from",
        "{.url https://cran.r-project.org/bin/windows/Rtools/}."
      )
    )
    status <- "info"
  }
  invisible(list(rtools_make_path = make_path, status = status))
}

# Internal helper: resolve the locations R consults for a user-level startup
# file (.Renviron or .Rprofile), in precedence order. `override_var` is the
# environment variable that, when set, overrides the search (R_ENVIRON_USER for
# .Renviron, R_PROFILE_USER for .Rprofile). When the override is set R reads
# only that target and does not fall back to the working-directory or home
# copies. Returns a list with the normalised candidate `paths`, a logical
# `exists` vector, the existing paths (`found`) and the path R will actually
# read (`used`, NA_character_ when none).
resolve_startup_file <- function(filename, override_var) {
  override <- Sys.getenv(override_var)
  has_override <- nzchar(override)
  paths <- character(0)
  if (has_override) {
    paths <- normalizePath(override, mustWork = FALSE)
  }
  paths <- c(
    paths,
    normalizePath(file.path(getwd(), filename), mustWork = FALSE),
    normalizePath(file.path(path.expand("~"), filename), mustWork = FALSE)
  )
  # Drop duplicate paths, keeping the highest-precedence occurrence (e.g. when
  # the working directory and home directory are the same folder).
  paths <- paths[!duplicated(paths)]
  exists <- file.exists(paths)
  if (has_override) {
    used <- paths[[1]]
  } else if (any(exists)) {
    used <- paths[exists][[1]]
  } else {
    used <- NA_character_
  }
  list(
    paths = paths,
    exists = exists,
    found = paths[exists],
    used = used
  )
}

# Internal helper: print the resolved locations for a single startup file.
# Shows every candidate that exists, plus the `used` path even when it is
# missing (which happens when an override points at a file that is not there),
# tagging the one R actually reads.
report_startup_file <- function(filename, resolved) {
  is_used <- !is.na(resolved$used) & resolved$paths == resolved$used
  shown <- resolved$exists | is_used
  if (!any(shown)) {
    cli::cli_text(
      "{filename}: not found in any location R reads (working directory or home)." # nolint: line_length_linter, line.
    )
    return(invisible(NULL))
  }
  n_found <- length(resolved$found)
  if (n_found > 1) {
    cli::cli_text("{filename}: found in {n_found} locations (the first wins):")
  } else {
    cli::cli_text("{filename}:")
  }
  for (i in seq_along(resolved$paths)) {
    if (!shown[[i]]) {
      next
    }
    tag <- if (is_used[[i]]) " [USED]" else ""
    suffix <- if (!resolved$exists[[i]]) " (missing)" else ""
    cli::cli_bullets(
      c("*" = paste0("{.path {resolved$paths[[i]]}}", tag, suffix))
    )
  }
  invisible(NULL)
}

#' Check the location of .Renviron and .Rprofile
#'
#' @description
#' Reports where R will read the user-level `.Renviron` and `.Rprofile` files
#' from, listing every location R consults in precedence order: the
#' `R_ENVIRON_USER` / `R_PROFILE_USER` override, the current working directory,
#' and the home directory. Each file that exists is listed, and the one R
#' actually uses is tagged, so you can spot when more than one copy exists (for
#' example a project-level file shadowing the one in your home directory).
#'
#' This check is purely informational and never reports a failure.
#'
#' @inherit diagnostic_params details
#' @return List object with a `renviron` and an `rprofile` entry (each a list of
#'   the `used` path and the `found` paths that exist), plus a `status` field
#'   which is always `"info"`.
#' @export
#'
#' @examples
#' \dontrun{
#' check_renv_rprof_location()
#' }
check_renv_rprof_location <- function() {
  cli::cli_h2(".Renviron / .Rprofile location")
  renviron <- resolve_startup_file(".Renviron", "R_ENVIRON_USER")
  rprofile <- resolve_startup_file(".Rprofile", "R_PROFILE_USER")
  report_startup_file(".Renviron", renviron)
  cli::cli_text("")
  report_startup_file(".Rprofile", rprofile)
  found_paths <- c(renviron$found, rprofile$found)
  if (any(grepl("OneDrive", found_paths, ignore.case = TRUE))) {
    cli::cli_alert_info(
      paste(
        "One or more of these files resolves inside OneDrive. R, RStudio and",
        "Git can resolve '~' inconsistently in that case, so double-check they",
        "all agree if something looks off."
      )
    )
  }
  invisible(list(
    renviron = list(used = renviron$used, found = renviron$found),
    rprofile = list(used = rprofile$used, found = rprofile$found),
    status = "info"
  ))
}
