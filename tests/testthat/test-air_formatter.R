test_that("air_formatter runs Air", {
  air_install(update_global_settings = FALSE, verbose = TRUE)
  temp_dir <- tempdir()
  test_script <- file(file.path(temp_dir, "air_test.R"))
  writeLines(
    "test_function=function(\nparam=NULL){print(\nparam)}",
    con = test_script
  )
  close(test_script)

  air_formatter(file.path(temp_dir, "air_test.R"), verbose = TRUE)

  formatted_code <- readLines(file.path(temp_dir, "air_test.R"))

  expect_equal(
    formatted_code |>
      paste(collapse = "\n"),
    "test_function = function(\n  param = NULL\n) {\n  print(\n    param\n  )\n}"
  )

  unlink(temp_dir, recursive = TRUE)
})
