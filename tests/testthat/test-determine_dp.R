test_that("Returns default dp for values < 1 million", {
  expect_equal(determine_dp(999999), 0)
})

test_that("Returns dynamic_dp_value for values >= 1 million not divisible by 10", {
  expect_equal(determine_dp(1e6), 2)
  expect_equal(determine_dp(3e6), 2)
})

test_that("Returns 0 for values >= 1 million divisible by 10", {
  expect_equal(determine_dp(10e6), 0)
})

test_that("Handles billion range correctly", {
  expect_equal(determine_dp(1e9), 2)
  expect_equal(determine_dp(10e9), 0)
})

test_that("Handles negative values correctly", {
  expect_equal(determine_dp(-1e6), 2)
  expect_equal(determine_dp(-10e6), 0)
})

test_that("Custom dp and dynamic_dp_value are respected", {
  expect_equal(determine_dp(1e6, dp = 1, dynamic_dp_value = 3), 3)
})


test_that("NA value returns custom dp", {
  expect_equal(determine_dp(NA, dp = 5, dynamic_dp_value = 3), 5)
})

test_that("Value < 1 million returns custom dp", {
  expect_equal(determine_dp(999999, dp = 2, dynamic_dp_value = 4), 2)
})

test_that("Value = 1 million returns dynamic_dp_value", {
  expect_equal(determine_dp(1e6, dp = 1, dynamic_dp_value = 3), 3)
})

test_that("Value = 10 million returns 0 if divisible by 10", {
  expect_equal(determine_dp(10e6, dp = 1, dynamic_dp_value = 4), 0)
})

test_that("Value = 3 billion returns dynamic_dp_value", {
  expect_equal(determine_dp(3e9, dp = 2, dynamic_dp_value = 5), 5)
})

test_that("Value = 10 billion returns 0 if divisible by 10", {
  expect_equal(determine_dp(10e9, dp = 2, dynamic_dp_value = 6), 0)
})

test_that("Negative values are handled correctly", {
  expect_equal(determine_dp(-2e6, dp = 3, dynamic_dp_value = 7), 7)
  expect_equal(determine_dp(-10e6, dp = 3, dynamic_dp_value = 7), 0)
})

test_that("Zero value returns default dp", {
  expect_equal(determine_dp(0, dp = 2, dynamic_dp_value = 4), 2)
})


test_that("Floating point values < 1 million return default dp", {
  expect_equal(determine_dp(0.123, dp = 1, dynamic_dp_value = 3), 1)
})

test_that("Floating point values >= 1 million return dynamic_dp_value", {
  expect_equal(determine_dp(1.5e6, dp = 1, dynamic_dp_value = 4), 4)
})

test_that("Edge case: exactly divisible by 10 after scaling", {
  expect_equal(determine_dp(20e6, dp = 1, dynamic_dp_value = 4), 0)
  expect_equal(determine_dp(30e9, dp = 1, dynamic_dp_value = 4), 0)
})

test_that("Edge case: not divisible by 10 after scaling", {
  expect_equal(determine_dp(21e6, dp = 1, dynamic_dp_value = 4), 4)
  expect_equal(determine_dp(31e9, dp = 1, dynamic_dp_value = 4), 4)
})

