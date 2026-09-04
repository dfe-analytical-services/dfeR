git_set <- function(key, value) {
  system2(
    "git",
    c("config", "--global", key, value),
    stdout = FALSE,
    stderr = FALSE
  )
}

git_get <- function(key) {
  out <- suppressWarnings(
    system2(
      "git",
      c("config", "--global", "--get", key),
      stdout = TRUE,
      stderr = FALSE
    )
  )
  if (length(out) == 0) NA_character_ else out[[1]]
}

# GIT_CONFIG_GLOBAL has been honoured since git 2.32 (June 2021). Tests that
# write to the global config use it to redirect those writes into a temp file,
# so the user's real ~/.gitconfig is never touched.
git_supports_isolated_global <- function() {
  if (!nzchar(Sys.which("git"))) {
    return(FALSE)
  }
  ver <- suppressWarnings(
    system2("git", "--version", stdout = TRUE, stderr = FALSE)
  )
  if (length(ver) == 0) {
    return(FALSE)
  }
  m <- regmatches(ver, regexpr("[0-9]+\\.[0-9]+(\\.[0-9]+)?", ver))
  if (length(m) == 0) {
    return(FALSE)
  }
  numeric_version(m) >= "2.32"
}

local_isolated_gitconfig <- function(.local_envir = parent.frame()) {
  testthat::skip_if_not(
    git_supports_isolated_global(),
    "git >= 2.32 required for isolated GIT_CONFIG_GLOBAL"
  )
  cfg <- withr::local_tempfile(.local_envir = .local_envir)
  file.create(cfg)
  withr::local_envvar(
    c(GIT_CONFIG_GLOBAL = cfg),
    .local_envir = .local_envir
  )
  invisible(cfg)
}

test_that("check_proxy_settings identifies and removes proxy settings", {
  local_isolated_gitconfig()
  # Stub out the permanent (setx) removal so the test does not write to the
  # real Windows user environment; we only assert the session-level clear.
  testthat::local_mocked_bindings(setx_clear = function(var) FALSE)
  proxy_setting_names <- c("http.proxy.test", "https.proxy.test")
  proxy_env_names <- c("http_proxy_test", "https_proxy_test", "no_proxy_test")

  # Confirm the dummy config is actually set before checking removal
  git_set("http.proxy.test", "this-is-a-test-entry")
  expect_equal(git_get("http.proxy.test"), "this-is-a-test-entry")

  # Detection run with clean disabled
  expect_equal(
    suppressMessages(
      check_proxy_settings(
        proxy_setting_names = proxy_setting_names,
        proxy_env_names = proxy_env_names,
        clean = FALSE
      )
    ),
    list(
      git = list(http.proxy.test = "this-is-a-test-entry"),
      system = NULL,
      status = "fail"
    )
  )

  # Clean
  expect_equal(
    suppressMessages(
      check_proxy_settings(
        proxy_setting_names = proxy_setting_names,
        proxy_env_names = proxy_env_names,
        clean = TRUE
      )
    ),
    list(
      git = list(http.proxy.test = "this-is-a-test-entry"),
      system = NULL,
      status = "fixed"
    )
  )

  # After cleaning, the setting is gone
  expect_true(is.na(git_get("http.proxy.test")))
  expect_equal(
    suppressMessages(
      check_proxy_settings(
        proxy_setting_names = proxy_setting_names,
        proxy_env_names = proxy_env_names
      )
    ),
    list(git = NULL, system = NULL, status = "pass")
  )

  # System environment branch
  withr::local_envvar(c(http_proxy_test = "this-is-a-test-entry"))
  expect_equal(
    suppressMessages(
      check_proxy_settings(
        proxy_setting_names = proxy_setting_names,
        proxy_env_names = proxy_env_names,
        clean = FALSE
      )
    ),
    list(
      git = NULL,
      system = list(http_proxy_test = "this-is-a-test-entry"),
      status = "fail"
    )
  )

  suppressMessages(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names,
      proxy_env_names = proxy_env_names,
      clean = TRUE
    )
  )
  expect_equal(Sys.getenv("http_proxy_test"), "")
})

