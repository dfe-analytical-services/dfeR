## Code to prepare `write_df_to_delta_stress_test` dataset
# ==============================================================================
# NOTE: This script requires specific Databricks access permissions.
# Other DfE analysts will need to update the Catalog, Schema, and Volume
# variables below to match their own dev environment.
# ==============================================================================
# STRESS TEST DOCUMENTATION
#
# DESCRIPTION:
# A list of microbenchmark results for extreme scales, ranging from
# 100 to 1 billion rows.
#
# ENVIRONMENT SPECS:
# - Machine: DfE High Memory Desktop (AVD)
# - CPU: AMD EPYC 7763 64-Core Processor (16 cores allocated)
# - RAM: 137 GB
#
# TEST DATA SCHEMA:
# Same as the Benchmarking Results (Int, Numeric, Char, Factor, Logic, Date,
# Time).
#
# FORMAT:
# A named list of 8 microbenchmark objects (100 to 1e+09 rows).
# Each object contains 5 evaluations of `write_df_to_delta`.
# ==============================================================================

# Load packages
library(usethis)
library(DBI)
library(odbc)
library(microbenchmark)
devtools::load_all()

# Configuration
db_catalog <- "catalog_40_copper_student_finance_modelling_unit"
db_schema  <- "sfmu"
db_volume  <-
  "/Volumes/catalog_40_copper_student_finance_modelling_unit/sfmu/sfmu_volume"

# Set up Databricks connection
con <- DBI::dbConnect(
  odbc::databricks(),
  httpPath       = Sys.getenv("DATABRICKS_SQL_PATH"),
  catalog        = db_catalog,
  schema         = db_schema,
  useNativeQuery = FALSE
)

# Define our powers of 10
scales <- 10^(2:9)
write_df_to_delta_stress_test <- list()

for (n in scales) {
  message(sprintf("Starting trials for 10^%d...", log10(n)))

  # Create test data set
  test_data <- data.frame(
    int = sample(1:10000, size = n, replace = TRUE),
    numeric = rnorm(n),
    character = sample(state.abb, size = n, replace = TRUE),
    factor = factor(sample(c("High", "Medium", "Low"), n, replace = TRUE)),
    logical = sample(c(TRUE, FALSE, NA), n, replace = TRUE),
    date = as.Date("2020-01-01") + (1:n),
    time = as.POSIXct("2025-01-01 00:00:00", tz = "UTC")  + (1:n)
  )

  # Run 5 iterations
  bm <- microbenchmark(
    "dfeR::write_df_to_delta" = {
      suppressMessages(
        write_df_to_delta(test_data,
                          target_table = "temp_dfe",
                          db_conn = con,
                          volume_dir = db_volume,
                          overwrite_table = TRUE)
      )
    },
    times = 5,
    unit = "s"
  )

  write_df_to_delta_stress_test[[as.character(n)]] <- bm

  # Free up memory for the next (larger) scale
  rm(test_data)
  gc() # Force R to release RAM to the OS
}

# Delete temp table
DBI::dbRemoveTable(con, "temp_dfe")

# Close the connection
DBI::dbDisconnect(con)

# Write the stress test results into the package
usethis::use_data(write_df_to_delta_stress_test, overwrite = TRUE,
                  internal = TRUE)
