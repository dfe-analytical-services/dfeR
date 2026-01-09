#' Write a Data Frame to Delta Lake with COPY INTO
#'
#' This function writes a large R data frame or tibble (`df`) to a Delta Lake
#' table (`target_table`) on Databricks using Databricks Volumes and the
#' `COPY INTO` SQL command.
#'
#' @description
#' The function:
#' - Optionally overwrites the table
#' - Uploads the data as a Parquet file(s) to a Volume
#' - Executes a `COPY INTO` command to load the file(s) into Delta Lake
#' - Deletes the temporary file(s) after loading
#'
#' @details
#' This function requires the following R packages:
#' - `DBI`
#' - `arrow`
#' - `httr2`
#' - `dplyr`
#'
#' @param df A `data.frame` or `tibble` containing the data to be written to
#' Delta Lake.
#' @param target_table A character string specifying the name of the Delta
#' table.
#' Can be unqualified (`"table"`), partially qualified (`"schema.table"`), or
#' fully qualified (`"catalog.schema.table"`).
#' If not fully qualified, the function resolves the catalog and/or schema from
#' the active database connection.
#' @param db_conn A valid DBI connection object to Databricks. This connection
#' is used to interact with the Delta table.
#' @param column_types_schema An optional Arrow Schema object (created via
#' \code{arrow::schema(...)}) used to explicitly enforce precise data types
#' during Parquet conversion. If \code{NULL} (default), data types are inferred
#' from the R data frame.
#'
#' Type mapping reference (Arrow schema field → Spark SQL type):
#'   \itemize{
#'     \item Arrow int8/int16 → TINYINT/SMALLINT
#'     \item Arrow int32/int64 → INT/BIGINT
#'     \item Arrow float/double → FLOAT/DOUBLE
#'     \item Arrow string/large_string → STRING
#'     \item Arrow bool → BOOLEAN
#'     \item Arrow \code{date32[day]} → DATE
#'     \item Arrow \code{timestamp['s' | 'ms' | 'us', ...]} → TIMESTAMP_NTZ
#'     (no timezone)
#'     \item Arrow \code{timestamp['s' | 'ms' | 'us', tz = ...]} → TIMESTAMP
#'     (with timezone)
#'     \item Arrow decimal(P,S) → DECIMAL(P,S)
#'   }
#' Important notes for schema use:
#' \itemize{
#'   \item Factors: If the R data frame contains a \code{factor} column, the
#'   corresponding Arrow schema field must be \code{utf8()} or
#'   \code{large_utf8()}. The categorical labels are automatically converted
#'   and mapped to a \code{STRING} type in the Delta table.
#'   \item Timestamp precision: Second (\code{s}), millisecond (\code{ms}),
#'   and microsecond (\code{us}) precisions are supported. Nanosecond
#'   (\code{ns}) precision may be incompatible with the current Databricks
#'   runtime environment.
#' }
#' @param volume_dir A character string specifying the path to the target
#' Databricks Volume where the Parquet file will be uploaded.
#' @param copy_options A character string specifying options for the
#' `COPY INTO` command, e.g., `'mergeSchema' = 'true'`. Defaults to
#' `"'mergeSchema' = 'true'"`.
#' @param overwrite_table Logical; if \code{TRUE}, deletes and recreates the
#' Delta table before import. If \code{FALSE} and the table does not exist,
#' the function will throw an error.
#' @param chunk_size_bytes An integer specifying the size of each data chunk
#' in bytes. This is used to split the data frame into smaller chunks for
#' uploading. Defaults to 5GB.
#'
#' @return Invisibly returns the result of the `COPY INTO` execution.
#'
#' @examples
#' \dontrun{
#' # Setup connection using environment variables
#' con <- DBI::dbConnect(odbc::databricks(),
#'   httpPath = Sys.getenv("DATABRICKS_SQL_PATH")
#' )
#'
#' write_df_to_delta(
#'   df = my_data,
#'   target_table = "catalog.schema.my_table",
#'   db_conn = con,
#'   volume_dir = "/Volumes/catalog/schema",
#'   overwrite_table = TRUE
#' )
#' }
#'
#' @export
#' @import DBI
#' @import arrow
#' @import httr2
#' @importFrom dplyr mutate across where
write_df_to_delta <- function(df,
                              target_table,
                              db_conn,
                              column_types_schema = NULL,
                              volume_dir,
                              copy_options = "'mergeSchema' = 'true'",
                              overwrite_table = FALSE,
                              chunk_size_bytes = 5 * 1024^3) {
  # Validation checks to ensure input is a data frame or tibble
  if (!inherits(df, "data.frame") && !inherits(df, "tbl_df")) {
    stop(
      "Input data must be a data frame or tibble. Provided object is of type ",
      class(df)[1]
    )
  }

  # Check if the data frame is empty
  if (nrow(df) == 0) {
    stop("The provided data frame is empty. There is no data to upload.")
  }

  # Check that db_conn is a valid DBI connection
  validate_db_connection(db_conn)

  # Validate column_types_schema
  if (!is.null(column_types_schema) &&
        !inherits(column_types_schema, "Schema")) {
    stop(
      "`column_types_schema` must be an Arrow schema object ",
      "created with arrow::schema()."
    )
  }

  # Validate volume_dir argument
  if (is.null(volume_dir) || !is.character(volume_dir) ||
        length(volume_dir) != 1) {
    stop(
      "`volume_dir` must be a non-NULL string ",
      "specifying the Databricks volume path."
    )
  }

  # Check that the volume exists
  if (!volume_exists(volume_dir)) {
    stop(
      "Target volume '", volume_dir, "' does not exist. ",
      "Please check the path or mount the volume first."
    )
  }

  # Validate overwrite_table
  if (!is.logical(overwrite_table) || length(overwrite_table) != 1) {
    stop("`overwrite_table` must be a single logical value.")
  }

  if (!overwrite_table && !db_exists_table_ignore_case(db_conn, target_table)) {
    stop(
      "Target table does not exist and overwrite_table = FALSE. ",
      "Set overwrite_table = TRUE to create it. (NOTE: The table may exist ",
      "but your current user/role lacks the necessary USAGE permission ",
      "on the catalog or schema.)"
    )
  }

  # Validate chunk_size_bytes
  if (!is.numeric(chunk_size_bytes) || chunk_size_bytes <= 0) {
    stop("`chunk_size_bytes` must be a positive integer.")
  }

  # Handle overwriting the table if requested
  if (overwrite_table) {
    # If custom_schema is provided, pass it.
    # Otherwise, pass the data frame for inference.
    df_or_schema <- if (!is.null(column_types_schema)) {
      column_types_schema
    } else {
      df
    }
    create_empty_delta(df_or_schema, target_table, db_conn)
  }

  # Count initial number of rows in target table
  num_rows_ini <- count_delta_rows(target_table, db_conn)

  # Fetch memory size of the data frame to decide how to split it into chunks
  total_size_bytes <- utils::object.size(df)

  # Calculate the number of chunks based on the specified chunk size
  n_chunks <- ceiling(as.numeric(total_size_bytes) / chunk_size_bytes)

  # Split the data frame into chunks based on the calculated number of chunks
  chunk_indices <- if (n_chunks < 2) {
    list(seq_len(nrow(df))) # If only one chunk, return the entire data frame
  } else {
    split(seq_len(nrow(df)), cut(seq_len(nrow(df)),
      breaks = n_chunks,
      labels = FALSE
    ))
  }

  # Create a unique identifier for uploaded files
  unique_id <- paste0(
    "temp_parquet_", as.integer(Sys.time()), "_",
    sample(10000, 1), "_chunk"
  )

  # Process each chunk of the data frame
  for (i in seq_along(chunk_indices)) {
    df_chunk <- df[chunk_indices[[i]], ]

    # Write each chunk to a local temporary Parquet file
    local_tmp_file <- tempfile(fileext = ".parquet")

    # Conditionally apply the schema or retain the dataframe chunk
    data_to_write <- if (!is.null(column_types_schema)) {
      # Convert all factor columns to character to ensure Arrow compatibility
      df_chunk <- df_chunk |>
        dplyr::mutate(dplyr::across(dplyr::where(is.factor), as.character))

      # If schema is provided, convert to Arrow Table with enforced precision
      arrow::as_arrow_table(df_chunk, schema = column_types_schema)
    } else {
      # Otherwise, use the R dataframe directly
      # (inference will occur inside write_parquet)
      df_chunk
    }

    # Write the data object (Arrow Table or dataframe) as a Parquet file
    arrow::write_parquet(data_to_write, local_tmp_file, compression = "snappy")

    # Construct the target volume file path in Databricks
    volume_file <- paste0(volume_dir, "/", unique_id, i, ".parquet")

    # Upload the Parquet file to Databricks Volume
    message(
      "Uploading chunk ", i, " / ", n_chunks,
      "; data size: ", round(utils::object.size(df_chunk) / (1024^2), 2), " MB",
      "; parquet file size: ", round(file.size(local_tmp_file) / (1024^2), 2),
      " MB"
    )

    upload_to_volume(local_tmp_file, volume_file)

    # Close and remove the local temporary file after upload
    all_conns <- showConnections(all = TRUE)
    match_row <- which(all_conns[, "description"] ==
                         normalizePath(local_tmp_file,
                                       winslash = "\\", mustWork = FALSE))
    if (length(match_row) > 0) {
      conn_id <- as.integer(rownames(all_conns)[match_row])
      close(getConnection(conn_id))
    }
    tryCatch(
      {
        file.remove(local_tmp_file)
      },
      warning = function(w) {
        warning("Could not remove local file: ", conditionMessage(w))
      }
    )

    # Load the data into the Delta Lake table
    result <- copy_into_delta(target_table, volume_file, db_conn, copy_options)

    # Clean up: Delete uploaded file from Databricks Volumes
    delete_from_volume(volume_file)
  }

  # Count final number of rows in target table
  num_rows_end <- count_delta_rows(target_table, db_conn)

  # Validation check
  num_rows_table <- (num_rows_end - num_rows_ini)
  message("Number of inserted rows in table: ", num_rows_table)
  message("Matches number of rows in data frame: ", nrow(df) == num_rows_table)

  # Return the result of the COPY INTO operation (invisible to avoid clutter)
  invisible(result)
}
