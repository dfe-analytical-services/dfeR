test_that("check_proxy_settings identifies and removes proxy settings", {
  proxy_setting_names <- c("http.proxy.test", "https.proxy.test")
  proxy_env_names <- c("http_proxy_test", "https_proxy_test", "no_proxy_test")

  withr::defer(
    try(
      git2r::config(http.proxy.test = NULL, global = TRUE),
      silent = TRUE
    )
  )

  # Confirm the dummy config is actually set before checking removal
  git2r::config(http.proxy.test = "this-is-a-test-entry", global = TRUE)
  expect_true("http.proxy.test" %in% names(git2r::config()$global))

  # Detect (clean = FALSE)
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
  expect_false("http.proxy.test" %in% names(git2r::config()$global))
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

test_that("check_git_sslverify detects and corrects sslverify=false", {
  prior_sslverify <- git2r::config()$global$http.sslverify
  withr::defer(
    if (is.null(prior_sslverify)) {
      git2r::config(http.sslverify = NULL, global = TRUE)
    } else {
      git2r::config(http.sslverify = prior_sslverify, global = TRUE)
    }
  )

  git2r::config(http.sslverify = "false", global = TRUE)
  expect_equal(git2r::config()$global$http.sslverify, "false")

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
  expect_equal(
    tolower(git2r::config()$global$http.sslverify),
    "true"
  )
})

test_that("check_github_pat detects, masks and clears GITHUB_PAT", {
  withr::with_envvar(c(GITHUB_PAT = ""), {
    res <- suppressMessages(check_github_pat())
    expect_equal(res$GITHUB_PAT, "")
    expect_equal(res$status, "pass")
  })

  withr::with_envvar(c(GITHUB_PAT = "fake_token_abc1234"), {
    res <- suppressMessages(check_github_pat())
    expect_equal(res$GITHUB_PAT, "fake_token_abc1234")
    expect_equal(res$status, "fail")

    res_fixed <- suppressMessages(check_github_pat(clean = TRUE))
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

test_that("check_renv_download_file_method detects and clears wininet", {
  withr::with_envvar(c(RENV_DOWNLOAD_FILE_METHOD = ""), {
    res <- suppressMessages(check_renv_download_file_method())
    expect_equal(res$RENV_DOWNLOAD_FILE_METHOD, "")
    expect_equal(res$status, "pass")
  })

  withr::with_envvar(c(RENV_DOWNLOAD_FILE_METHOD = "wininet"), {
    res <- suppressMessages(check_renv_download_file_method())
    expect_equal(res$RENV_DOWNLOAD_FILE_METHOD, "wininet")
    expect_equal(res$status, "fail")

    res_fixed <- suppressMessages(check_renv_download_file_method(clean = TRUE))
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

test_that("check_renviron_rprofile_location reports paths", {
  res <- suppressMessages(check_renviron_rprofile_location())
  expect_true(is.list(res))
  expect_true(
    all(
      c(
        "renviron_path",
        "renviron_exists",
        "rprofile_path",
        "rprofile_exists",
        "HOME",
        "R_USER",
        "tilde",
        "status"
      ) %in%
        names(res)
    )
  )
  expect_true(res$status %in% c("info", "fail"))
})

test_that("check_gitconfig_location returns a path when git is on PATH", {
  skip_if(Sys.which("git") == "", "git not available on PATH")
  res <- suppressMessages(check_gitconfig_location())
  expect_true(is.list(res))
  expect_true("gitconfig_path" %in% names(res))
  expect_true(res$status %in% c("info", "fail"))
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
