test_that("Can retrieve basic script", {
  expect_equal(
    get_clean_sql("sql_scripts/simple.sql"),
    TRUE
  )
})
