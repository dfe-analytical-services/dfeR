test_that("Rejects non 6-digit numbers", {
  expect_error(formatAY(19858))
  expect_error(formatAY(1985))
  expect_error(formatAY(1985867))
  expect_error(formatAY("1999c"))
  expect_error(formatAY("abcdef"))
  expect_error(formatAY("1985-98"))
})

test_that("Converts correctly", {
  expect_equal(formatAY(199920), "1999/20")
  expect_equal(formatAY("199920"), "1999/20")
})
