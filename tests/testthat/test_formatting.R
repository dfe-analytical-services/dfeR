context("format_ay")

test_that("Deals with non numeric year variable gracefully", {
  expect_error(format_ay("year"), "year parameter must be a number e.g. 201617")
})

test_that("Input as expected", {
  expect_error(format_ay(20102011), "year parameter should be 6 digits long e.g. 201617")
})

