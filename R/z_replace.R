#' Replaces `NA` values in tables
#'
#' @description
#' Replaces `NA` values in tables except for ones in time and geography
#' columns that must be included in DfE official statistics.
#' \href{https://www.shorturl.at/chy76}{Guidance on our Open Data Standards.}
#'
#' @details

#' Names of geography and time columns that are used in this function can be
#' found in `dfeR::geog_time_identifiers`.
#'
#' @param data name of the table that you want to replace NA values in
#' @param replacement_alt optional - if you want the NA replacement
#' value to be different to "z"
#' @param exclude_columns optional - additional columns to exclude from
#' NA replacement.
#' Column names that match ones found in `dfeR::geog_time_identifiers`
#' will always be excluded because any missing data for these columns
#' need more explicit codes to explain why data is not available.
#'
#' @return table with "z" or an alternate replacement value instead of `NA`
#' values for columns that are not for time or geography.
#' @export
#' @seealso [dfeR::geog_time_identifiers]
#' @examples
#' # Create a table for the example
#'
#' df <- data.frame(
#'   time_period = c(2022, 2022, 2022),
#'   time_identifier = c("Calendar year", "Calendar year", "Calendar year"),
#'   geographic_level = c("National", "Regional", "Regional"),
#'   country_code = c("E92000001", "E92000001", "E92000001"),
#'   country_name = c("England", "England", "England"),
#'   region_code = c(NA, "E12000001", "E12000002"),
#'   region_name = c(NA, "North East", "North West"),
#'   mystery_count = c(42, 25, NA)
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
  # check for same column names but different case or formatting

  # load in potential column names

  geog_time_identifiers <- dfeR::geog_time_identifiers

  # check for same column names but different case or formatting

  # standardize column names for potential column names

  ref_col_names <- gsub("[[:punct:]]", " ", geog_time_identifiers)
  # removing extra space
  ref_col_names <- gsub("  ", " ", ref_col_names)
  # adding _ instead of spaces
  ref_col_names <- gsub(" ", "_", tolower(ref_col_names))


  # standardize column names for data input
  data_col_names_og <- colnames(data)

  data_col_names <- gsub("[[:punct:]]", " ", data_col_names_og)
  # removing extra space
  data_col_names <- gsub("  ", " ", data_col_names)
  # adding _ instead of spaces
  data_col_names <- gsub(" ", "_", tolower(data_col_names))

  # check if the column name exists by comparing standardized names

  col_name_exists <- data_col_names %in% ref_col_names
  # check if the formatting matches by comparing non-standardized
  formatting_test <- data_col_names_og %in% geog_time_identifiers

  if (any(col_name_exists %in% TRUE & formatting_test %in% FALSE) == TRUE) {
    stop(
      "Your table has geography and/or time column(s) that are not ",
      "in snake_case.\nPlease amend your column names to match the formatting",
      " of dfeR::geog_time_identifiers."
    )
  }

  # check for alt NA replacement
  # if no alt, provided, use z
  if (is.null(replacement_alt)) {
    replacement_alt <- "z"
    # check that replacement_alt is a single character vector
  } else if (!is.character(replacement_alt)) {
    stop(
      "You provided a ", data.class(replacement_alt),
      " input for replacement_alt.\n",
      "Please amend replace it with a character vector."
    )
  } else if (length(replacement_alt) > 1) {
    stop(
      "You provided multiple values for replacement_alt.\n",
      "Please, only provide a single value."
    )
  } else {
    # otherwise use the provided replacement
    replacement_alt <- replacement_alt
  }


  # start loop based on exclude_columns

  # if exclude columns is specified, use the snake case version
  if (!is.null(exclude_columns)) {
    data <- data %>%
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(
          geog_time_identifiers,
          exclude_columns
        )),
        ~ as.character(.)
      )) %>%
      # replace NAs
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(
          geog_time_identifiers,
          exclude_columns
        )),
        ~ dplyr::if_else(is.na(.), replacement_alt, .)
      ))
  } else {
    # if exclude_columns is not specified, then use the saved potential
    # location and time columns only
    data <- data %>%
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(geog_time_identifiers)),
        ~ as.character(.)
      )) %>%
      # replace NAs
      dplyr::mutate(dplyr::across(
        -tidyselect::any_of(c(geog_time_identifiers)),
        ~ dplyr::if_else(is.na(.), replacement_alt, .)
      ))
  }

  return(data)
}
