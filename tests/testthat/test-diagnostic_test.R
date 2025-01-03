test_that("Check proxy settings identifies and removes proxy setting", {
  # Set a dummy config parameter for the purposes of testing
  proxy_setting_names <- c("http.proxy.test", "https.proxy.test")
  # Check functionality with Git config
  git2r::config(http.proxy.test = "this-is-a-test-entry", global = TRUE)
  # Check that check_proxy_settings identifies the rogue entry
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names,
      clean = FALSE
    ) |>
      suppressMessages(),
    list(
      git = list(http.proxy.test = "this-is-a-test-entry"),
      system = NULL
    )
  )
  # Run the check in clean mode
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names,
      clean = TRUE
    ) |>
      suppressMessages(),
    list(
      git = list(http.proxy.test = "this-is-a-test-entry"),
      system = NULL
    )
  )
  # And now run again to see if clean mode worked in removing the rogue setting
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names
    ) |>
      suppressMessages(),
    list(
      git = NULL,
      system = NULL
    )
  )
  # Check functionality with system environment variables
  Sys.setenv(http.proxy.test = "this-is-a-test-entry")
  # Check that check_proxy_settings identifies the rogue entry
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names,
      clean = FALSE
    ) |>
      suppressMessages(),
    list(
      git = NULL,
      system = list(http.proxy.test = "this-is-a-test-entry")
    )
  )
  # Run the check in clean mode
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names,
      clean = TRUE
    ) |>
      suppressMessages(),
    list(
      git = NULL,
      system = list(http.proxy.test = "this-is-a-test-entry")
    )
  )
  # And now run again to see if clean mode worked in removing the rogue setting
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names
    ) |>
      suppressMessages(),
    list(
      git = NULL,
      system = NULL
    )
  )
})

test_that("Check RENV_DOWNLOAD_METHOD", {
  # Check that check_proxy_settings identifies the rogue entry
  expect_equal(
    check_renv_download_method(
      ".Renviron_test",
      clean = FALSE
    ) |>
      suppressMessages(),
    list(RENV_DOWNLOAD_METHOD = NA)
  )
})
