context("sql_conn_string")

test_that("Basic test case works", {
  expect(is.character(sql_conn_string("database","server")), "Output not a string")
})

test_that("Example Database as Expected", {
  expect_equal(sql_conn_string("3DCPRI-PDB16\\ACSQLS", "SWFC_Project"),
  "driver={SQL Server};server=3DCPRI-PDB16\\ACSQLS;database=SWFC_Project;trusted_connection=TRUE")
})

test_that("Deals with non character server variable gracefully", {
  expect_error(sql_conn_string(1, "database"), "server parmaeter must be of type character")
})

test_that("Deals with non character database variable gracefully", {
  expect_error(sql_conn_string("server", data.frame(a = 1)), "database parmaeter must be of type character")
})

context("read_sql_script")

test_that("Unclean Query Read in correctly", {
  expect_equal(read_sql_script("data/unclean_query.sql"), "Select * From Schema.TableName")
})

