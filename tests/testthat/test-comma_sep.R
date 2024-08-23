test_that("comma separates", {
  expect_equal(comma_sep(1000), "1,000")
  expect_equal(comma_sep(1000000), "1,000,000")
  expect_equal(comma_sep(10000000), "10,000,000")
  expect_equal(comma_sep(1000.24), "1,000.24")
  expect_equal(comma_sep(100), "100")
  expect_equal(comma_sep(-1000), "-1,000")
})

test_that("handles non-numbers", {
  expect_equal(comma_sep("12"), "12")
  expect_equal(comma_sep("1200"), "1200")
  expect_equal(comma_sep("test"), "test")
  expect_equal(comma_sep(TRUE), "TRUE")
})
