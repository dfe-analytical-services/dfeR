# --- 1. Validation & Metadata ----------------------------------------------
# These functions check the connection and resolve table/volume names.

#' Validate a DBI connection
#'
#' @param db_conn A DBI database connection object to Databricks.
#' @return Stops execution if the connection is NULL, of wrong class,
#' or not valid.
#' @keywords internal
#' @import DBI
validate_db_connection <- function(db_conn) {
  if (is.null(db_conn)) {
    stop("Database connection is NULL.")
  }

  if (!inherits(db_conn, "DBIConnection")) {
    stop(
      "The provided object is not a DBI connection. It is of class: ",
      class(db_conn)[1]
    )
  }

  if (!DBI::dbIsValid(db_conn)) {
    stop("Database connection is not valid (disconnected or expired).")
  }
}

#' Resolve Table Name into Catalog, Schema, and Table
#'
#' Resolves a table name into its fully qualified components—catalog, schema,
#' and table—using the current session defaults from the Databricks connection
#' if necessary.
#'
#' @param table_name A character string specifying the table name.
#' Can be one of the following:
#'   - `"table"` (unqualified)
#'   - `"schema.table"` (partially qualified)
#'   - `"catalog.schema.table"` (fully qualified)
#'
#' @param db_conn A DBI database connection object (e.g., created using
#' `DBI::dbConnect()`).
#'
#' @return A named list with components:
#' \describe{
#'   \item{`catalog`}{The catalog name, either extracted from the input or
#'   resolved from the session via `current_catalog()`.}
#'   \item{`schema`}{The schema name, either extracted from the input or
#'   resolved from the session via `current_schema()`.}
#'   \item{`table`}{The bare table name.}
#' }
#'
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(odbc::odbc(), "Databricks")
#' resolve_table_parts("my_table", conn)
#' resolve_table_parts("my_schema.my_table", conn)
#' resolve_table_parts("my_catalog.my_schema.my_table", conn)
#' }
#' @keywords internal
#' @import DBI
resolve_table_parts <- function(table_name, db_conn) {
  parts <- strsplit(table_name, "\\.")[[1]]
  if (length(parts) < 1 || length(parts) > 3) {
    stop(
      "Invalid table name format. Use 'table', 'schema.table', ",
      "or 'catalog.schema.table'."
    )
  }

  # Fetch defaults from session
  conn_catalog <- DBI::dbGetQuery(db_conn, "SELECT current_catalog()")[[1]]
  conn_schema <- DBI::dbGetQuery(db_conn, "SELECT current_schema()")[[1]]

  if (length(parts) == 3) {
    list(catalog = parts[1], schema = parts[2], table = parts[3])
  } else if (length(parts) == 2) {
    list(catalog = conn_catalog, schema = parts[1], table = parts[2])
  } else {
    list(catalog = conn_catalog, schema = conn_schema, table = parts[1])
  }
}

#' Check if a Table Exists in Databricks Ignoring Case
#'
#' Performs a case-insensitive existence check for a Delta table in Databricks
#' by querying the `information_schema.tables` metadata. This function splits
#' the provided table name into catalog, schema, and table parts, resolves
#' defaults from the current session, and compares lowercased identifiers to
#' avoid issues with case sensitivity.
#'
#' @param db_conn A DBI-compatible database connection object connected to
#' Databricks.
#' @param table_name A character string specifying the table name to check.
#' Can be unqualified (`"table"`), partially qualified (`"schema.table"`), or
#' fully qualified (`"catalog.schema.table"`).
#'
#' @return Logical `TRUE` if the table exists (case-insensitive match),
#' otherwise `FALSE`.
#'
#' @details
#' - The function uses `resolve_table_parts()` to split the table name and fill
#' in missing catalog or schema using the current connection context.
#' - It queries the `information_schema.tables` in the resolved catalog and
#' compares `table_schema` and `table_name` in lowercase to handle case
#' insensitivity.
#' - If the metadata query fails, a warning is issued, and the function
#' returns `FALSE`.
#'
#' @examples
#' \dontrun{
#' db_exists_table_ignore_case(db_conn, "my_table")
#' db_exists_table_ignore_case(db_conn, "my_schema.my_table")
#' db_exists_table_ignore_case(db_conn, "my_catalog.my_schema.my_table")
#' }
#' @keywords internal
#' @import DBI
db_exists_table_ignore_case <- function(db_conn, table_name) {
  # Parse the fully qualified table name into catalog, schema, and
  # table components
  parts <- resolve_table_parts(table_name, db_conn)

  # Compose SQL to query information_schema.tables for case-insensitive match
  sql <- paste0(
    "SELECT table_name FROM ",
    DBI::dbQuoteIdentifier(db_conn, parts$catalog),
    ".information_schema.tables ",
    "WHERE lower(table_schema) = lower(",
    DBI::dbQuoteLiteral(db_conn, parts$schema), ") ",
    "AND lower(table_name) = lower(",
    DBI::dbQuoteLiteral(db_conn, parts$table), ")"
  )

  # Execute query safely, returning empty result on error with warning
  result <- tryCatch(
    {
      DBI::dbGetQuery(db_conn, sql)
    },
    error = function(e) {
      warning("Failed to query information_schema.tables: ", e$message)
      data.frame(table_name = character(0))
    }
  )

  # Return TRUE if one or more matching tables found; FALSE otherwise
  nrow(result) > 0
}

