test_that("write_df_to_delta returns TRUE on a successful end-to-end run", {
  # Setup
  withr::local_envvar(
    DATABRICKS_HOST = "https://adb-1234.fake.databricks.com",
    DATABRICKS_TOKEN = "dapi_fake_token_12345",
    DATABRICKS_SQL_PATH = "sql/protocol/v1/o/fake"
  )
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  # Mocking
  local_mocked_bindings(
    validate_db_connection = function(...) TRUE,
    volume_exists = function(...) TRUE,
    db_exists_table_ignore_case = function(...) TRUE,
    upload_to_volume = function(...) TRUE,
    create_empty_delta = function(...) TRUE,
    copy_into_delta = function(...) TRUE,
    delete_from_volume = function(...) TRUE,
    resolve_table_parts = function(...) {
      list(catalog = "cat", schema = "sch", table = "tab")
    },
    count_delta_rows = mockery::mock(0, 150)
  )

  # Execute
  result <- suppressMessages(
    write_df_to_delta(
      df = iris,
      target_table = "cat.sch.tab",
      db_conn = fake_con,
      volume_dir = "/Volumes/catalog/schema/volume",
      overwrite_table = TRUE
    )
  )

  # Assert
  expect_true(result)
})

test_that("write_df_to_delta stops on invalid input types", {
  # Setup a fake connection object
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  # Mock the connection validation so the function doesn't crash on the DBI call
  local_mocked_bindings(
    validate_db_connection = function(...) TRUE
  )

  # Test 1: df is not a dataframe
  expect_error(
    write_df_to_delta(df = "not_a_df", "tab", fake_con, volume_dir = "/path"),
    "Input data must be a data frame"
  )

  # Test 2: empty dataframe
  expect_error(
    write_df_to_delta(df = data.frame(), "tab", fake_con, volume_dir = "/path"),
    "data frame is empty"
  )

  # Test 3: invalid volume_dir
  expect_error(
    write_df_to_delta(iris, "tab", fake_con, volume_dir = NULL),
    "must be a non-NULL string"
  )
})

test_that("write_df_to_delta stops if volume or table is missing", {
  # Setup a fake connection object
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  # Mock connection so we can reach Volume checks
  local_mocked_bindings(validate_db_connection = function(...) TRUE)

  # Test 1: Volume does not exist
  local_mocked_bindings(volume_exists = function(...) FALSE)
  expect_error(
    write_df_to_delta(iris, "tab", fake_con, volume_dir = "/wrong/path"),
    "Target volume .* does not exist"
  )

  # Test 2: Table does not exist and overwrite is FALSE
  local_mocked_bindings(
    volume_exists = function(...) TRUE,
    db_exists_table_ignore_case = function(...) FALSE
  )
  expect_error(
    write_df_to_delta(iris, "new_tab", fake_con, volume_dir = "/path",
                      overwrite_table = FALSE),
    "Target table does not exist and overwrite_table = FALSE"
  )
})

test_that("write_df_to_delta triggers table creation when overwrite is TRUE", {
  # SETUP: Create a dummy connection object
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  # SPY: Create a mock 'spy' to track if the table creation function is called
  m_create <- mockery::mock(TRUE)

  local_mocked_bindings(
    # Bypass the S4 DBI::dbIsValid crash
    validate_db_connection = function(...) TRUE,
    # Simulate a healthy Databricks environment
    volume_exists = function(...) TRUE,
    db_exists_table_ignore_case = function(...) TRUE,
    # Plug in our 'spy' mock here
    create_empty_delta = m_create,
    # Stub out the remaining side-effect functions
    upload_to_volume = function(...) TRUE,
    copy_into_delta = function(...) TRUE,
    delete_from_volume = function(...) TRUE,
    count_delta_rows = mockery::mock(0, 150)
  )

  # EXECUTE: Run with overwrite_table = TRUE
  suppressMessages(
    write_df_to_delta(
      df = iris,
      target_table = "tab",
      db_conn = fake_con,
      volume_dir = "/path",
      overwrite_table = TRUE
    )
  )

  # ASSERT: Verify that create_empty_delta was called exactly once
  # because overwrite_table was TRUE
  mockery::expect_called(m_create, 1)
})

