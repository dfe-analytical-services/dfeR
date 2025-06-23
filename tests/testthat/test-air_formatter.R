test_that("air_style runs Air", {
  air_install(update_global_settings = FALSE, verbose = FALSE)
  temp_dir <- tempdir()
  test_script <- file(file.path(temp_dir, "air_test.R"))
  writeLines(
    "test_function=function(\nparam=NULL){print(\nparam)}",
    con = test_script
  )
  close(test_script)

  air_style(file.path(temp_dir, "air_test.R"), verbose = FALSE)

  styled_code <- readLines(file.path(temp_dir, "air_test.R"))

  expect_equal(
    styled_code |>
      paste(collapse = "\n"),
    paste0(
      "test_function = function(\n  param = NULL\n) ",
      "{\n  print(\n    param\n  )\n}"
    )
  )

  unlink(temp_dir, recursive = TRUE)
})
