df <- data.frame(
  a = c(2.589, -5.8937, "c"),
  b = c(11.19875, 45.6894, -78.4985),
  c = c("X", "Y", "Z")
)


test_that("prettifies tables", {

  expect_equal(pretty_table(df), data.frame(
    a = c("2.59", "-5.89", as.double(NA)),
    b = c("11.2", "45.69", "-78.5"),
    c = c(NA, NA, NA)
    ))

  expect_equal(pretty_table(df, gbp = TRUE, exclude_columns = "c"), data.frame(
    a = c("£2.59", "-£5.89", as.double(NA)),
    b = c("£11.2", "£45.69", "-£78.5"),
    c = c("X", "Y", "Z")
  ))


  expect_equal(pretty_table(df, suffix = "%", dp = 1,exclude_columns = c("b","c"))
               , data.frame(
    a = c("2.6%", "-5.9%", NA_real_),
    b = c(11.19875, 45.6894, -78.4985),
    c = c("X", "Y", "Z")
  ))
})
