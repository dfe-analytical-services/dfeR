test_that("pretties time", {
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:05:53",
      "2024-03-23 07:05:54"
    ),
    "1 second"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:05:53",
      "2024-03-23 07:05:57"
    ),
    "4 seconds"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:05:53",
      "2024-03-23 07:09:53"
    ),
    "4 minutes 0 seconds"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:05:53",
      "2024-03-23 07:09:54"
    ),
    "4 minutes 1 second"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:09:53",
      "2024-03-23 09:08:52"
    ),
    "118 minutes 59 seconds"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:09:53",
      "2024-03-23 09:09:52"
    ),
    "1 hour 59 minutes 59 seconds"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:09:53",
      "2024-03-23 09:09:53"
    ),
    "2 hours 0 minutes 0 seconds"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:05:53",
      "2024-03-23 12:09:56"
    ),
    "5 hours 4 minutes 3 seconds"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 07:05:53",
      "2024-03-23 09:06:54"
    ),
    "2 hours 1 minute 1 second"
  )
  expect_equal(
    pretty_time_taken(
      "2024-03-23 20:05:53",
      "2024-03-24 01:09:53"
    ),
    "5 hours 4 minutes 0 seconds"
  )
})

test_that("comma separates", {
  expect_equal(
    pretty_time_taken(
      "2024-03-24 00:05:53",
      "2024-08-28 00:05:57"
    ),
    "3,768 hours 0 minutes 4 seconds"
  )
})

test_that("rejects non-dates", {
  expect_error(
    pretty_time_taken("12", "13"),
    "start and end times must be convertible to POSIXct format"
  )
})
