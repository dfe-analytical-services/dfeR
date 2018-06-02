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

  # get the locations of resource files located within the package
  file <- system.file("styles/national_statistic.docx", package = "dfeR")

  # call the base html_document function
  rmarkdown::word_document(reference_docx = file)
}
