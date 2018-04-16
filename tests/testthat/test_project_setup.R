context("project_setup")

test_that("folder structure can be created in temp folder",{

  # Create temporary directory to test function on
  dir <- file.path(tempdir(), "test")

  # Run project setup in directory
  project_setup(dir)

  # Make a character vector of all files in folder (Folders classed as files)
  files <- list.files(path = dir)

  # Check that the files match
  expect_equal(files, c("Data","Misc","Outputs","Queries","R","README.md","report.Rmd", "run.R"))
})

test_that("Deals with non character path variable gracefully", {
  expect_error(project_setup(1) , "path parmaeter must be of type character")
})

