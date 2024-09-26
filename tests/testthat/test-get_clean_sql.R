test_that("Can retrieve basic script", {
  expect_equal(
    get_clean_sql("../sql_scripts/simple.sql"),
    paste0(
      " /* Simple SQL script to get all data from my database table",
      " */  SELECT * FROM [my_database_table]"
    )
  )
})

test_that("Ignores USE lines", {
  expect_equal(
    get_clean_sql("../sql_scripts/use_example.sql"),
    paste0(
      " /* Example SQL script use a Use call",
      " */   SELECT * FROM [my_database_table];"
    )
  )
})

test_that("Adds additional settings", {
  # Check that the output starts with the desired lines
  expect_true(
    grepl(
      "^SET ANSI_PADDING OFF SET NOCOUNT ON;",
      get_clean_sql("../sql_scripts/simple.sql", additional_settings = TRUE)
    )
  )
})

test_that("Keeps the query when adding additional settings", {
  # Check that the output ends with the desired lines
  expect_true(
    grepl(
      "\\[my_database_table\\]$",
      get_clean_sql("../sql_scripts/simple.sql", additional_settings = TRUE)
    )
  )
})

test_that("Doesn't add additional settings", {
  # Check that the output doesn't start with the additional lines
  expect_false(
    grepl(
      "^SET ANSI_PADDING OFF SET NOCOUNT ON;",
      get_clean_sql("../sql_scripts/simple.sql", additional_settings = FALSE)
    )
  )
  # Check that the output doesn't start with the additional lines
  expect_false(
    grepl(
      "^SET ANSI_PADDING OFF SET NOCOUNT ON;",
      get_clean_sql("../sql_scripts/simple.sql")
    )
  )
})

test_that("Rejects non-boolean values for additional_settings", {
  expect_error(
    get_clean_sql("../sql_scripts/simple.sql", additional_settings = "True"),
    "additional_settings must be either TRUE or FALSE"
  )
  expect_error(
    get_clean_sql("../sql_scripts/simple.sql", additional_settings = ""),
    "additional_settings must be either TRUE or FALSE"
  )
})

test_that("Rejects file that don't have SQL extension", {
  expect_error(
    get_clean_sql("../spelling.R"),
    ""
  )
})
