test_that("comma separates", {
  expect_equal(comma_sep(1000), "1,000")
  expect_equal(comma_sep(1000000), "1,000,000")
  expect_equal(comma_sep(10000000), "10,000,000")
  expect_equal(comma_sep(1000.24), "1,000.24")
  expect_equal(comma_sep(100), "100")
  expect_equal(comma_sep(-1000), "-1,000")
})

test_that("rejects non-numbers", {
  expect_error(
    comma_sep("12"),
    "number must be a numeric value"
  )
  expect_error(
    comma_sep("test"),
    "number must be a numeric value"
  )
  expect_error(
    comma_sep(TRUE),
    "number must be a numeric value"
  )
})
