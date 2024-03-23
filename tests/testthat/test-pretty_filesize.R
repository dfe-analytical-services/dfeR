test_that("pretties file size", {
  expect_equal(pretty_filesize(0.1), "0.1 bytes")
  expect_equal(pretty_filesize(1), "1 byte")
  expect_equal(pretty_filesize(999.99), "999.99 bytes")
  expect_equal(pretty_filesize(999.999), "1 KB")
  expect_equal(pretty_filesize(2^10), "1.02 KB")
  expect_equal(pretty_filesize(1000^2), "1 MB")
  expect_equal(pretty_filesize(1000 * 1024), "1.02 MB")
  expect_equal(pretty_filesize(10^9), "1 GB")
})

test_that("comma separates", {
  expect_equal(pretty_filesize(50000000*100000), "5,000 GB")
})

test_that("rejects non-numbers", {
  expect_error(
    pretty_filesize("12"),
    "file size must be a numeric value"
  )
  expect_error(
    pretty_filesize("test"),
    "file size must be a numeric value"
  )
  expect_error(
    pretty_filesize(TRUE),
    "file size must be a numeric value"
  )
})
