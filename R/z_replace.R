#' Replaces `NA` values
#'
#' @description
#' Replaces `NA` values in tables except for time and location columns.
#'
#' @details

#' Names of location and time columns that are used in this function can be
#' found in `dfeR::geog_identifiers`and `dfeR::time_identifiers`.
#' Column names from tables put through the function are standardized
#' to match the snake case format used in `dfeR::geog_identifiers`
#' and `dfeR::time_identifiers` . This is to allow the function to check
#' for their presence but the function returns the column names in
#' their original form.
#'
#' @param data name of the table that you want to replace NA values in
#' @param replacement_alt optional - if you want the NA replacement
#' value to be different to "z"
#' @param exclude_columns optional - additional columns to exclude from
#' NA replacement.
#' Column names that match ones found in `dfeR::geog_identifiers`and
#' `dfeR::time_identifiers` will always be excluded.
#'
#' @return table with "z" or an alternate replacement value instead of `NA`
#' values for columns that are not for time or locations.
#' @export
#' @seealso [dfeR::geog_identifiers]
#' @seealso [dfeR::time_identifiers]
#' @examples
#' # Create a table for the example
#'
#' df <- data.frame(
#'   a = c(1, 2, 3, as.double(NA)),
#'   b = c(1, 2, as.double(NA), 4),
#'   LOCAL_AUTHORITY = c(1, 2, as.double(NA), 7),
#'   Academic_Year = c(2008, 2023, 2024, as.double(NA))
#' )
#'
#' z_replace(df)
#'
#' # Use a different replacement value
#' z_replace(df, replacement_alt = "c")
#'
z_replace <- function(data,
                      replacement_alt = NULL,
                      exclude_columns = NULL) {
  # check if table is empty

  # Check if the table has rows - if not, stop the process
  if (nrow(data) < 1) {
    stop("Table is empty or contains no rows.")
  }

  # standardize column names for the function
  # but keeping original names so that the data cols are not changed
  orignal_col_names <- colnames(data)

  # removing punctuation
  snake_col_names <- gsub("[[:punct:]]", " ", orignal_col_names)
  # removing extra space
  snake_col_names <- gsub("  ", " ", snake_col_names)
  # adding _ instead of spaces
  snake_col_names <- gsub(" ", "_", tolower(snake_col_names))
  # replacing original col names with snake case ones
  colnames(data) <- snake_col_names

  # change exclude_cols to snake case
  # removing punctuation
  snake_exclude_cols <- gsub("[[:punct:]]", " ", exclude_columns)
  # removing extra space
  snake_exclude_cols <- gsub("  ", " ", snake_exclude_cols)
  # adding _ instead of spaces
  snake_exclude_cols <- gsub(" ", "_", tolower(snake_exclude_cols))

  # load in potential column names

  time_identifiers <- dfeR::time_identifiers
  geog_identifiers <- dfeR::geog_identifiers

  # check for alt NA replacement
  # if no alt, provided, use z
  if (is.null(replacement_alt)) {
    replacement <- "z"
  } else {
    # otherwise use the provided replacement
    replacement <- replacement_alt
  }

  # start loop based on exclude_columns

  # if exclude columns is specified, use the snake case version
  if (!is.null(exclude_columns)) {
    data <- data %>%
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(
          time_identifiers, geog_identifiers,
          snake_exclude_cols
        )),
        ~ as.character(.)
      )) %>%
      # replace NAs
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(
          time_identifiers, geog_identifiers,
          snake_exclude_cols
        )),
        ~ dplyr::if_else(is.na(.), replacement, .)
      ))
  } else {
    # if exclude_columns is not specified, then use the saved potential
    # location and time columns only
    data <- data %>%
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(time_identifiers, geog_identifiers)),
        ~ as.character(.)
      )) %>%
      # replace NAs
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(time_identifiers, geog_identifiers)),
        ~ dplyr::if_else(is.na(.), replacement, .)
      ))
  }


  # return cols to original format
  colnames(data) <- orignal_col_names

  return(data)
}
