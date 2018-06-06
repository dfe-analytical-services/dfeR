context("rmarkdown_template")

test_that("Output is a list", {
  expect_equal(typeof(rmarkdown_template("national_statistic")), "list")
  })
