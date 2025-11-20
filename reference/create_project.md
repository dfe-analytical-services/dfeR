# Creates a pre-populated project for DfE R

Creates a pre-populated project for DfE R

## Usage

``` r
create_project(
  path,
  init_renv = TRUE,
  include_structure_for_pkg = FALSE,
  create_publication_proj = FALSE,
  include_github_gitignore,
  ...
)
```

## Arguments

- path:

  Path of the new project

- init_renv:

  Boolean; initiate renv in the project. Default is set to true.

- include_structure_for_pkg:

  Boolean; Additional folder structure for package development. Default
  is set to false.

- create_publication_proj:

  Boolean; Should the folder structure be for a publication project.
  Default is set to false.

- include_github_gitignore:

  Boolean; Should a strict .gitignore file for GitHub be created.

- ...:

  Additional parameters, currently not used

## Value

No return values, the project and its contents are created

## Details

This function creates a new project with a custom folder structure. It
sets up the `R/` folder and template function scripts, initializes
`{testthat}` and adds tests for the function scripts, builds the core
project structure, creates a .gitignore file, creates a readme, and
optionally initializes `{renv}`.

## Examples

``` r
if (FALSE) { # \dontrun{

# Call the function to create a new project
dfeR::create_project(
  path = "C:/path/to/your/new/project",
  init_renv = TRUE,
  include_structure_for_pkg = FALSE,
  create_publication_proj = FALSE,
  include_github_gitignore = TRUE
)
} # }
```
