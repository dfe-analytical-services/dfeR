# Write a Data Frame to Delta Lake with COPY INTO

This function writes a large R data frame or tibble (`df`) to a Delta
Lake table (`target_table`) on Databricks using Databricks Volumes and
the `COPY INTO` SQL command.

## Usage

``` r
write_df_to_delta(
  df,
  target_table,
  db_conn,
  column_types_schema = NULL,
  volume_dir,
  copy_options = "'mergeSchema' = 'true'",
  overwrite_table = FALSE,
  chunk_size_bytes = 5 * 1024^3
)
```

## Arguments

- df:

  A `data.frame` or `tibble` containing the data to be written to Delta
  Lake.

- target_table:

  A character string specifying the name of the Delta table. Can be
  unqualified (`"table"`), partially qualified (`"schema.table"`), or
  fully qualified (`"catalog.schema.table"`). If not fully qualified,
  the function resolves the catalog and/or schema from the active
  database connection.

- db_conn:

  A valid DBI connection object to Databricks. This connection is used
  to interact with the Delta table.

- column_types_schema:

  An optional Arrow Schema object (created via `arrow::schema(...)`)
  used to explicitly enforce precise data types during Parquet
  conversion. Defaults to `NULL`. If `NULL`, data types are inferred
  from the R data frame.

  Type mapping reference (Arrow schema field → Spark SQL type):

  - Arrow int8/int16 → TINYINT/SMALLINT

  - Arrow int32/int64 → INT/BIGINT

  - Arrow float/double → FLOAT/DOUBLE

  - Arrow string/large_string → STRING

  - Arrow bool → BOOLEAN

  - Arrow `date32[day]` → DATE

  - Arrow `timestamp['s' | 'ms' | 'us', ...]` → TIMESTAMP_NTZ (no
    timezone)

  - Arrow `timestamp['s' | 'ms' | 'us', tz = ...]` → TIMESTAMP (with
    timezone)

  - Arrow decimal(P,S) → DECIMAL(P,S)

  Important notes for schema use:

  - Factors: If the R data frame contains a `factor` column, the
    corresponding Arrow schema field must be `utf8()` or `large_utf8()`.
    The categorical labels are automatically converted and mapped to a
    `STRING` type in the Delta table.

  - Timestamp precision: Second (`s`), millisecond (`ms`), and
    microsecond (`us`) precisions are supported. Nanosecond (`ns`)
    precision may be incompatible with the current Databricks runtime
    environment.

- volume_dir:

  A character string specifying the path to the target Databricks Volume
  where the Parquet file will be uploaded.

- copy_options:

  A character string specifying options for the `COPY INTO` command,
  e.g., `'mergeSchema' = 'true'`. Defaults to
  `"'mergeSchema' = 'true'"`.

- overwrite_table:

  Logical; if `TRUE`, deletes and recreates the Delta table before
  import. If `FALSE` and the table does not exist, the function will
  throw an error. Defaults to `FALSE`.

- chunk_size_bytes:

  An integer specifying the size of each data chunk in bytes. This is
  used to split the data frame into smaller chunks for uploading.
  Defaults to 5GB.

## Value

Invisibly returns the result of the `COPY INTO` execution.

## Details

The function performs the following steps:

- Optionally overwrites the target table.

- Uploads the data as Parquet file(s) to a specified Databricks Volume.

- Executes a `COPY INTO` command to load the file(s) into Delta Lake.

- Deletes the temporary file(s) from the Volume after loading is
  complete.

Data is chunked into segments during upload to accommodate the
Databricks REST API limit of 5 GB per single file upload.

## Note

To use this function, users must ensure that they have appropriate
Databricks permissions:

- **Catalog/schema**: `USE CATALOG` on the target catalog and
  `USE SCHEMA` on the target schema.

- **Table creation**: `CREATE TABLE` on the target schema (if
  `overwrite_table = TRUE`) or `MODIFY` and `SELECT` on the existing
  table.

- **Volume access**: `READ VOLUME` and `WRITE VOLUME` on the Databricks
  Volume used for staging (specified in `volume_dir`).

Moreover, this function requires valid `.Renviron` variables for
authentication, specifically `DATABRICKS_TOKEN` and `DATABRICKS_HOST`.

## See also

Other databricks:
[`check_databricks_odbc()`](https://dfe-analytical-services.github.io/dfeR/reference/check_databricks_odbc.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Setup connection using environment variables
con <- DBI::dbConnect(odbc::databricks(),
  httpPath = Sys.getenv("DATABRICKS_SQL_PATH")
)

write_df_to_delta(
  df = my_data,
  target_table = "catalog.schema.my_table",
  db_conn = con,
  volume_dir = "/Volumes/catalog/schema",
  overwrite_table = TRUE
)
} # }
```
