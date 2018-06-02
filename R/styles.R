#' Test
#'
#' @export


test_style <- function(toc = TRUE) {

  # get the locations of resource files located within the package
  tmp <- system.file("styles/template.docx", package = "dfeR")

  # call the base html_document function
  rmarkdown::word_document(toc = toc,
                           reference_docx = tmp)
}
