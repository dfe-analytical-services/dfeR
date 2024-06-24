#' tbl_nvarchar
#'
#' @param con A DBI connection to a database
#' @param table A valid table name or Id(schema, table)
#'
#' @return lazy_tbl
#' @export
#'
#' @examples
#' \dontrun{
#' tbl_nvarchar(con, Id(schema = 'dbo', table = 'my_sql_data_table'))
#' }
#'
tbl_nvarchar <- function(con, table) {
  # Retrieve the column names and types
  if(typeof(table) == "character"){
    column_query <- paste0(
      "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS ",
      "WHERE TABLE_NAME='", table, "'"
    )
  } else{
    column_query <- paste0(
      "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS ",
      "WHERE TABLE_SCHEMA='", schema, "' AND TABLE_NAME='", table, "'"
    )
  }
  column.types <- DBI::dbGetQuery(
    con,
    column_query
  )

  # Arrange the columns by type and width
  ct <- column.types %>%
    mutate(cml = case_when(
      is.na(CHARACTER_MAXIMUM_LENGTH) ~ 10,
      CHARACTER_MAXIMUM_LENGTH == -1 ~ 100000,
      TRUE ~ as.double(CHARACTER_MAXIMUM_LENGTH)
    )) %>%
    arrange(cml) %>%
    pull(COLUMN_NAME)

  # Run the query with the columns reordered by type and size
  tbl(con, table) %>% select(all_of(ct))
}

#' tbl_nvarchar_select
#'
#' @param con A DBI connection to a database
#' @param table A valid table name or Id(schema, table)
#' @param selection
#'
#' @return
#' @export
#'
#' @examples
tbl_nvarchar_select <- function(con, table, selection) {
  if(typeof(table) == "character"){
    column_query <- paste0(
      "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS ",
      "WHERE TABLE_NAME='", table, "'"
    )
  } else{
    column_query <- paste0(
      "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS ",
      "WHERE TABLE_SCHEMA='", schema, "' AND TABLE_NAME='", table, "'"
    )
  }
  column.types <- DBI::dbGetQuery(
    con,
    column_query
  )
  ct <- column.types %>%
    mutate(cml = case_when(
      is.na(CHARACTER_MAXIMUM_LENGTH) ~ 10,
      CHARACTER_MAXIMUM_LENGTH == -1 ~ 100000,
      TRUE ~ as.double(CHARACTER_MAXIMUM_LENGTH)
    )) %>%
    arrange(cml) %>%
    pull(COLUMN_NAME)
  ct_all <- c(setdiff(selection, ct), ct) %>% unique()
  ct_intersect <- intersect(ct_all, selection)
  tbl(con, Id(schema = schema, table = table)) %>% select(all_of(ct_intersect))
}

#' Restore order tbl_nvarchar output
#'
#' @param data Data to have columns reordered
#' @param con A DBI connection to a database
#' @param table A valid table name or Id(schema, table)
#'
#' @return
#' @export
#'
#' @examples
#' tbl_nvarchar(con, table) %>%
#'   collect() %>%
#'   restore_order_nvarchar(con, table)
restore_order_nvarchar <- function(data, con, table) {
  current_column_order <- names(data)
  original_column_order <- tbl(con, Id(schema='INFORMATION_SCHEMA', table='COLUMNS')) %>%
    filter(table_schema == schema, table_name == table_name) %>%
    select(column_name)
  intersecting_columns <- intersect(original_column_order, current_column_order)
  # Checking for any extra columns that have been added to the original table
  added_columns <- setdiff(current_column_order, original_column_order)
  # Now re-ordering using the columns from the original table in their original
  # order, followed by any columns that have since been added to the data.
  data %>% select(all_of(intersecting_columns, added_columns))
}
