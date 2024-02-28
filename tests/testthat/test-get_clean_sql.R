test_that("Can retrieve basic script", {
  expect_equal(
    get_clean_sql("../sql_scripts/simple.sql"),
    " /* Simple SQL script to get all data from my database table */
    SELECT * FROM [my_database_table]",
    fixed
  )
})

test_that("Adds additional settings", {
  # Check that the output starts with the desired lines
  expect_true(
    grepl(
      "^SET ANSI_PADDING OFF SET NOCOUNT ON;",
      get_clean_sql("sql_scripts/simple.sql", additional_settings = T)
      )
  )
})

test_that("Rejects non-boolean values for additional_settings", {
  expect_equal(
    get_clean_sql("sql_scripts/simple.sql"),
  )
})
