
test_that("create_project() basic functionality test", {
  local({

    # Create a non-temporary directory for testing
    temp_dir <- withr::local_tempdir()

    # Call the function with a valid path
    create_project(path = temp_dir,
                   init_renv = TRUE,
                   include_structure_for_pkg = FALSE,
                   create_publication_proj = FALSE,
                   include_github_gitignore = FALSE)

    # Verify that the project structure is created correctly
    expect_true(dir.exists(paste0(temp_dir, "/_analysis")))
    expect_true(file.exists(paste0(temp_dir, "/_analysis/analysis.qmd")))
    expect_true(dir.exists(paste0(temp_dir, "/_output")))

    # Function files
    expect_true(file.exists(paste0(temp_dir, "/R/helpers.R")))

    # Test files
    expect_true(file.exists(paste0(temp_dir,
                                   "/tests/testthat/test-helpers.R")))

    # renv
    expect_true(dir.exists(paste0(temp_dir, "/renv")))
    expect_true(file.exists(paste0(temp_dir, "/renv.lock")))

    # Add more expectations for other directories and files as needed

  })
})


test_that("Test that if init_renv is set to FALSE then the custom warning
          message is displayed", {
  local({

    # Create a non-temporary directory for testing
    temp_dir <- withr::local_tempdir()

    # Create project with renv as false
    expect_warning({
      create_project(path = temp_dir,
                     init_renv = FALSE,
                     include_structure_for_pkg = FALSE,
                     create_publication_proj = FALSE,
                     include_github_gitignore = FALSE)
      },
      regexp = "renv couldn't be used as the `renv` package is not "
      )
  })
})