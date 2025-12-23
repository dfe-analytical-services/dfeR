test_that("dynamic_dp_value argument is respected for millions and billions", {
  # For values that are not whole millions/billions
  expect_equal(determine_dp(1.25e6, dp = 0, dynamic_dp_value = 4), 4)
  expect_equal(determine_dp(2.5e6, dp = 1, dynamic_dp_value = 3), 3)
  expect_equal(determine_dp(1.25e9, dp = 0, dynamic_dp_value = 4), 4)
  expect_equal(determine_dp(2.5e9, dp = 1, dynamic_dp_value = 3), 3)
  # For values that are whole millions/billions
  expect_equal(determine_dp(2e6, dp = 0, dynamic_dp_value = 4), 0)
  expect_equal(determine_dp(5e6, dp = 1, dynamic_dp_value = 3), 0)
  expect_equal(determine_dp(2e9, dp = 0, dynamic_dp_value = 4), 0)
  expect_equal(determine_dp(5e9, dp = 1, dynamic_dp_value = 3), 0)
  # For values < 1 million, should use dp
  expect_equal(determine_dp(999999, dp = 2, dynamic_dp_value = 4), 2)
})
test_that("Returns default dp for values < 1 million", {
  expect_equal(determine_dp(999999), 0)
})

test_that("Returns 0 for values >= 1 mil that are whole millions", {
  expect_equal(determine_dp(1e6), 0)
  expect_equal(determine_dp(3e6), 0)
  expect_equal(determine_dp(10e6), 0)
})

test_that("Handles billion range correctly (whole billions)", {
  expect_equal(determine_dp(1e9), 0)
  expect_equal(determine_dp(3e9), 0)
  expect_equal(determine_dp(10e9), 0)
})

test_that("Handles non-whole millions/billions correctly", {
  expect_equal(determine_dp(1.5e6), 2)
  expect_equal(determine_dp(1.5e9), 2)
})

test_that("Handles negative values correctly", {
  expect_equal(determine_dp(-1e6), 0)
  expect_equal(determine_dp(-10e6), 0)
})

test_that("Custom dp and dynamic_dp_value are respected", {
  expect_equal(determine_dp(1e6, dp = 1, dynamic_dp_value = 3), 0)
})


test_that("NA value returns custom dp", {
  expect_equal(determine_dp(NA, dp = 5, dynamic_dp_value = 3), 5)
})

test_that("Value < 1 million returns custom dp", {
  expect_equal(determine_dp(999999, dp = 2, dynamic_dp_value = 4), 2)
})

test_that("Value = 1 million returns 0 if whole million", {
  expect_equal(determine_dp(1e6, dp = 1, dynamic_dp_value = 3), 0)
})

test_that("Value = 10 million returns 0 if divisible by 10", {
  expect_equal(determine_dp(10e6, dp = 1, dynamic_dp_value = 4), 0)
})

test_that("Value = 3 billion returns 0 if whole billion", {
  expect_equal(determine_dp(3e9, dp = 2, dynamic_dp_value = 5), 0)
})

test_that("Value = 10 billion returns 0 if divisible by 10", {
  expect_equal(determine_dp(10e9, dp = 2, dynamic_dp_value = 6), 0)
})

test_that("Negative values are handled correctly for non-whole and whole millions", {
  expect_equal(determine_dp(-2e6, dp = 3, dynamic_dp_value = 7), 0)
  expect_equal(determine_dp(-10e6, dp = 3, dynamic_dp_value = 7), 0)
})

test_that("Zero value returns default dp", {
  expect_equal(determine_dp(0, dp = 2, dynamic_dp_value = 4), 2)
})


test_that("Floating point values < 1 million return default dp", {
  expect_equal(determine_dp(0.123, dp = 1, dynamic_dp_value = 3), 1)
})

test_that("Floating point values >= 1 million return dynamic_dp_value if not whole million", {
  expect_equal(determine_dp(1.5e6, dp = 1, dynamic_dp_value = 4), 4)
})

test_that("Edge case: exactly divisible by 1e6 or 1e9 after scaling", {
  expect_equal(determine_dp(20e6, dp = 1, dynamic_dp_value = 4), 0)
  expect_equal(determine_dp(30e9, dp = 1, dynamic_dp_value = 4), 0)
})

test_that("Edge case: not a whole million or billion after scaling", {
  expect_equal(determine_dp(21e6, dp = 1, dynamic_dp_value = 4), 0)
  expect_equal(determine_dp(31e9, dp = 1, dynamic_dp_value = 4), 0)
})
