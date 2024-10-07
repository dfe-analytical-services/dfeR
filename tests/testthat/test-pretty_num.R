test_that("prettifies", {
  expect_equal(pretty_num(1, gbp = TRUE, suffix = " offer"), "£1.00 offer")
  expect_equal(pretty_num(-1), "-1.00")
  expect_equal(pretty_num(-1, prefix = "-"), "--1.00")
  expect_equal(pretty_num(-1, prefix = "+/-"), "-1.00")
  expect_equal(pretty_num(1, prefix = "+/-"), "+1.00")
  expect_equal(pretty_num(12.289009, suffix = "%"), "12.29%")
  expect_equal(pretty_num(1000), "1,000.00")
  expect_equal(pretty_num(11^8, gbp = TRUE, dp = -1), "£210 million")
  expect_equal(pretty_num(11^9, gbp = TRUE, dp = 3), "£2.358 billion")
  expect_equal(pretty_num(-11^8, gbp = TRUE, dp = -1), "-£210 million")
  expect_equal(pretty_num(-123421421), "-123.42 million")
  expect_equal(pretty_num(63.71, dp = 1, nsmall = 2), "63.70")
  expect_equal(pretty_num(894.1, dp = 2, nsmall = 3), "894.100")
  expect_equal(
    pretty_num(11^8, prefix = "+/-", gbp = TRUE, dp = -1.00), "+£210 million"
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
    c("1.00", "2.00", "3.00", "4.00")
  )

  expect_equal(
    pretty_num(c(1:4), nsmall = 1),
    c("1.0", "2.0", "3.0", "4.0")
  )
})
