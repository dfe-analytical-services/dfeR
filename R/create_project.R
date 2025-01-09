#' Creates a pre-populated project for DfE R
#'
#' @param path Path of the new project
#' @param init_renv Boolean; initiate renv in the project.
#' Default is set to true.
#' @param include_structure_for_pkg Boolean; Additional folder structure for
#' package development. Default is set to false.
#' @param create_publication_proj Boolean; Should the folder structure be for a
#' publication project. Default is set to false.
#' @param include_github_gitignore Boolean; Should a strict .gitignore file for
#' GitHub be created.
#' @param ... Additional parameters, currently not used
#'
#' @details This function creates a new project with a custom folder structure.
#' It sets up the `R/` folder and template function scripts,
#' initializes `{testthat}` and adds tests for the function scripts,
#' builds the core project structure, creates a .gitignore file,
#' creates a readme, and optionally initializes `{renv}`.
#'
#' @return No return values, the project and its contents are created
#' @importFrom utils installed.packages
#' @importFrom withr with_dir
#' @importFrom usethis create_package create_project use_testthat use_test
#' @importFrom usethis proj_set
#' @importFrom emoji emoji
#' @rawNamespace import(renv, except = run)
#' @export
#' @examples
#' \dontrun{
#'
#' # Call the function to create a new project
#' dfeR::create_project(
#'   path = "C:/path/to/your/new/project",
#'   init_renv = TRUE,
#'   include_structure_for_pkg = FALSE,
#'   create_publication_proj = FALSE,
#'   include_github_gitignore = TRUE
#' )
#' }
create_project <- function(
    path,
    init_renv = TRUE,
    include_structure_for_pkg = FALSE,
    create_publication_proj = FALSE,
    include_github_gitignore,
    ...) {
  # Function parameter checks ---
  # Check if the parameters are 1 length booleans
  # List of variables to check
  variables <- list(
    init_renv = init_renv,
    include_structure_for_pkg = include_structure_for_pkg,
    create_publication_proj = create_publication_proj,
    include_github_gitignore = include_github_gitignore
  )

  # Loop through each variable and check if it's a boolean
  for (var_name in names(variables)) {
    var_value <- variables[[var_name]]
    if (!is.logical(var_value) || length(var_value) != 1) {
      stop(paste(var_name, "must be a boolean."))
    }
  }

  # Project creation -----
  usethis::create_project(path = path, open = FALSE)
  usethis::proj_set(path)


  # Setup R/ folder and template function scripts -----
  ## helper_functions script
  usethis::use_r(name = "helper_functions.R", open = FALSE)
  helper_functions_content <- c(
    paste0(
      "# Your functions can go here. ",
      "Then, when you want to ",
      "call those functions, run\n",
      "# `source('R/helper_functions.R')` at the start of your ",
      "script.\n\n",
      "message('Your scripts and functions should be in ",
      "the R folder.')"
    )
  )
  writeLines(helper_functions_content, paste0(path, "/R/helper_functions.R"))

  ## load_data script
  usethis::use_r(name = "load_data.R", open = FALSE)
  load_content <- c(
    paste0(
      "# You can use this script to store functions that ",
      "load in data.\n",
      "# Remember to include `source('R/load_data')` at ",
      "the start of\n",
      "# the main script you want to call these functions ",
      "into.\n\n",
      "# Database connection ==== \n",
      "con <- DBI::dbConnect(odbc::odbc(),\n",
      "   Driver = 'ODBC Driver 17 for SQL Server',\n",
      "   Server = 'server_name',\n",
      "   Database = 'database_name',\n",
      "   UID = '',\n",
      "   PWD = '',\n",
      "   Trusted_Connection = 'Yes'\n",
      ")"
    )
  )
  writeLines(load_content, paste0(path, "/R/load_data.R"))


  # Initialise testthat and add tests for the function scripts -----
  usethis::use_test("helper_functions.R", open = FALSE)
  usethis::use_test("load_data.R", open = FALSE)


  # Build the core project structure -----
  if (!create_publication_proj) {
    # create ad-hoc project folder structure
    file.create(paste0(path, "/run.R"))
    dir.create(paste0(path, "/_data/"))
    dir.create(paste0(path, "/_analysis/"))
    dir.create(paste0(path, "/_output/"))
  } else {
    # create large folder structure
    dir.create(paste0(path, "/01_data"))
    dir.create(paste0(path, "/01_data/01_raw"))
    dir.create(paste0(path, "/01_data/02_prod"))

    dir.create(paste0(path, "/02_analysis"))

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


  # Create the .gitignore file -----
  if (!include_github_gitignore) {
    # .gitignore for Azure DevOps
    gitignore_content <- c(
      ".Rproj.user",
      ".Rhistory",
      ".RData",
      ".Ruserdata"
    )
  } else {
    # .gitignore for GitHub
    gitignore_content <- c(
      ".Rproj.user",
      ".Rhistory",
      ".RData",
      ".RData*",
      ".Ruserdata",
      "*unpublished*",
      "_output",
      "04_Outputs",
      "*/*_priv",
      "*/*_raw",
      "*.html",
      "*.xlsx"
    )
  }

  # Write to .gitignore
  gitignore_concat <- paste0(gitignore_content, collapse = "\n")
  writeLines(gitignore_concat, con = file.path(path, ".gitignore"))


  # Create the readme -----
  file.copy(
    system.file(package = "dfeR", "README_template.md"),
    file.path(path, "README.md")
  )

  # .renvignore
  file.create(paste0(path, "/.renvignore"))
  renvignore_content <- "tests/*"
  writeLines(renvignore_content, paste0(path, "/.renvignore"))


  # Initialise renv -----
  successful_creation <- TRUE

  if (init_renv) {
    # Test if renv snapshot works - if not throw informative error and
    # set project creation as fail
    tryCatch(
      {
        if (requireNamespace("renv", quietly = TRUE)) {
          renv::init(project = path, bare = TRUE, load = FALSE, restart = FALSE)
          renv::snapshot(
            project = path,
            prompt = FALSE,
            update = TRUE,
            packages = list("renv")
          )
        } else {
          # Message if renv not installed
          message(
            paste0(
              "Warning: ",
              "renv couldn't be used as the `{renv}` package is not ",
              "installed.\n",
              "If you want to use renv, please first install it with ",
              "`install.packages('renv')`"
            )
          )
          successful_creation <<- FALSE
        }
      },
      error = function(e) {
        if (grepl(
          "aborting snapshot due to pre-flight validation failure",
          e$message
        )) {
          # Message if renv snapshot fails
          message(
            "Warning: ",
            "`{renv}` not properly initialised due to the above missing ",
            "package(s).\n",
            "Please install the package(s) to successfully create project."
          )

          successful_creation <<- FALSE
        } else {
          # Re-throw original error if it's not related to snapshot
          message(e$message)

          successful_creation <<- FALSE
        }
      }
    )
  } else {
    # Message for if init_renv is FALSE
    warning(
      "Beware `{renv}` not in use."
    )
  }

  # Create a .Rprofile with a custom welcome message
  if (!file.exists(paste0(path, "/.Rprofile"))) {
    file.create(paste0(path, "/.Rprofile"))
  }
  rprofile_content <- paste(
    ".First <- function() {",
    "if ('praise' %in% installed.packages()) {",
    "    message(praise::praise('${Exclamation}-${Exclamation}! '),",
    "            'Welcome to your dfeR project.\\n',",
    "            praise::praise('Time for some ${adjective} R coding...'))",
    "  } else {",
    "    message('Welcome to your dfeR project!\\n',",
    "            'To finish setting up renv, please do the following:\\n\\n',",
    "            '- Run `renv::snapshot()`\\n',",
    "            '- Select `2: Install the packages, then snapshot.`\\n',",
    "            '- Finally type `y` to `Do you want to proceed?`\\n')",
    "  }",
    "}",
    "source('renv/activate.R')",
    sep = "\n"
  )
  writeLines(rprofile_content, paste0(path, "/.Rprofile"))

  # Successful project creation message (or delete project if fails)
  if (successful_creation) {
    message(
      paste0(
        "\n\n",
        "****************************************************************\n",
        "Your new dfeR project has been successfuly created! ",
        emoji::emoji("mortar_board"), "\n",
        "It exists at the file path: '", path, "'\n",
        "****************************************************************\n"
      )
    )
  } else {
    unlink(path, recursive = TRUE)
  }
}