test_that("write_df_to_delta returns FALSE if copy step fails", {
  # SETUP: Create a dummy connection object
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  local_mocked_bindings(
    # Standard mocks for a issue-free path until we reach the SQL execution
    validate_db_connection = function(...) TRUE,
    volume_exists = function(...) TRUE,
    db_exists_table_ignore_case = function(...) TRUE,
    upload_to_volume = function(...) TRUE,
    # INJECT FAILURE: Force the COPY INTO command to return FALSE
    copy_into_delta = function(...) FALSE,
    delete_from_volume = function(...) TRUE,
    # Simulate no change in row counts
    count_delta_rows = mockery::mock(10, 10)
  )

  # EXECUTE: Capture the invisible return value
  # Again, volume_dir is named to prevent positional argument errors
  result <- suppressMessages(
    write_df_to_delta(
      df = iris,
      target_table = "tab",
      db_conn = fake_con,
      volume_dir = "/path"
    )
  )

  # ASSERT: The function should pass through the failure of copy_into_delta
  expect_false(result)
})

test_that("write_df_to_delta handles multiple chunks correctly", {
  # Create a dummy connection object
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  # We use a function mock or 'cycle = TRUE' so it can be called many times
  m_upload <- mockery::mock(TRUE, cycle = TRUE)

  local_mocked_bindings(
    validate_db_connection = function(...) TRUE,
    volume_exists = function(...) TRUE,
    db_exists_table_ignore_case = function(...) TRUE,
    create_empty_delta = function(...) TRUE,
    upload_to_volume = m_upload,
    copy_into_delta = function(...) TRUE,
    delete_from_volume = function(...) TRUE,
    # Provide two values here because the function calls this twice (start/end)
    count_delta_rows = mockery::mock(0, 150)
  )

  # 2. Execute with a tiny chunk size to force multiple loops
  # object.size(iris) is ~7000 bytes, so 1000 bytes will force ~7 chunks
  suppressMessages(
    write_df_to_delta(
      df = iris,
      target_table = "tab",
      db_conn = fake_con,
      volume_dir = "/path",
      chunk_size_bytes = 1000,
      overwrite_table = TRUE
    )
  )

  # 3. ASSERT: Check that the upload was called more than once
  # This proves the chunking logic actually split the data
  args <- mockery::mock_args(m_upload)
  expect_gt(length(args), 1)
})

test_that("write_df_to_delta applies arrow schema and converts factors", {
  # Create a dummy connection object
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  # Create a dummy dataframe with a factor
  test_df <- data.frame(a = factor("label"), b = 1)
  # Create a simple arrow schema
  test_schema <- arrow::schema(a = arrow::utf8(), b = arrow::int32())

  # Mocking
  local_mocked_bindings(
    validate_db_connection = function(...) TRUE,
    volume_exists = function(...) TRUE,
    db_exists_table_ignore_case = function(...) TRUE,
    upload_to_volume = function(...) TRUE,
    copy_into_delta = function(...) TRUE,
    delete_from_volume = function(...) TRUE,
    count_delta_rows = mockery::mock(0, 1)
  )

  # If this runs without error, it means the factor conversion
  # and as_arrow_table(schema = ...) logic is sound.
  result <- suppressMessages(
    write_df_to_delta(test_df, "tab", fake_con,
      volume_dir = "/path",
      column_types_schema = test_schema
    )
  )
  expect_true(result)
})

test_that("write_df_to_delta correctly reports row count matches", {
  # Create a dummy connection object
  fake_con <- structure(list(),
                        class = c("Databricks", "odbc", "DBIConnection"))

  # Mocking
  local_mocked_bindings(
    validate_db_connection = function(...) TRUE,
    volume_exists = function(...) TRUE,
    db_exists_table_ignore_case = function(...) TRUE,
    upload_to_volume = function(...) TRUE,
    copy_into_delta = function(...) TRUE,
    delete_from_volume = function(...) TRUE,
    # Simulate: started with 10 rows, ended with 160 (150 added)
    count_delta_rows = mockery::mock(10, 160)
  )

  # Capture messages to see if our row-matching logic is correct
  messages <- capture_messages({
    write_df_to_delta(iris, "tab", fake_con, volume_dir = "/path")
  })

  # iris has 150 rows. Our mock says 150 were added.
  expect_match(paste(messages, collapse = " "),
               "Matches number of rows in data frame: TRUE")
})
