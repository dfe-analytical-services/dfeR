test_that("Check proxy settings identifies and removes proxy setting", {
  # Set a dummy config parameter for the purposes of testing
  git2r::config(http.proxy.test = "this-is-a-test-entry", global = TRUE)
  proxy_setting_names <- c("http.proxy.test", "https.proxy.test")
  # Check that check_proxy_settings identifies the rogue entry
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names,
      clean = FALSE
    ) |>
      suppressMessages(),
    list(http.proxy.test = "this-is-a-test-entry")
  )
  # Run the check in clean mode
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names,
      clean = TRUE
    ) |>
      suppressMessages(),
    list(http.proxy.test = "this-is-a-test-entry")
  )
  # And now run again to see if clean mode worked in removing the rogue setting
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = proxy_setting_names
    ) |>
      suppressMessages(),
    proxy_config <- as.list(rep("", length(proxy_setting_names))) |>
      stats::setNames(proxy_setting_names)
  )
})

test_that("Test GITHUB_PAT diagnostic check", {
  # Check that check_proxy_settings identifies the rogue entry
  expect_equal(
    check_github_pat(
      clean = FALSE
    ) |>
      suppressMessages(),
    list(GITHUB_PAT = "")
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