test_that("check_proxy_settings reports permanent removal, multiple vars", {
  local_isolated_gitconfig()
  # Mock the permanent (setx) removal as succeeding so we can assert the
  # "permanently" success message fires when several variables are cleared.
  # This locks down the OR-accumulation of the `permanent` flag in the loop:
  # the success message must fire even though the helper is called per-variable.
  testthat::local_mocked_bindings(setx_clear = function(var) TRUE)
  proxy_setting_names <- c("http.proxy.test", "https.proxy.test")
  proxy_env_names <- c("http_proxy_test", "https_proxy_test", "no_proxy_test")

  withr::local_envvar(c(
    http_proxy_test = "this-is-a-test-entry",
    https_proxy_test = "this-is-another-test-entry"
  ))

  suppressMessages(
    expect_message(
      check_proxy_settings(
        proxy_setting_names = proxy_setting_names,
        proxy_env_names = proxy_env_names,
        clean = TRUE
      ),
      "permanently in your Windows user environment"
    )
  )
})

test_that("check_git_sslverify detects and corrects sslverify=false", {
  local_isolated_gitconfig()

  git_set("http.sslverify", "false")
  expect_equal(git_get("http.sslverify"), "false")

  res <- suppressMessages(
    check_git_sslverify(
      ssl_verify_vars = "http.sslverify",
      clean = FALSE
    )
  )
  expect_equal(res$ssl_verify, list(http.sslverify = "false"))
  expect_equal(res$status, "fail")

  res_fixed <- suppressMessages(
    check_git_sslverify(
      ssl_verify_vars = "http.sslverify",
      clean = TRUE
    )
  )
  expect_equal(res_fixed$status, "fixed")
  expect_equal(tolower(git_get("http.sslverify")), "true")
})

test_that("check_github_pat detects, masks and clears GITHUB_PAT", {
  withr::with_envvar(c(GITHUB_PAT = ""), {
    res <- suppressMessages(check_github_pat())
    expect_equal(res$GITHUB_PAT, "")
    expect_equal(res$status, "pass")
  })

  withr::with_envvar(c(GITHUB_PAT = "fake_token_abc1234"), {
    res <- suppressMessages(check_github_pat())
    expect_equal(res$GITHUB_PAT, "...1234")
    expect_equal(res$status, "fail")

    res_fixed <- suppressMessages(check_github_pat(clean = TRUE))
    expect_equal(res_fixed$GITHUB_PAT, "...1234")
    expect_equal(res_fixed$status, "fixed")
    expect_equal(Sys.getenv("GITHUB_PAT"), "")
  })
})

test_that("check_renv_download_method handles missing/curl/wininet cases", {
  # Missing file
  missing <- tempfile()
  res_missing <- suppressMessages(check_renv_download_method(missing))
  expect_equal(res_missing$RENV_DOWNLOAD_METHOD, NA)
  expect_equal(res_missing$status, "fail")

  # Restore RENV_DOWNLOAD_METHOD because clean=TRUE calls readRenviron()
  withr::local_envvar(
    c(RENV_DOWNLOAD_METHOD = Sys.getenv("RENV_DOWNLOAD_METHOD"))
  )

  curl_file <- withr::local_tempfile(lines = 'RENV_DOWNLOAD_METHOD="curl"')
  res_curl <- suppressMessages(check_renv_download_method(curl_file))
  expect_equal(res_curl$RENV_DOWNLOAD_METHOD, "curl")
  expect_equal(res_curl$status, "pass")

  # Unquoted and whitespace variants should also be treated as PASS
  unquoted_file <- withr::local_tempfile(lines = "RENV_DOWNLOAD_METHOD=curl")
  expect_equal(
    suppressMessages(
      check_renv_download_method(unquoted_file)
    )$RENV_DOWNLOAD_METHOD,
    "curl"
  )

  spaced_file <- withr::local_tempfile(
    lines = 'RENV_DOWNLOAD_METHOD = "curl"'
  )
  expect_equal(
    suppressMessages(
      check_renv_download_method(spaced_file)
    )$RENV_DOWNLOAD_METHOD,
    "curl"
  )

  wininet_file <- withr::local_tempfile(
    lines = 'RENV_DOWNLOAD_METHOD="wininet"'
  )
  res_wininet <- suppressMessages(
    check_renv_download_method(wininet_file)
  )
  expect_equal(res_wininet$RENV_DOWNLOAD_METHOD, "wininet")
  expect_equal(res_wininet$status, "fail")

  res_clean <- suppressMessages(
    check_renv_download_method(wininet_file, clean = TRUE)
  )
  expect_equal(res_clean$status, "fixed")
  expect_equal(
    suppressMessages(
      check_renv_download_method(wininet_file)
    )$RENV_DOWNLOAD_METHOD,
    "curl"
  )
})