#' Count Rows in a Delta Table
#'
#' Executes a SQL `COUNT(*)` query on a specified Delta table to return the
#' total number of rows.
#'
#' @param target_table A character string specifying the name of the Delta
#' table. Can be unqualified (`"table"`), partially qualified
#' (`"schema.table"`), or fully qualified (`"catalog.schema.table"`).
#' If not fully qualified, the function resolves the catalog and/or schema from
#' the active database connection.
#' @param db_conn A database connection object, used to query the Delta table.
#'
#' @return An integer or numeric value representing the number of rows in the
#' specified table. Returns `NULL` if the query fails.
#'
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(odbc::databricks(),
#'   httpPath = Sys.getenv("DATABRICKS_SQL_PATH")
#' )
#' row_count <- count_delta_rows("catalog.schema.my_table", conn)
#' }
#' @keywords internal
#' @import DBI
count_delta_rows <- function(target_table, db_conn) {
  # Check that db_conn is a valid DBI connection
  validate_db_connection(db_conn)

  if (!db_exists_table_ignore_case(db_conn, target_table)) {
    stop(
      sprintf(
        "Table '%s' could not be found or is inaccessible. ",
        "Check that the table name is correct and you have USAGE permissions ",
        "on the parent catalog and schema.", target_table
      )
    )
  }

  # Count number of rows in target table
  count_sql <- paste0("SELECT COUNT(*) FROM ", target_table)

  # Try running the query
  result <- tryCatch(
    {
      DBI::dbGetQuery(db_conn, count_sql)[[1]]
    },
    error = function(e) {
      message("Count query failed: ", conditionMessage(e))
      NULL
    }
  )

  result
}

# --- 2. API & Volume Handling ----------------------------------------------
# These functions interact with the Databricks REST API for file management.

#' Perform an HTTP request with automatic retries
#'
#' This function performs an HTTP request using `httr2::req_perform()` and
#' automatically retries the request if an error occurs, such as network
#' timeouts or temporary server issues. It uses exponential backoff between
#' attempts.
#'
#' @param req A request object created with `httr2::request()`.
#' @param max_tries Maximum number of attempts to perform the request.
#' Default is 5.
#' @param wait_base Base of the exponential backoff used between retries
#' (in seconds). For example, if `wait_base = 2`, the wait time between retries
#' will be 2, 4, 8, ... seconds.
#'
#' @return The HTTP response object from `httr2::req_perform()` if successful.
#' If all attempts fail, an error is raised.
#'
#' @examples
#' \dontrun{
#' req <- httr2::request("https://example.com") |>
#'   httr2::req_method("GET")
#' response <- safe_req_perform(req)
#' }
#'
#' @keywords internal
#' @import httr2
safe_req_perform <- function(req, max_tries = 5, wait_base = 2) {
  # Try to perform the HTTP request up to max_tries times
  for (i in seq_len(max_tries)) {
    # Perform the request, catch errors as objects
    result <- tryCatch(
      req_perform(req),
      error = function(e) e
    )

    # If no error, return the successful response immediately
    if (!inherits(result, "error")) {
      return(result)
    }

    # If error occurred, log the failure message and prepare to retry
    message(sprintf("Attempt %d failed: %s", i, conditionMessage(result)))

    # If not the last attempt, wait before retrying
    if (i < max_tries) {
      sleep_time <- wait_base^i # Exponential backoff
      message(sprintf("Retrying after %d seconds...", sleep_time))
      Sys.sleep(sleep_time)
    }
  }

  # If all attempts failed, stop with an error
  stop("All upload attempts failed after ", max_tries, " tries.")
}

#' Check if a Databricks Volume Exists
#'
#' This function checks whether a Databricks Unity Catalog volume exists.
#' It converts a standard volume path (e.g., `/Volumes/catalog/schema/volume`)
#' to the fully qualified volume name (`catalog.schema.volume`) required by the
#' Databricks REST API and performs a GET request. Transient connection issues
#' are automatically retried using `safe_req_perform()`.
#'
#' @param volume_dir Character. The full path to the Databricks volume in the
#' format `/Volumes/catalog/schema/volume/...`. Only the first three path
#' components after `/Volumes/` are used to identify the volume.
#'
#' @return Logical. `TRUE` if the volume exists, `FALSE` if the volume does not
#' exist. Throws an error for unexpected HTTP statuses or missing environment
#' variables.
#'
#' @details
#' The function requires the environment variables `DATABRICKS_HOST` and
#' `DATABRICKS_TOKEN` to be set for authenticating API requests. A 404 response
#' is interpreted as "volume does not exist", while other HTTP statuses
#' (e.g., 500, 403) will cause an error.
#'
#' @examples
#' \dontrun{
#' volume_exists("/Volumes/my_catalog/my_schema/my_volume")
#' }
#'
#' @keywords internal
#' @import httr2
volume_exists <- function(volume_dir) {
  # Read Databricks host and token from environment
  databricks_host <- Sys.getenv("DATABRICKS_HOST")
  databricks_token <- Sys.getenv("DATABRICKS_TOKEN")

  if (databricks_host == "" || databricks_token == "") {
    stop(
      "DATABRICKS_HOST and DATABRICKS_TOKEN must be set in the environment.",
      call. = FALSE
    )
  }

  # Convert /Volumes/catalog/schema/volume/... to catalog.schema.volume
  parts <- strsplit(volume_dir, "/", fixed = TRUE)[[1]]
  if (length(parts) < 5 || parts[2] != "Volumes") {
    stop("Invalid Databricks volume path: ", volume_dir, call. = FALSE)
  }
  volume_name <- paste(parts[3], parts[4], parts[5], sep = ".")

  # Construct the GET request to the Databricks Unity Catalog volumes API
  req <- request(
    paste0(databricks_host, "/api/2.1/unity-catalog/volumes/", volume_name)
  ) |>
    req_auth_bearer_token(databricks_token) |> # Authenticate using bearer token
    req_method("GET") |> # HTTP GET
    req_timeout(30) |> # Timeout after 30s
    req_error(is_error = ~FALSE) # Prevent 404 from throwing an error

  # Perform the request with retries for transient connection errors
  res <- safe_req_perform(req)

  # Extract HTTP status code
  status <- resp_status(res)

  # Return TRUE if volume exists, FALSE if 404, otherwise throw an error
  if (status == 200) {
    TRUE
  } else if (status == 404) {
    FALSE
  } else {
    stop("Unexpected HTTP status ", status, ": ", resp_body_string(res))
  }
}

#' Upload a Local File to a Databricks Volume
#'
#' Uploads a local file to a specified path in a Databricks Volume using the
#' Databricks REST API (`/api/2.0/fs/files`). Retries up to 5 times with
#' exponential backoff if the upload fails.
#'
#' @param local_file Path to the local file to upload.
#' @param volume_file Full target path in the Databricks Volume, e.g.,
#'   `/Volumes/catalog/schema/volume_name/filename.parquet`.
#'
#' @return None. Stops with an error if the upload fails.
#'
#' @examples
#' \dontrun{
#' upload_to_volume(
#'   "local/path/file.parquet",
#'   "/Volumes/catalog/schema/volume_name/file.parquet"
#' )
#' }
#'
#' @keywords internal
#' @import httr2
upload_to_volume <- function(local_file, volume_file) {
  # Set Databricks host and token for file uploads
  databricks_host <- Sys.getenv("DATABRICKS_HOST")
  databricks_token <- Sys.getenv("DATABRICKS_TOKEN")

  upload_url <- paste0(
    databricks_host, "/api/2.0/fs/files",
    utils::URLencode(volume_file)
  )

  req <- request(upload_url) |>
    req_method("PUT") |>
    req_headers(Authorization = paste("Bearer", databricks_token)) |>
    req_body_file(local_file) |>
    # to aid debugging, add: verbose = TRUE
    req_options(connecttimeout = 120, timeout = 600) |>
    req_progress(type = "up")

  res_upload <- safe_req_perform(req)

  # Check if the upload was successful
  if (resp_status(res_upload) != 204) {
    stop("Upload to Volume failed: ", resp_body_string(res_upload))
  } else {
    message("Uploaded to Volume successfully!")
  }
}

#' Delete a File from a Databricks Volume
#'
#' Deletes a file from a specified Databricks Volume path using the
#' REST API (`/api/2.0/fs/files`). Retries the request with exponential
#' backoff if it fails.
#'
#' @param volume_file Full path of the file in the Databricks Volume to delete,
#'   e.g., `/Volumes/catalog/schema/volume_name/file.parquet`.
#'
#' @return None. A message is printed on success; a warning is issued if
#' deletion fails.
#'
#' @examples
#' \dontrun{
#' delete_from_volume(
#'   "/Volumes/catalog/schema/volume_name/file_to_delete.parquet"
#' )
#' }
#'
#' @keywords internal
#' @import httr2
delete_from_volume <- function(volume_file) {
  # Set Databricks host and token for file deletion
  databricks_host <- Sys.getenv("DATABRICKS_HOST")
  databricks_token <- Sys.getenv("DATABRICKS_TOKEN")

  delete_url <- paste0(
    databricks_host, "/api/2.0/fs/files",
    utils::URLencode(volume_file)
  )

  req <- request(delete_url) |>
    req_method("DELETE") |>
    req_auth_bearer_token(databricks_token) |>
    req_timeout(60) # timeout in seconds

  res_del <- safe_req_perform(req)

  if (resp_status(res_del) != 204) {
    warning("Failed to delete: ", volume_file)
  } else {
    message("Deleted: ", volume_file)
  }
}

# --- 3. SQL Execution ------------------------------------------------------
# These functions perform the final data movement into Delta tables.

#' Create or Replace a Delta Table in Databricks
#'
#' This function generates and executes a `CREATE OR REPLACE TABLE` SQL
#' statement in Databricks, using the schema inferred from either an R data
#' frame or an Arrow schema. The resulting table is stored in Delta Lake format.
#'
#' The function automatically maps column types from R or Arrow to appropriate
#' Spark SQL types:
#'  - **R types**: \code{integer} → INT, \code{integer64} → BIGINT,
#'         \code{numeric} → DOUBLE, \code{character/factor} → STRING,
#'         \code{logical} → BOOLEAN, \code{Date} → DATE,
#'         \code{POSIXct/POSIXlt} → TIMESTAMP or TIMESTAMP_NTZ.
#'  - **Arrow types**: int8/int16 → TINYINT/SMALLINT, int32/int64 → INT/BIGINT,
#'         float/double → FLOAT/DOUBLE, string/large_string → STRING,
#'         bool → BOOLEAN, \code{date32[day]} → DATE,
#'         \code{timestamp[...]} → TIMESTAMP/TIMESTAMP_NTZ,
#'         decimal(P,S) → DECIMAL(P,S).
#'
#' Timestamps are mapped to either `TIMESTAMP_NTZ` (no timezone) or `TIMESTAMP`
#' (with timezone). Unsupported types fall back to `STRING`.
#'
#' @param df_or_schema An R data frame or an Arrow `Schema` object whose
#' structure defines the schema of the Delta table.
#' @param target_table A character string specifying the name of the Delta
#' table. Can be unqualified (`"table"`), partially qualified
#' (`"schema.table"`), or fully qualified (`"catalog.schema.table"`). If not
#' fully qualified, the function resolves the catalog and/or schema from the
#' active database connection.
#' @param db_conn A DBI database connection object to Databricks.
#'
#' @return None. The function executes the SQL statement to create or replace
#' the Delta table.
#'
#' @examples
#' \dontrun{
#' # Using a data frame
#' con <- DBI::dbConnect(odbc::databricks(),
#'   httpPath = Sys.getenv("DATABRICKS_SQL_PATH")
#' )
#' df <- data.frame(
#'   id = 1:5,
#'   name = letters[1:5],
#'   score = c(9.5, 8.3, 7.2, 6.8, 9.0)
#' )
#' create_empty_delta(df, "catalog.schema.my_table", con)
#'
#' # Using an Arrow schema
#' library(arrow)
#' schema_example <- schema(
#'   id = int32(),
#'   name = utf8(),
#'   score = float32()
#' )
#' create_empty_delta(schema_example, "catalog.schema.my_arrow_table", con)
#' }
#'
#' @keywords internal
#' @import DBI
#' @importFrom dplyr coalesce
create_empty_delta <- function(df_or_schema, target_table, db_conn) {
  # Function to map a single column to a Spark SQL type
  map_type <- function(col) {
    # If the column is an Arrow schema Field
    if (inherits(col, "Field")) {
      type_str <- col$type$ToString() # Get Arrow type as string

      # Handle timestamps generically
      # Supports any timestamp precision and optional timezone
      if (grepl("^timestamp\\[.*\\]$", type_str)) {
        if (grepl(", tz=", type_str)) {
          return("TIMESTAMP") # Column has timezone => TIMESTAMP
        } else {
          return("TIMESTAMP_NTZ") # No timezone => TIMESTAMP_NTZ
        }
      }

      # Handle Arrow Decimal types (often used for precision)
      if (grepl("^decimal", type_str)) {
        matches <- regmatches(
          type_str,
          regexec(
            "decimal[0-9]+\\(([0-9]+),\\s*([0-9]+)\\)",
            type_str
          )
        )
        if (length(matches[[1]]) == 3) {
          return(paste0(
            "DECIMAL(", matches[[1]][2], ", ", matches[[1]][3],
            ")"
          ))
        } else {
          return("DECIMAL") # fallback if parsing fails
        }
      }

      # Map other Arrow types to Spark SQL types
      switch(type_str,
        "int8" = "TINYINT",
        "int16" = "SMALLINT",
        "int32" = "INT",
        "int64" = "BIGINT",
        "float" = "FLOAT",
        "double" = "DOUBLE",
        "string" = "STRING",
        "large_string" = "STRING",
        "bool" = "BOOLEAN",
        "date32[day]" = "DATE",
        "STRING"
      ) # Default fallback type
    } else { # Column is an R data frame column

      rtype <- class(col)[1] # Get base R type
      switch(rtype,
        "integer" = "INT",
        "integer64" = "BIGINT",
        "numeric" = "DOUBLE",
        "character" = "STRING",
        "factor" = "STRING",
        "logical" = "BOOLEAN",
        "Date" = "DATE",
        "POSIXct" = ifelse(coalesce(attr(col, "tzone"), "") == "",
          "TIMESTAMP_NTZ", "TIMESTAMP"
        ),
        "POSIXlt" = ifelse(coalesce(attr(as.POSIXct(col), "tzone"), "") == "",
          "TIMESTAMP_NTZ", "TIMESTAMP"
        ),
        "STRING"
      ) # Default fallback
    }
  }

  # Determine Spark types and names for all columns
  if (inherits(df_or_schema, "data.frame") ||
        inherits(df_or_schema, "tbl_df")) {
    # Map each data frame column
    spark_types <- sapply(df_or_schema, map_type)
  } else if (inherits(df_or_schema, "Schema")) {
    # Map each Arrow schema field
    spark_types <- vapply(
      df_or_schema$fields, function(f) map_type(f),
      character(1)
    )
    names(spark_types) <- vapply(
      df_or_schema$fields, function(f) f$name,
      character(1)
    )
  } else {
    stop("Input must be a data frame or Arrow Schema object.")
  }

  # Construct SQL for creating the Delta table
  schema_string <- paste0("`", names(spark_types), "` ", spark_types,
    collapse = ", "
  )
  create_sql <- paste0(
    "CREATE OR REPLACE TABLE ", target_table,
    " (", schema_string,
    ") USING DELTA TBLPROPERTIES ('delta.feature.timestampNtz' = 'supported');"
  )

  # Print messages for debugging/confirmation
  message("Creating or replacing table: ", target_table)
  message(create_sql)

  tryCatch(
    {
      # Execute the SQL statement via DBI connection
      DBI::dbExecute(db_conn, create_sql)
    },
    error = function(e) {
      # Check for the specific Unity Catalog Insufficient Privileges error
      # (SQLSTATE: 42501)
      if (grepl("42501", e$message) || grepl(
        "INSUFFICIENT_PERMISSIONS",
        e$message
      )) {
        stop(sprintf(
          "DBI Execution Failed: Insufficient Unity Catalog WRITE privileges. ",
          "\nYou need 'USE CATALOG' privilege on the target catalog and ",
          "'CREATE TABLE' privilege on the target schema to execute ",
          "'CREATE OR REPLACE TABLE %s'.",
          target_table
        ), call. = FALSE)
      } else {
        # Re-throw any other unexpected error
        stop(e$message, call. = FALSE)
      }
    }
  )
}

#' Load Parquet Data into a Delta Table using COPY INTO
#'
#' This function executes a `COPY INTO` SQL command to load data from a Parquet
#' file in a Databricks Volume into a Delta Lake table.
#'
#' @param target_table A character string specifying the name of the Delta
#' table. Can be unqualified (`"table"`), partially qualified
#' (`"schema.table"`), or fully qualified (`"catalog.schema.table"`).
#' If not fully qualified, the function resolves the catalog and/or schema from
#' the active database connection.
#' @param volume_file A character string with the full path to the Parquet file
#'   in a Databricks Volume (e.g., `/Volumes/.../data.parquet`).
#' @param db_conn A DBI database connection object to Databricks.
#' @param copy_options A character string of key-value pairs to customise the
#'   `COPY INTO` behaviour. Defaults to `'mergeSchema' = 'true'`.
#'
#' @return The result of executing the `COPY INTO` SQL command.
#'
#' @examples
#' \dontrun{
#' con <- DBI::dbConnect(odbc::databricks(),
#'   httpPath = Sys.getenv("DATABRICKS_SQL_PATH")
#' )
#' copy_into_delta(
#'   "catalog.schema.my_table",
#'   "/Volumes/my_volume/data_file.parquet",
#'   con
#' )
#' }
#'
#' @keywords internal
#' @import DBI
copy_into_delta <- function(target_table, volume_file, db_conn,
                            copy_options = "'mergeSchema' = 'true'") {
  # Prepare the COPY INTO SQL statement for loading the data into the Delta Lake
  # table
  copy_sql <- paste0(
    "COPY INTO ", target_table, "\n",
    "FROM '", volume_file, "' \n",
    "FILEFORMAT = PARQUET \n",
    "COPY_OPTIONS (", copy_options, ")\n"
  )

  message("Executing COPY INTO...")
  message(copy_sql)


  tryCatch(
    {
      # Execute the SQL statement via DBI connection
      result <- DBI::dbExecute(db_conn, copy_sql)
      message("COPY INTO executed successfully. Result: ", result)
      return(result)
    },
    error = function(e) {
      # Capture the full, raw error message string from the exception object
      error_message <- e$message

      # --- 1. Check for Permissions Errors (SQLSTATE: 42501 or general
      # INSUFFICIENT_PRIVILEGES) ---
      if (grepl("42501", error_message) || grepl(
        "INSUFFICIENT_PERMISSIONS",
        error_message
      )) {
        stop(sprintf(
          "DBI Execution Failed: Insufficient Unity Catalog READ/WRITE ",
          "privileges.\nCheck if you have 'SELECT' on the volume and 'MODIFY'",
          "on the target table (%s).",
          target_table
        ), call. = FALSE)
      }

      # --- 2. Check for Schema/Data Incompatibility Errors (Targeting Merge
      # and Type Conflicts) ---
      if (grepl("PARQUET_TYPE_ILLEGAL", error_message, ignore.case = TRUE) ||
            grepl("DELTA_FAILED_TO_MERGE_FIELDS", error_message,
                  ignore.case = TRUE) ||
            grepl("42846", error_message) ||
            grepl("22005", error_message)) {
        # The full message to display, ensuring all details are included
        full_error_detail <- paste0(
          "\n===============================================================\n",
          "COPY INTO Failed: Schema Mismatch (Failed to merge fields / ",
          "Illegal Parquet type).\n",
          "Cause: Data types in the Parquet file are incompatible with ",
          "the target Delta table's schema.\n",
          "Action: Ensure data types match exactly.\n\n",
          "RAW SERVER TRACE: Inspect the detailed error below for ",
          "conflicting field(s).\n",
          "-----------------------------------------------------------------\n",
          e,
          "\n===============================================================\n"
        )

        # Use cat() to print the entire detailed message to the console's error
        # stream (guaranteed visibility)
        cat(full_error_detail, file = stderr())

        # Then, use a short, simple stop() message to halt execution cleanly
        stop("COPY INTO failed due to Schema Mismatch. ",
          "See details above in 'RAW SERVER TRACE'.",
          call. = FALSE
        )
      }

      # --- 3. Re-throw any other unexpected error ---
      stop(paste(
        "COPY INTO execution failed with an unexpected error:",
        error_message
      ), call. = FALSE)
    }
  )
}
