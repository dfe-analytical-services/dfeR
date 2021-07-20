test_that("round five up rounds fives up", {
  expect_equal(roundFiveUp(285, -1), 290)
  expect_equal(roundFiveUp(2.85, 1), 2.9)
})

test_that("round five up rounds other numbers as expected", {
  expect_equal(roundFiveUp(283, -1), 280)
  expect_equal(roundFiveUp(2.87, 1), 2.9)
})
