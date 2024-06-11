#' Title
#'
#' @param con
#' @param schema
#' @param table
#'
#' @return
#' @export
#'
#' @examples
tbl_nvarchar <- function(con, schema, table) {
  column_query <- paste0(
    "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS ",
    "WHERE TABLE_SCHEMA='", schema, "' AND TABLE_NAME='", table, "'"
  )
  column.types <- dbGetQuery(
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

  tbl(con, Id(schema = schema, table = table)) %>% select(all_of(ct))
}

#' Title
#'
#' @param table
#' @param con
#' @param schema
#' @param table_name
#' @param selection
#'
#' @return
#' @export
#'
#' @examples
tbl_nvarchar_select <- function(con, schema, table_name, selection) {
  column.types <- dbGetQuery(
    con,
    paste0(
      "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS ",
      "WHERE TABLE_SCHEMA='", schema, "' AND TABLE_NAME='", table, "'"
    )
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
#' @param table
#' @param con
#' @param schema
#' @param table_name
#'
#' @return
#' @export
#'
#' @examples
#' tbl_nvarchar(con, shema, table) %>%
#'   collect() %>%
#'   restore_order_nvarchar(con, schema, table)
restore_order_nvarchar <- function(table, con, schema, table_name) {
  current_column_order <- names(table)
  original_column_order <- tbl(con, Id(schema='INFORMATION_SCHEMA', table='COLUMNS')) %>%
    filter(table_schema == schema, table_name == table_name) %>%
    select(column_name)
  intersecting_columns <- intersect(original_column_order, current_column_order)
  # Checking for any extra columns that have been added to the original table
  added_columns <- setdiff(current_column_order, original_column_order)
  # Now re-ordering using the columns from the original table in their original
  # order, followed by any columns that have since been added to the data.
  table %>% select(all_of(intersecting_columns, added_columns))
}
