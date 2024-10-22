#' Replaces NA values
#'
#' @description
#' Replaces NA values in data frames except for time and location columns
#'
#' @details

#'
#' @param data name of the table that you want to replace NA values in
#' @param replacement_alt optional - if you want the NA replacement value to be different to "z"
#'
#' @return table with "z" instead of NA values
#' @export
#' @examples
#'



z_replace <- function(data,
                      replacement_alt=NULL){

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

#replace NAs
data <- data %>%
  mutate(across(everything(), ~ as.character(.))) %>%
  mutate(across(-any_of(c(time_identifiers,geog_identifiers)), ~dplyr::if_else(is.na(.),replacement,.) ))

#return cols to original format
colnames(data) <- orignal_col_names

return(data)
}

df <- data.frame(a=c(1,2,3,as.double(NA)),
                 b= c(1,2,as.double(NA),4),
                 National=c(1,2,as.double(NA),7))
z_replace(df, replacement_alt="c")