test_that("check_renv_dl_file_method detects and clears wininet", {
  # Stub out the permanent (setx) removal so the test does not write to the
  # real Windows user environment; we only assert the session-level clear.
  testthat::local_mocked_bindings(setx_clear = function(var) FALSE)
  withr::with_envvar(c(RENV_DOWNLOAD_FILE_METHOD = ""), {
    res <- suppressMessages(check_renv_dl_file_method())
    expect_equal(res$RENV_DOWNLOAD_FILE_METHOD, "")
    expect_equal(res$status, "pass")
  })

  withr::with_envvar(c(RENV_DOWNLOAD_FILE_METHOD = "wininet"), {
    res <- suppressMessages(check_renv_dl_file_method())
    expect_equal(res$RENV_DOWNLOAD_FILE_METHOD, "wininet")
    expect_equal(res$status, "fail")

    res_fixed <- suppressMessages(check_renv_dl_file_method(clean = TRUE))
    expect_equal(res_fixed$status, "fixed")
    expect_equal(Sys.getenv("RENV_DOWNLOAD_FILE_METHOD"), "")
  })
})

test_that("check_rtools returns make path info", {
  res <- suppressMessages(check_rtools())
  expect_true(is.list(res))
  expect_true("rtools_make_path" %in% names(res))
  expect_true(is.character(res$rtools_make_path))
  expect_true(res$status %in% c("pass", "info"))
})

test_that("check_renv_rprof_location returns info status and tidy shape", {
  res <- suppressMessages(check_renv_rprof_location())
  expect_equal(res$status, "info")
  # HOME / R_USER / path.expand("~") are no longer surfaced.
  expect_setequal(names(res), c("renviron", "rprofile", "status"))
  expect_setequal(names(res$renviron), c("used", "found"))
  expect_setequal(names(res$rprofile), c("used", "found"))
})

test_that("check_renv_rprof_location finds a working-directory copy", {
  tmp <- withr::local_tempdir()
  withr::local_dir(tmp)
  withr::local_envvar(c(R_ENVIRON_USER = "", R_PROFILE_USER = ""))
  file.create(file.path(tmp, ".Renviron"))
  file.create(file.path(tmp, ".Rprofile"))

  res <- suppressMessages(check_renv_rprof_location())

  wd_renviron <- normalizePath(file.path(getwd(), ".Renviron"))
  wd_rprofile <- normalizePath(file.path(getwd(), ".Rprofile"))
  # The working-directory copy outranks any home copy, so it is the one used.
  expect_equal(res$renviron$used, wd_renviron)
  expect_equal(res$rprofile$used, wd_rprofile)
  expect_true(wd_renviron %in% res$renviron$found)
  expect_true(wd_rprofile %in% res$rprofile$found)
})

test_that("check_renv_rprof_location reports multiple copies, override wins", {
  tmp <- withr::local_tempdir()
  withr::local_dir(tmp)
  file.create(file.path(tmp, ".Renviron"))
  override <- withr::local_tempfile(fileext = ".Renviron")
  file.create(override)
  withr::local_envvar(c(R_ENVIRON_USER = override, R_PROFILE_USER = ""))

  res <- suppressMessages(check_renv_rprof_location())

  override_path <- normalizePath(override)
  wd_renviron <- normalizePath(file.path(getwd(), ".Renviron"))
  # Two copies exist; the R_ENVIRON_USER override short-circuits the search.
  expect_equal(res$renviron$used, override_path)
  expect_true(all(c(override_path, wd_renviron) %in% res$renviron$found))
})

test_that("check_renv_rprof_location ignores absent working-directory copies", {
  tmp <- withr::local_tempdir()
  withr::local_dir(tmp)
  withr::local_envvar(c(R_ENVIRON_USER = "", R_PROFILE_USER = ""))

  res <- suppressMessages(check_renv_rprof_location())

  wd_renviron <- normalizePath(
    file.path(getwd(), ".Renviron"),
    mustWork = FALSE
  )
  expect_false(wd_renviron %in% res$renviron$found)
})

test_that("check_renv_rprof_location surfaces a missing override target", {
  missing <- withr::local_tempfile(fileext = ".Renviron")
  withr::local_envvar(c(R_ENVIRON_USER = missing))

  res <- suppressMessages(check_renv_rprof_location())

  override_path <- normalizePath(missing, mustWork = FALSE)
  # R reads only the override target, even though it does not exist.
  expect_equal(res$renviron$used, override_path)
  expect_false(override_path %in% res$renviron$found)
})

