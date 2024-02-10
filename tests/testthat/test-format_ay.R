test_that("Rejects non 6-digit numbers", {
  expect_error(format_ay(19858))
  expect_error(format_ay(1985))
  expect_error(format_ay(1985867))
  expect_error(format_ay("1999c"))
  expect_error(format_ay("abcdef"))
  expect_error(format_ay("1985-98"))
})

test_that("Converts correctly", {
  expect_equal(format_ay(199920), "1999/20")
  expect_equal(format_ay("199920"), "1999/20")
})
