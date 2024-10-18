# testing pretty table
# create data frame for testing
df <- data.frame(
  a = c(2.589, -5.8937, "c"),
  b = c(11.19875, 45.6894, -78.4985),
  c = c("X", "Y", "Z")
)


test_that("prettifies tables", {
  expect_equal(pretty_num_table(df, dp = 2), data.frame(
    a = c("2.59", "-5.89", as.double(NA)),
    b = c("11.20", "45.69", "-78.50"),
    c = c(as.double(NA), as.double(NA), as.double(NA))
  ))

  expect_equal(pretty_num_table(df, dp = 3), data.frame(
    a = c("2.589", "-5.894", as.double(NA)),
    b = c("11.199", "45.689", "-78.499"),
    c = c(as.double(NA), as.double(NA), as.double(NA))
  ))

  expect_equal(
    pretty_num_table(df, dp = 2, gbp = TRUE, exclude_columns = "c"),
    data.frame(
      a = c("£2.59", "-£5.89", as.double(NA)),
      b = c("£11.20", "£45.69", "-£78.50"),
      c = c("X", "Y", "Z")
    )
  )

  expect_equal(
    pretty_num_table(df, gbp = TRUE, exclude_columns = "c"),
    data.frame(
      a = c("£3", "-£6", as.double(NA)),
      b = c("£11", "£46", "-£78"),
      c = c("X", "Y", "Z")
    )
  )


  expect_equal(
    pretty_num_table(df,
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
    pretty_num_table(df,
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
    pretty_num_table(df,
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
    pretty_num_table(df,
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

test_that("pretty_num_table with empty data frames", {
  expect_error(pretty_num_table(df), "Data frame is empty or contains no rows.")
})

# test non data frame objects

test_that("test non data frames", {
  expect_error(
    pretty_num_table(1.12),
    "Data has the class numeric, data must be a data.frame object"
  )

  expect_error(
    pretty_num_table("a"),
    "Data has the class character, data must be a data.frame object"
  )

  expect_error(
    pretty_num_table(c("a", 1.2)),
    "Data has the class character, data must be a data.frame object"
  )
})
