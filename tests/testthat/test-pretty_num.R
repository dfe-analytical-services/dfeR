test_that("prettifies", {
  expect_equal(pretty_num(1, gbp = TRUE, suffix = " offer"), "£1 offer")
  expect_equal(pretty_num(-1, dp = 2), "-1.00")
  expect_equal(pretty_num(-1), "-1")
  expect_equal(pretty_num(-1, prefix = "-"), "--1")
  expect_equal(pretty_num(-1, prefix = "+/-"), "-1")
  expect_equal(pretty_num(-1, dp = 2, prefix = "+/-"), "-1.00")
  expect_equal(pretty_num(1, prefix = "+/-"), "+1")
  expect_equal(pretty_num(12.289009, dp = 2, suffix = "%"), "12.29%")
  expect_equal(pretty_num(1000), "1,000")
  expect_equal(pretty_num(11^8, gbp = TRUE, dp = -1), "£210 million")
  expect_equal(pretty_num(11^9, gbp = TRUE, dp = 3), "£2.358 billion")
  expect_equal(pretty_num(-11^8, gbp = TRUE, dp = -1), "-£210 million")
  expect_equal(pretty_num(-123421421, dp = 2), "-123.42 million")
  expect_equal(pretty_num(63.71, dp = 1, nsmall = 2), "63.70")
  expect_equal(pretty_num(894.1, dp = 2, nsmall = 3), "894.100")
  expect_equal(
    pretty_num(11^8, prefix = "+/-", gbp = TRUE, dp = -1), "+£210 million"
  )
})

test_that("handles NAs", {
  expect_no_error(pretty_num("x"))
  expect_equal(pretty_num("x", ignore_na = TRUE), "x")
  expect_equal(pretty_num("x"), as.double(NA))
  expect_equal(pretty_num("x", alt_na = "c"), "c")
})

test_that("tests multiple values", {
  expect_equal(
    pretty_num(c(1:4)),
    c("1", "2", "3", "4")
  )

  expect_equal(
    pretty_num(c(1:4), nsmall = 1),
    c("1.0", "2.0", "3.0", "4.0")
  )

  expect_equal(
    pretty_num(c(1.478, 7.38897, 8.37892), dp = 1, nsmall = 2),
    c("1.50", "7.40", "8.40")
  )
})
