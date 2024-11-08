test_that("Check proxy settings identifies and removes proxy setting", {
  # Set a dummy config parameter for the purposes of testing
  git2r::config(http.proxy.test = "this-is-a-test-entry", global = TRUE)
  # Check that check_proxy_settings identifies the rogue entry
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = c("http.proxy.test", "https.proxy.test")
    ) |>
      suppressMessages(),
    list(http.proxy.test = "this-is-a-test-entry")
  )
  # Now double check that it cleared out the entry by running again...
  expect_equal(
    check_proxy_settings(
      proxy_setting_names = c("http.proxy.test", "https.proxy.test")
    ) |>
      suppressMessages(),
    purrr::keep(list(x = NULL), names(list(x = NULL)) != "x")
  )
})
