#' Create a standard project structure for analytical projects
#'
#' This function creates the the following structure to be used for analytical projects: \cr \cr
#' 1. R - A folder for your R scripts and functions \cr
#' 2. Data - A folder for copies of raw data to be stored if required \cr
#' 3. Outputs - A folder to populate in run.R with all outputs. Note outputs are considered disposable and not inteded to be tracked when using git. \cr
#' 4. Queries - A folder for copies of any SQL scripts used \cr
#' 5. Misc - A folder for anything else \cr
#' 6. README.md - A markdown file where documentation is to be kept \cr
#' 7. report.Rmd - An example R Markdown. Note .Rmd is in root so that relative references can be used easily.
#' 8. run.R - An R file that when run populates the outputs folder with your analysis \cr
#' @param path Folder path where you would like to create the structure. Default is current working directory
#' @return Updated folder structure
#' @keywords project, setup
#' @export
#' @examples
#' \dontrun{
#' project_setup()
#' }

project_setup <- function(path = ".") {

  if (!is.character(path)) stop("path parmaeter must be of type character")

  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  folders <- c("R","Data","Outputs", "Queries", "Misc")

  folders_w_path <- file.path(path, folders)

  lapply(folders_w_path, dir.create)

  write("#README\n\nThis document is to be filled in with the documentation of the analysis.",file = file.path(path, "README.md"))

  write("#Note\n\nOutputs are not tracked in git. To populate this folder you must run run.R.", file = file.path(path, "Outputs/README.md"))

  write("# This file should be used to run all of the code required to populate the Outputs folder \n\n# Example below that renders example markdown in Outputs folder \n\nrmarkdown::render('findings.Rmd', output_format = 'html_document', output_file='findings.html', output_dir='Outputs')", file = file.path(path, "run.R"))

  rmarkdown::draft(file.path(path, "findings.Rmd"), template = "dfe_analysis_markdown", package = "dfeR", edit = FALSE)

}
