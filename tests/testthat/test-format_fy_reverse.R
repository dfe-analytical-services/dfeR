test_that("Rejects incorrectly formatted dates", {
  expect_error(format_fy_reverse(19858))
  expect_error(format_fy_reverse(1985))
  expect_error(format_fy_reverse(1985867))
  expect_error(format_fy_reverse("1999c"))
  expect_error(format_fy_reverse("abcdef"))
  expect_error(format_fy_reverse("1985--98"))
  expect_error(format_fy_reverse("1985/98"))
})

test_that("Converts correctly", {
  expect_equal(format_fy_reverse("1999-20"), "199920")
})
