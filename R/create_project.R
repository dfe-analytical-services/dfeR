#' Creates a pre-populated project for DfE R
#'
#' @param path Path of the new project
#' @param init_renv Boolean of whether to initiate renv in the project.
#' Default is set to true.
#' @param include_structure_for_pkg Additional structure for package development
#' @param create_publication_proj Should the folder structure be for a
#' publication project
#' @param include_github_gitignore Should a strict .gitignore file for
#' GitHub be created
#' @param ... Additional parameters, currently not used
#'
#' @details This function creates a new project with a specified structure.
#' It sets up the R/ folder and template function scripts,
#' initializes testthat and adds tests for the function scripts,
#' builds the core project structure, creates a .gitignore file,
#' creates a readme, and optionally initializes renv.
#'
#' @return no return values, the project and its contents are created
#' @importFrom utils installed.packages
#' @importFrom withr with_dir
#' @importFrom usethis create_package create_project use_testthat use_test
#' @importFrom usethis proj_set
#' @import testthat
#' @import rmarkdown
#' @import renv
#' @import stringr
#' @export
#' \dontrun{
#' # Load the necessary library
#' library(your_package_name)  # replace with your actual package name
#'
#' # Define the path for the new project
#' path <- "/path/to/your/new/project"  # replace with your actual path
#'
#' # Call the function to create a new project
#' create_project(
#'   path = path,
#'   init_renv = TRUE,
#'   include_structure_for_pkg = TRUE,
#'   create_publication_proj = FALSE,
#'   include_github_gitignore = TRUE
#' )
#' }
create_project <- function(
    path,
    init_renv=TRUE,
    include_structure_for_pkg,
    create_publication_proj,
    include_github_gitignore,
    ...) {


  # Project creation
  usethis::create_project(path = path, open = FALSE)
  usethis::proj_set(path)


  # Setup R/ folder and template function scripts
  # helpers function script
  usethis::use_r(name = "helpers.R", open = FALSE)
  helpers_content <- c(
    paste0(
      '# Your functions can go here. ',
      'Then, when you want to ',
      'call those functions, run\n',
      '# `source("R/helpers.R")` at the start of your ',
      'script.\n\n',
      'print("Your scripts and functions should be in',
      'the R folder.")'
    )
  )
  writeLines(helpers_content, paste0(path, "/R/helpers.R"))

  # load_data functions script
  usethis::use_r(name = "load_data.R", open = FALSE)
  load_content <- c(
    paste0(
      '# You can use this script to store functions that ',
      'load in data.\n',
      '# Remember to include `source("R/load_data")` at ',
      'the start of\n',
      'the main script you want to call these functions ',
      'into.\n\n',
      '# Database connection ==== \n',
      'con <- DBI::dbConnect(odbc::odbc(),\n',
      '   Driver = "ODBC Driver 17 for SQL Server",\n',
      '   Server = "server_name",\n',
      '   Database = "database_name",\n',
      '   UID = "",\n',
      '   PWD = "",\n',
      '   Trusted_Connection = "Yes"\n',
      ')'
    )
  )
  writeLines(load_content, paste0(path, "/R/load_data.R"))


  # Initialise testthat and add tests for the function scripts
  usethis::use_testthat()
  usethis::use_test("helpers.R", open = FALSE)
  usethis::use_test("load_data.R", open = FALSE)


  # Build the core project structure
  if(!create_publication_proj) {
    # create ad-hoc project folder structure
    dir.create(paste0(path, "/_analysis/"))
    file.create(paste0(path, "/_analysis/analysis.qmd"))
    dir.create(paste0(path, "/_output/"))
  } else {
    # create large folder structure
    dir.create(paste0(path, "/01_data"))

    dir.create(paste0(path, "/02_analysis"))
    file.create(paste0(path, "/02_analysis/analysis.qmd"))

    dir.create(paste0(path, "/03_documentation"))
    dir.create(paste0(path, "/03_documentation/01_public"))
    dir.create(paste0(path, "/03_documentation/02_priv"))

    dir.create(paste0(path, "/04_outputs"))
    dir.create(paste0(path, "/04_outputs/01_results"))
    dir.create(paste0(path, "/04_outputs/02_figures"))
    dir.create(paste0(path, "/04_outputs/03_tables"))

    dir.create(paste0(path, "/05_misc"))
    dir.create(paste0(path, "/05_misc/01_public"))
    dir.create(paste0(path, "/05_misc/02_priv"))
  }


  # create a .gitignore file
  if (!include_github_gitignore) {
    # .gitignore for Azure DevOps
    gitignore_content <- c(
      ".Rproj.user",
      ".Rhistory",
      ".RData",
      ".Ruserdata",
      "*.xlsx"
    )
  } else {
    # .gitignore for GitHub
    gitignore_content <- c(
      ".Rproj.user",
      ".Rhistory",
      ".RData",
      ".Ruserdata",
      "_output",
      "01_Data",
      "03_Documentation",
      "04_Outputs",
      "*/02_priv",
      "*.html",
      "*.xlsx"
    )
  }

  # Write to .gitignore
  gitignore_concat <- paste0(gitignore_content, collapse = "\n")
  writeLines(gitignore_concat, con = file.path(path, ".gitignore"))


  # create a readme
  readme_content <- c(
    "# Readme",
    "This is the template for a standard data analysis.",
    "Please give an overview what you do in this project and how to ",
    "navigate it.",
    "",
    "## Introduction",
    "TODO: Give a short introduction of your project.",
    "Let this section explain the objectives or the motivation behind ",
    "this project.",
    "",
    "## Getting Started",
    "TODO: Guide users through getting your code up and running on their ",
    "own system. ",
    "In this section you can talk about:",
    "1.	Installation process",
    "2.	Software dependencies",
    "3.	Latest releases",
    "4.	API references",
    "",
    "# Build and Test",
    "TODO: Describe and show how to build your code and run the tests.",
    "",
    "# Contribute",
    "TODO: Explain how other users and developers can contribute to make ",
    "your code better.",
    "",
    "## Git integration",
    "If you want to use git with your project (you should!), ",
    "please do the following steps (replace `<name of your repository>` with ",
    "the actual name):",
    "",
    "1.  Go to your git repository provider (GitHub/Azure DevOps) and create ",
    "a new repository",
    "2.  DON'T check 'Add a README file'",
    "3.  Go to the Terminal within RStudio and type the following commands ",
    "(for the URL, e.g. https://github.com):",
    "",
    "```bash",
    "git init",
    "git branch -M main",
    "git remote add origin <URL of your GitHub/Azure DevOps instance>/<name ",
    "of your repository>.git",
    "```",
    "",
    "4.  Restart RStudio",
    "5.  Type in the R terminal `bash git add .` to add all files to ",
    "the commit",
    '5.  Type in the R terminal `bash git commit -m ',
    '"Your commit message (initial commit)"` to commit those files with ",
    "a message.',
    "6.  In the terminal, execute the following command:",
    "",
    "```bash",
    "git push -u origin main",
    "```",
    "",
    "7.  For the following commits, repeat this process",
    "",
    "NOTE: For sharing content on GitHub you should have ticked the ",
    "'Create a .gitignore file for GitHub' checkbox when creating the project.",
    "This will give create a strict .gitignore which is suitable for sharing ",
    "code to the public.",
    "Please also review to ensure no sensitive information is shared.",
    "",
    "For more information about the integration of git and RStudio, ",
    "check out https://happygitwithr.com."
  )

  # Write to README.md
  readme_concat <- paste0(readme_content, collapse = "\n")
  writeLines(readme_concat, con = file.path(path, "README.md"))


  # Initialise renv
  if (requireNamespace("renv", quietly = TRUE) & init_renv) {
    renv::init(project = path,
               bare = TRUE, load = FALSE)
    renv::snapshot(project = path, prompt = FALSE,
                   update = TRUE, packages = list("rmarkdown", "testthat",
                                                  "renv", "stringr"))
  } else {
    warning(
      paste0("renv couldn't be used as the `renv` package is not installed.",
             "If you want to use renv, please first install it with `install",
             ".packages('renv')`")
    )
  }
}

