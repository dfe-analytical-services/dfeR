test_that("Rejects non 6-digit numbers", {
  expect_error(format_fy(19858))
  expect_error(format_fy(1985))
  expect_error(format_fy(1985867))
  expect_error(format_fy("1999c"))
  expect_error(format_fy("abcdef"))
  expect_error(format_fy("1985-98"))
})

test_that("Converts correctly", {
  expect_equal(format_fy(199900), "1999-00")
  expect_equal(format_fy("199900"), "1999-00")
})
