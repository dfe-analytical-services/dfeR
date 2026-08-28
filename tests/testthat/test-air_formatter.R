test_that("air_style runs Air", {
  air_install(update_rstudio_settings = FALSE, verbose = FALSE)

  platform <- Sys.info()[1]
  air_executable <- if (platform == "Windows") "air.exe" else "air"
  user_home <- if (platform == "Windows") {
    Sys.getenv("USERPROFILE")
  } else {
    Sys.getenv("HOME")
  }
  air_path <- paste0(user_home, "/.local/bin/", air_executable)
  installed_version <- get_air_version(air_path)

  skip_if(
    is.na(installed_version) ||
      installed_version < numeric_version(dfer_min_air_version),
    paste0(
      "Installed Air version is older than the minimum supported version (",
      dfer_min_air_version,
      "); this test's expected output assumes the 'arrow' default ",
      "assignment-style introduced in that release"
    )
  )

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
      "test_function <- function(\n  param = NULL\n) ",
      "{\n  print(\n    param\n  )\n}"
    )
  )

  expect_error(
    air_style("./this/file/does/not/exist.R"),
    "Target file ./this/file/does/not/exist.R does not exist"
  )

  unlink(temp_dir, recursive = TRUE)
})
