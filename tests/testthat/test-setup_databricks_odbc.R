test_that("setup_databricks_odbc() returns TRUE on success", {
  withr::local_envvar(DATABRICKS_TOKEN = "abcdef")
  withr::local_envvar(DATABRICKS_HOST = "abcdef")
  withr::local_envvar(DATABRICKS_SQL_PATH = "abcdef")
  local_mocked_bindings(
    get_odbc_version = function(pkg, ...) package_version("1.4.0")
  )
  expect_true(suppressMessages(setup_databricks_odbc()))
})

test_that("setup_databricks_odbc() returns FALSE on unset variables", {
  withr::local_envvar(DATABRICKS_TOKEN = "abcdef")
  withr::local_envvar(DATABRICKS_HOST = "abcdef")
  withr::local_envvar(DATABRICKS_SQL_PATH = NA)
  local_mocked_bindings(
    get_odbc_version = function(pkg, ...) package_version("1.4.0")
  )
  expect_false(suppressMessages(setup_databricks_odbc()))
})

test_that("setup_databricks_odbc() returns FALSE on non-ascii env variables", {
  # Non ascii characters sometimes appear when copying from teams/powerpoint.
  # They don't show up in the console, so it's tricky to debug.
  withr::local_envvar(DATABRICKS_TOKEN = "abcdef")
  withr::local_envvar(DATABRICKS_HOST = "abcdef")
  withr::local_envvar(DATABRICKS_SQL_PATH = "abcdef\u00A0")
  local_mocked_bindings(
    get_odbc_version = function(pkg, ...) package_version("1.4.0")
  )
  expect_false(suppressMessages(setup_databricks_odbc()))
})

test_that("setup_databricks_odbc() returns FALSE for odbc version < 1.4.0", {
  withr::local_envvar(DATABRICKS_TOKEN = "abcdef")
  withr::local_envvar(DATABRICKS_HOST = "abcdef")
  withr::local_envvar(DATABRICKS_SQL_PATH = "abcdef")
  local_mocked_bindings(
    get_odbc_version = function(pkg, ...) package_version("1.3.0")
  )
  expect_false(suppressMessages(setup_databricks_odbc()))
})
