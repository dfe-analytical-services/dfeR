test_that("prettifies", {
  expect_equal(pretty_num(1, gbp = TRUE, suffix = " offer"), "£1.00 offer")
  expect_equal(pretty_num(-1), "-1.00")
  expect_equal(pretty_num(-1, prefix = "-"), "--1.00")
  expect_equal(pretty_num(-1, prefix = "+/-"), "-1.00")
  expect_equal(pretty_num(1, prefix = "+/-"), "+1.00")
  expect_equal(pretty_num(12.289009, suffix = "%"), "12.29%")
  expect_equal(pretty_num(1000), "1,000.00")
  expect_equal(pretty_num(11^8, gbp = TRUE, dp = -1), "£210.0 million")
  expect_equal(pretty_num(11^9, gbp = TRUE, dp = 3), "£2.358 billion")
  expect_equal(pretty_num(-11^8, gbp = TRUE, dp = -1), "-£210.0 million")
  expect_equal(pretty_num(-123421421), "-123.42 million")
  expect_equal(
    pretty_num(11^8, prefix = "+/-", gbp = TRUE, dp = -1.00), "+£210.0 million"
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
})
