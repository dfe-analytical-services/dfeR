# Tests for get_databricks_host utility

test_that("get_databricks_host returns existing https:// host unchanged", {
  withr::with_envvar(
    c(DATABRICKS_HOST = "https://adb-1234.cloud.databricks.com"),
    expect_equal(
      get_databricks_host(),
      "https://adb-1234.cloud.databricks.com"
    )
  )
})

test_that("get_databricks_host prepends https:// when scheme is missing", {
  withr::with_envvar(
    c(DATABRICKS_HOST = "adb-1234.cloud.databricks.com"),
    expect_equal(
      get_databricks_host(),
      "https://adb-1234.cloud.databricks.com"
    )
  )
})

test_that("get_databricks_host upgrades http:// to https://", {
  withr::with_envvar(
    c(DATABRICKS_HOST = "http://adb-1234.cloud.databricks.com"),
    expect_equal(
      get_databricks_host(),
      "https://adb-1234.cloud.databricks.com"
    )
  )
})

test_that("get_databricks_host strips trailing slash", {
  withr::with_envvar(
    c(DATABRICKS_HOST = "https://adb-1234.cloud.databricks.com/"),
    expect_equal(
      get_databricks_host(),
      "https://adb-1234.cloud.databricks.com"
    )
  )
})

test_that("get_databricks_host errors when DATABRICKS_HOST is unset", {
  withr::with_envvar(
    c(DATABRICKS_HOST = NA),
    expect_error(
      get_databricks_host(),
      "DATABRICKS_HOST must be set"
    )
  )
})

test_that("get_databricks_host errors when DATABRICKS_HOST is empty", {
  withr::with_envvar(
    c(DATABRICKS_HOST = ""),
    expect_error(
      get_databricks_host(),
      "DATABRICKS_HOST must be set"
    )
  )
})