test_that("git_config_get_global resolves duplicate keys like git", {
  local_isolated_gitconfig()

  git_set("http.proxy.test", "first-value")
  # git config replaces existing keys, so append a duplicate section to the
  # config file directly to simulate a hand-edited .gitconfig.
  cfg <- Sys.getenv("GIT_CONFIG_GLOBAL")
  cat(
    '[http "proxy"]\n\ttest = last-value\n',
    file = cfg,
    append = TRUE
  )

  res <- git_config_get_global("http.proxy.test")
  expect_equal(res, list(http.proxy.test = "last-value"))
})

test_that("check_gitconfig_location keeps the full path when it has spaces", {
  testthat::skip_if_not(
    git_supports_isolated_global(),
    "git >= 2.32 required for isolated GIT_CONFIG_GLOBAL"
  )
  base <- withr::local_tempdir()
  spaced_dir <- file.path(base, "OneDrive - Department for Education")
  dir.create(spaced_dir)
  cfg <- file.path(spaced_dir, ".gitconfig")
  writeLines(c("[user]", "\tname = Test"), cfg)
  withr::local_envvar(c(GIT_CONFIG_GLOBAL = cfg))

  res <- suppressMessages(check_gitconfig_location())

  expect_equal(
    normalizePath(res$gitconfig_path, mustWork = FALSE),
    normalizePath(cfg, mustWork = FALSE)
  )
  expect_equal(res$status, "fail")
})

test_that("check_gitconfig_location returns a path when git is on PATH", {
  skip_if(Sys.which("git") == "", "git not available on PATH")
  res <- suppressMessages(check_gitconfig_location())
  expect_true(is.list(res))
  expect_true("gitconfig_path" %in% names(res))
  expect_true(res$status %in% c("info", "fail", "pass"))
})

test_that("diagnostic_test runs without error", {
  res <- suppressMessages(diagnostic_test())
  expect_true(is.list(res))
  expect_true(
    all(
      c(
        "proxy",
        "sslverify",
        "gitconfig",
        "github_pat",
        "renv_download",
        "renv_download_file",
        "rtools",
        "renviron_rprofile"
      ) %in%
        names(res)
    )
  )
  # Every check now reports a status
  statuses <- vapply(res, function(x) x$status, character(1))
  expect_true(all(statuses %in% c("pass", "fail", "fixed", "info")))
})

test_that("diagnostic_test(full = TRUE) prints the full dump", {
  skip_if_not_installed("renv")
  # Mock renv::diagnostics to avoid the full dump actually being printed
  testthat::local_mocked_bindings(
    diagnostics = function(...) invisible(NULL),
    .package = "renv"
  )
  out <- testthat::capture_messages(diagnostic_test(full = TRUE))
  expect_true(any(grepl("Full diagnostic dump", out)))
})

test_that("diagnostic_test(full = TRUE) masks sensitive env values", {
  skip_if_not_installed("renv")
  testthat::local_mocked_bindings(
    diagnostics = function(...) invisible(NULL),
    .package = "renv"
  )
  withr::with_envvar(
    c(
      GITHUB_PAT = "ghp_thisisafaketoken12345",
      FAKE_API_TOKEN = "secret-value-abcd1234",
      MY_SAFE_VAR = "ordinary-value"
    ),
    {
      out <- paste(
        testthat::capture_messages(diagnostic_test(full = TRUE)),
        collapse = "\n"
      )
      expect_false(grepl("ghp_thisisafaketoken12345", out, fixed = TRUE))
      expect_false(grepl("secret-value-abcd1234", out, fixed = TRUE))
      expect_true(grepl("...2345", out, fixed = TRUE))
      expect_true(grepl("...1234", out, fixed = TRUE))
    }
  )
})

test_that("mask_sensitive_env masks values by key pattern", {
  env <- c(
    GITHUB_PAT = "ghp_abcdefghij1234",
    MY_API_TOKEN = "tok_zzzz9999",
    BORING = "hello",
    EMPTY_SECRET = ""
  )
  out <- mask_sensitive_env(env)
  expect_equal(out[["GITHUB_PAT"]], "...1234")
  expect_equal(out[["MY_API_TOKEN"]], "...9999")
  expect_equal(out[["BORING"]], "hello")
  # Unset/empty sensitive vars stay empty rather than rendering as "..."
  expect_equal(out[["EMPTY_SECRET"]], "")
})
