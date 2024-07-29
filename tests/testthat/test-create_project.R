
test_that("create_project() basic functionality test", {
  local({

    # Create a temporary directory for testing
    temp_dir <- withr::local_tempdir()

    # Call the function with a valid path
    suppressMessages({
      create_project(path = temp_dir,
                     init_renv = TRUE,
                     include_structure_for_pkg = FALSE,
                     create_publication_proj = FALSE,
                     include_github_gitignore = FALSE)
    })

    # Verify that the project structure is created correctly
    expect_true(dir.exists(paste0(temp_dir, "/_analysis")))
    expect_true(file.exists(paste0(temp_dir, "/_analysis/analysis.qmd")))
    expect_true(dir.exists(paste0(temp_dir, "/_output")))

    # Function files
    expect_true(file.exists(paste0(temp_dir, "/R/helper_functions.R")))

    # Test files
    expect_true(file.exists(paste0(temp_dir,
                                   "/tests/testthat/test-helper_functions.R")))

    # renv
    expect_true(dir.exists(paste0(temp_dir, "/renv")))
    expect_true(file.exists(paste0(temp_dir, "/renv.lock")))

    # Add more expectations for other directories and files as needed

  })
})


test_that("init_renv = FALSE displays custom warning message", {
  local({
    # Create a non-temporary directory for testing
    temp_dir <- withr::local_tempdir()

    # Create project with renv as false
    suppressMessages({
      expect_warning({
        create_project(
          path = temp_dir,
          init_renv = FALSE,
          include_structure_for_pkg = FALSE,
          create_publication_proj = FALSE,
          include_github_gitignore = FALSE
        )
      }, regexp = "renv couldn't be used as the `renv` package is not ")
    })
  })
})


test_that("Empty include_github_gitignore displays boolean error message", {
  local({
    # Create a non-temporary directory for testing
    temp_dir <- withr::local_tempdir()

    # Create project with include_github_gitignore as value 1
    suppressMessages({
      expect_error({
        create_project(
          path = temp_dir,
          init_renv = FALSE,
          include_structure_for_pkg = FALSE,
          create_publication_proj = FALSE,
          include_github_gitignore = 1
        )
      }, regexp = "include_github_gitignore must be a boolean.")
    })
  })
})
