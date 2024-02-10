test_that("Rounds fives up", {
  expect_equal(round_five_up(285, -1), 290)
  expect_equal(round_five_up(2.85, 1), 2.9)
})

test_that("Rounds other numbers", {
  expect_equal(round_five_up(283, -1), 280)
  expect_equal(round_five_up(2.87, 1), 2.9)
})

test_that("Input validation", {
  expect_error(
    round_five_up("ten", "10"),
    "both inputs must be numeric"
  )
  expect_error(
    round_five_up(12, "ten"),
    "the decimal places value must be numeric"
  )
  expect_error(
    round_five_up(12, "10"),
    "the decimal places value must be numeric"
  )
  expect_error(
    round_five_up("twelve", 10),
    "the value to be rounded must be numeric"
  )
  expect_error(
    round_five_up("12", 10),
    "the value to be rounded must be numeric"
  )
})
