context("format_ay")

test_that("Deals with non numeric year variable gracefully", {
  expect_error(format_ay("year"), "year parameter must be a six didgit number e.g. 201617")
})

test_that("Input as expected", {
  expect_error(format_ay(20102011), "year parameter must be a six didgit number e.g. 201617")
})

test_that("Input as expected", {
  expect_error(format_ay(2011), "year parameter must be a six didgit number e.g. 201617")
})

test_that("Example numerical known answer", {
  expect_equal(format_ay(201112), "2011/12")
})

test_that("Example character known answer", {
  expect_equal(format_ay("201112"), "2011/12")
})

context("round_nearest")

test_that("Input as expected", {
  expect_error(round_nearest(12, "ten"), "n must be a number")
})

test_that("Input as expected", {
  expect_error(round_nearest("twelve", 10), "x must be a number")
})

test_that("Example numerical known answer", {
  expect_equal(round_nearest(1337,5), "1335")
})

test_that("Example character known answer", {
  expect_equal(round_nearest("1337",10), "1340")
})
