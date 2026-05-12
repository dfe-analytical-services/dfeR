# Tests for normalize_databricks_host utility

test_that("normalize_databricks_host adds https:// if missing", {
  expect_equal(
    normalize_databricks_host("adb-1234.cloud.databricks.com"),
    "https://adb-1234.cloud.databricks.com"
  )
  expect_equal(
    normalize_databricks_host("http://adb-1234.cloud.databricks.com"),
    "http://adb-1234.cloud.databricks.com"
  )
  expect_equal(
    normalize_databricks_host("https://adb-1234.cloud.databricks.com"),
    "https://adb-1234.cloud.databricks.com"
  )
})
