test_that("prettifies", {
  expect_equal(pretty_num(1, gbp = TRUE, suffix = " offer"), "£1 offer")
  expect_equal(pretty_num(-1), "-1")
  expect_equal(pretty_num(-1, prefix = "-"), "--1")
  expect_equal(pretty_num(-1, prefix = "+/-"), "-1")
  expect_equal(pretty_num(1, prefix = "+/-"), "+1")
  expect_equal(pretty_num(12.289009, suffix = "%"), "12.29%")
  expect_equal(pretty_num(1000), "1,000")
  expect_equal(pretty_num(11^8, gbp = TRUE, dp = -1), "£210 million")
  expect_equal(pretty_num(11^9, gbp = TRUE, dp = 3), "£2.358 billion")
  expect_equal(pretty_num(-11^8, gbp = TRUE, dp = -1), "-£210 million")
  expect_equal(pretty_num(-123421421), "-123.42 million")
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

test_that("rejects multiple values", {
  expect_error(
    pretty_num(c(1:4)),
    "value must be a single value, multiple values were detected"
  )
})
