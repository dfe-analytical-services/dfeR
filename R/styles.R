#' R Markdown template picker
#'
#' Allows you to pick template in inst/styles folder and convert into callable output type.
#'
#' @param template Name of template in styles folder

rmarkdown_template <- function(template) {

  # get the locations of resource files located within the package
  file <- system.file(paste0("styles/",template,".docx"), package = "dfeR")

  # call the base html_document function
  rmarkdown::word_document(reference_docx = file)
}

#' R Markdown DfE National Statistic Output Format
#'
#' This function creates an R Markdown output format that generates documents
#' in the style of an DfE National Statistics Publications. \cr
#'
#' To format an R Markdown document using this template add the function to the R Markdowns
#' YAML header as follows:
#'
#' title: "Name" \cr
#' output: dfeR::national_statistic
#'
#' @param ... All Parameters from rmarkdown::word_document are accepted
#' @export
#' @examples
#' national_statistic()

national_statistic <- function(...) {

  rmarkdown_template("national_statistic")

}

#' R Markdown DfE Official Statistic Output Format
#'
#' This function creates an R Markdown output format that generates documents
#' in the style of an DfE Official Statistics Publications. \cr
#'
#' To format an R Markdown document using this template add the function to the R Markdowns
#' YAML header as follows:
#'
#' title: "Name" \cr
#' output: dfeR::official_statistic
#'
#' @param ... All Parameters from rmarkdown::word_document are accepted
#' @export
#' @examples
#' official_statistic()

official_statistic <- function(...) {

  rmarkdown_template("official_statistic")

}
