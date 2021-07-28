test_that("Rounds fives up", {
  expect_equal(roundFiveUp(285, -1), 290)
  expect_equal(roundFiveUp(2.85, 1), 2.9)
})

test_that("Rounds other numbers", {
  expect_equal(roundFiveUp(283, -1), 280)
  expect_equal(roundFiveUp(2.87, 1), 2.9)
})

test_that("Input validation", {
  expect_error(roundFiveUp("ten", "10"), "both inputs must be numeric")
  expect_error(roundFiveUp(12, "ten"), "the roundTo value must be numeric")
  expect_error(roundFiveUp(12, "10"), "the roundTo value must be numeric")
  expect_error(roundFiveUp("twelve", 10), "the value to be rounded must be numeric")
  expect_error(roundFiveUp("12", 10), "the value to be rounded must be numeric")
})
