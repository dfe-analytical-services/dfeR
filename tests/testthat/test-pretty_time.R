test_that("pretties time", {
  expect_equal(pretty_time(1), "1 second")
  expect_equal(pretty_time(8), "8 seconds")
  expect_equal(pretty_time(60), "60 seconds")
  expect_equal(pretty_time(61), "61 seconds")
  expect_equal(pretty_time(121), "2 minutes 1 second")
  expect_equal(pretty_time(420), "7 minutes 0 seconds")
  expect_equal(pretty_time(3600), "60 minutes 0 seconds")
  expect_equal(pretty_time(3601), "60 minutes 1 second")
  expect_equal(pretty_time(3661), "61 minutes 1 second")
  expect_equal(pretty_time(7200), "2 hours 0 minutes 0 seconds")
  expect_equal(pretty_time(7261), "2 hours 1 minute 1 second")
  expect_equal(pretty_time(7321), "2 hours 2 minutes 1 second")
  expect_equal(pretty_time(8008), "2 hours 13 minutes 28 seconds")
})

test_that("comma separates", {
  expect_equal(pretty_time(3.6e+6), "1,000 hours 0 minutes 0 seconds")
})

test_that("handles vector inputs", {
  expect_equal(
    pretty_time(c(1, 8, 60, 61, 121, 4, 8008)),
    c(
      "1 second", "8 seconds", "60 seconds", "61 seconds",
      "2 minutes 1 second", "4 seconds", "2 hours 13 minutes 28 seconds"
    )
  )
})
