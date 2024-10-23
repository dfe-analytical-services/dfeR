#' Replaces `NA` values
#'
#' @description
#' Replaces `NA` values in data frames except for time and location columns.
#'
#' @details

#' Names of location and time columns that are used in this function can be found
#' in `dfeR::geog_identifiers`and `dfeR::time_identifiers`.
#' Column names from data frames put through the function are standardized
#' to match the snake case format used in `dfeR::geog_identifiers`
#' and `dfeR::time_identifiers` . This is to allow the function to check
#' for their presence but the function returns the column names in
#' their original form.
#' You can choose which columns to include or exclude from the `NA` replacement
#' by using exclude_columns and include_columns. This does not apply to the column
#' names that would match ones found in `dfeR::geog_identifiers`and `dfeR::time_identifiers`
#' as they will always be excluded from `NA` replacement. The default for both is `NULL`,
#' but if both are specified, exclude_columns takes precedence.
#'
#' @param data name of the table that you want to replace NA values in
#' @param replacement_alt optional - if you want the NA replacement
#' value to be different to "z"
#' @param exclude_columns optional - additional columns to exclude from NA replacement.
#' Column names that match ones found in `dfeR::geog_identifiers`and
#' `dfeR::time_identifiers` will always be excluded.
#'
#' @param include_columns optional - columns to add for NA replacement.
#' Column names found in `dfeR::geog_identifiers`and `dfeR::time_identifiers`
#' will not be included, even if added here.
#'
#' @return table with "z" or an alternate replacement value instead of `NA`
#' values for columns that are not for time or locations.
#' @export
#' @examples
#' #Create a data frame for the example
#'
#' df <- data.frame(a=c(1,2,3,as.double(NA)),
#' b= c(1,2,as.double(NA),4),
#' LOCAL_AUTHORITY=c(1,2,as.double(NA),7),
#' Academic_Year= c(2008,2023,2024,as.double(NA)))
#'
#' z_replace(df)
#'
#' # Use a different replacement value
#' z_replace(df, replacement_alt="c")
#'
#' # Exclude columns
#'z_replace(df, exclude_columns = "a")




z_replace <- function(data,
                      replacement_alt=NULL,
                      exclude_columns = NULL,
                      include_columns = NULL){

  #check if dataframe is empty

  # Check if the data frame has rows - if not, stop the process
  if (nrow(data) < 1) {
    stop("Data frame is empty or contains no rows.")
  }

#standardize column names for the function
#but keeping original names so that the data cols are not changed
orignal_col_names <- colnames(data)

#removing punctuation
snake_col_names <- gsub("[[:punct:]]"," ",orignal_col_names )
#removing extra space
snake_col_names <- gsub("  "," ",snake_col_names)
#adding _ instead of spaces
snake_col_names <- gsub(" ", "_", tolower(snake_col_names ))
#replacing original col names with snake case ones
colnames(data) <- snake_col_names

#load in potential col names

base::load(file="data/time_identifiers.rda")
base::load(file="data/geog_identifiers.rda")

# check for alt NA replacement
#if no alt, provided, use z
if(is.null(replacement_alt)){
  replacement <- "z"
}else{
  #otherwise use the provided replacement
  replacement <- replacement_alt
}

# Determine which columns to include based on the provided parameters

# if the include_columns arg is specified
if (!is.null(exclude_columns)) {
  # assign the names to the cols_to_include variable
  cols_to_exclude <- c(exclude_columns,time_identifiers,geog_identifiers)

  # if the exclude_columns arg is specified
} else if (!is.null(include_columns)) {
  # we assign the cols_to_include to names of all columns
  # except for ones specified in exclude_columns
  cols_to_exclude <- c(setdiff(
    names(data),
    include_columns
  ),time_identifiers,geog_identifiers)
} else {
  # if none of the previous conditions are met
  # all columns are assigned to cols_to_include
  cols_to_exclude <- c(time_identifiers,geog_identifiers)
}

#replace NAs
data <- data %>%
  mutate(across(-any_of(cols_to_exclude), ~ as.character(.))) %>%
  mutate(across(-any_of(cols_to_exclude), ~dplyr::if_else(is.na(.),replacement,.) ))

#return cols to original format
colnames(data) <- orignal_col_names

return(data)
}

