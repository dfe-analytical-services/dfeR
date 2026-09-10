test_that("air_style runs Air", {
  air_install(update_rstudio_settings = FALSE, verbose = FALSE)

  air_path <- get_air_path()$air_path
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

test_that("air_install reports the right reason for reinstalling", {
  # Stub out the actual installer, we only care about the message given
  mockery::stub(air_install, "system", invisible(NULL))

  # Installing runs a remote script, so the reason is always announced, even
  # when verbose = FALSE. The stubbed version is what get_air_version() gives
  # back after the install too, so the branches below that are still under the
  # minimum version also warn - suppressed here to keep the focus on messages
  mockery::stub(air_install, "get_air_version", numeric_version("99.0.0"))
  expect_message(
    air_install(verbose = TRUE, force = TRUE),
    "Forcing a reinstall of Air"
  )
  expect_message(
    air_install(verbose = FALSE, force = TRUE),
    "Forcing a reinstall of Air"
  )

  expect_message(
    air_install(verbose = TRUE),
    "Air is already installed on your system"
  )
  expect_no_message(air_install(verbose = FALSE))

  mockery::stub(air_install, "get_air_version", numeric_version("0.9.0"))
  expect_message(
    suppressWarnings(air_install(verbose = TRUE)),
    "is older than the minimum supported version"
  )
  expect_message(
    suppressWarnings(air_install(verbose = FALSE)),
    "is older than the minimum supported version"
  )

  # Air missing entirely, no executable on disk to find
  mockery::stub(air_install, "get_air_version", NA)
  mockery::stub(air_install, "file.exists", FALSE)
  expect_message(
    suppressWarnings(air_install(verbose = TRUE)),
    "Air does not appear to be installed"
  )
  expect_message(
    suppressWarnings(air_install(verbose = FALSE)),
    "Air does not appear to be installed"
  )

  # Air present, but its version could not be determined
  mockery::stub(air_install, "file.exists", TRUE)
  expect_message(
    suppressWarnings(air_install(verbose = TRUE)),
    "could not determine its version"
  )
  expect_message(
    suppressWarnings(air_install(verbose = FALSE)),
    "could not determine its version"
  )
})

test_that("air_install warns when the install did not take", {
  # Stub out the actual installer, the version stub stays below the minimum
  # to mimic an install that silently failed to update Air
  mockery::stub(air_install, "system", invisible(NULL))
  mockery::stub(air_install, "get_air_version", numeric_version("0.9.0"))

  expect_warning(
    suppressMessages(air_install(verbose = FALSE)),
    "does not appear to have completed successfully"
  )

  # An install that worked leaves no warning behind
  mockery::stub(air_install, "get_air_version", numeric_version("99.0.0"))
  expect_no_warning(
    suppressMessages(air_install(verbose = FALSE, force = TRUE))
  )
})

test_that("get_air_path resolves a platform-specific executable path", {
  air_info <- get_air_path()

  expect_true(is.list(air_info))
  expect_true(all(
    c("platform", "air_executable", "user_home", "air_path") %in%
      names(air_info)
  ))
  expect_true(endsWith(air_info$air_path, air_info$air_executable))
  expect_true(grepl("/.local/bin/", air_info$air_path, fixed = TRUE))

  if (air_info$platform == "Windows") {
    expect_equal(air_info$air_executable, "air.exe")
  } else {
    expect_equal(air_info$air_executable, "air")
  }
})

test_that("get_air_version returns NA when the executable does not exist", {
  mockery::stub(get_air_version, "file.exists", FALSE)

  expect_true(is.na(get_air_version("/does/not/exist/air")))
})

test_that("get_air_version returns NA when system() errors", {
  mockery::stub(get_air_version, "file.exists", TRUE)
  mockery::stub(
    get_air_version,
    "system",
    function(...) stop("command not found")
  )

  expect_true(is.na(get_air_version("/fake/path/air")))
})

test_that("get_air_version returns NA and re-raises unexpected warnings", {
  mockery::stub(get_air_version, "file.exists", TRUE)
  mockery::stub(
    get_air_version,
    "system",
    function(...) {
      warning("something odd happened")
      "air 0.10.0"
    }
  )

  expect_warning(
    result <- get_air_version("/fake/path/air"),
    "something odd happened"
  )
  expect_true(is.na(result))
})

test_that("get_air_version treats a non-zero exit status as undetectable", {
  mockery::stub(get_air_version, "file.exists", TRUE)
  mockery::stub(
    get_air_version,
    "system",
    function(...) {
      # Mirrors what system(intern = TRUE) really does on a non-zero exit
      # status: it warns *and* sets a "status" attribute on the result
      # (see ?system) - get_air_version() relies on that attribute, not
      # the (locale-dependent) warning text, to detect this case
      result <- ""
      attr(result, "status") <- 1L
      warning("running command 'air --version' had status 1")
      result
    }
  )

  expect_no_warning(get_air_version("/fake/path/air"))
  expect_true(is.na(get_air_version("/fake/path/air")))
})

test_that("get_air_version detects a non-zero exit status via any locale", {
  mockery::stub(get_air_version, "file.exists", TRUE)
  mockery::stub(
    get_air_version,
    "system",
    function(...) {
      # A translated message that would not match an English-only
      # "had status" check, to prove detection relies on the "status"
      # attribute rather than the (locale-dependent) warning text
      result <- ""
      attr(result, "status") <- 1L
      warning("la commande a \u00e9chou\u00e9 avec le statut 1")
      result
    }
  )

  expect_no_warning(get_air_version("/fake/path/air"))
  expect_true(is.na(get_air_version("/fake/path/air")))
})

test_that("get_air_version returns NA when output has no version string", {
  mockery::stub(get_air_version, "file.exists", TRUE)
  mockery::stub(get_air_version, "system", "unexpected output, no version")

  expect_true(is.na(get_air_version("/fake/path/air")))
})

test_that("get_air_version parses a valid version string", {
  mockery::stub(get_air_version, "file.exists", TRUE)
  mockery::stub(get_air_version, "system", "air 0.10.0")

  expect_equal(
    get_air_version("/fake/path/air"),
    numeric_version("0.10.0")
  )
})
