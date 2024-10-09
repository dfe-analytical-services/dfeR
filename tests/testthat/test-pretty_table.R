# testing pretty table
# create data frame for testing
df <- data.frame(
  a = c(2.589, -5.8937, "c"),
  b = c(11.19875, 45.6894, -78.4985),
  c = c("X", "Y", "Z")
)


test_that("prettifies tables", {
  expect_equal(pretty_table(df), data.frame(
    a = c("2.59", "-5.89", as.double(NA)),
    b = c("11.20", "45.69", "-78.50"),
    c = c(as.double(NA), as.double(NA), as.double(NA))
  ))

  expect_equal(pretty_table(df, gbp = TRUE, exclude_columns = "c"), data.frame(
    a = c("£2.59", "-£5.89", as.double(NA)),
    b = c("£11.20", "£45.69", "-£78.50"),
    c = c("X", "Y", "Z")
  ))


  expect_equal(
    pretty_table(df,
      suffix = "%", dp = 1, nsmall = 2,
      exclude_columns = c("b", "c")
    ),
    data.frame(
      a = c("2.60%", "-5.90%", as.double(NA)),
      b = c(11.19875, 45.6894, -78.4985),
      c = c("X", "Y", "Z")
    )
  )

  expect_equal(
    pretty_table(df,
      alt_na = "[z]", dp = -1,
      include_columns = c("a", "b")
    ),
    data.frame(
      a = c("0", "-10", "[z]"),
      b = c("10", "50", "-80"),
      c = c("X", "Y", "Z")
    )
  )

  expect_equal(
    pretty_table(df,
      alt_na = "", dp = 2,
      prefix = "+/-", suffix = "g", include_columns = "a"
    ),
    data.frame(
      a = c("+2.59g", "-5.89g", ""),
      b = c(11.19875, 45.6894, -78.4985),
      c = c("X", "Y", "Z")
    )
  )


  expect_equal(
    pretty_table(df,
      dp = 2,
      include_columns = "a", exclude_columns = "b"
    ),
    data.frame(
      a = c("2.59", "-5.89", as.double(NA)),
      b = c(11.19875, 45.6894, -78.4985),
      c = c("X", "Y", "Z")
    )
  )
})

# test empty data frame

# create empty data frame for testing
df <- data.frame(
  a = character(),
  b = character(),
  c = character()
)

test_that("pretty_table with empty data frames", {
  expect_warning(pretty_table(df), "Data frame is empty or contains no rows.")
})
