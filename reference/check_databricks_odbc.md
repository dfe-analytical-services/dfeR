# Check Databricks ODBC connection variables

Checks if the required environment variables for connecting to
Databricks are set, and if the `odbc` package version is sufficient.

## Usage

``` r
check_databricks_odbc()
```

## Value

TRUE if the connection is set up correctly, FALSE otherwise.

## Details

Prints instructions for fixing common problems to the console.

## Examples

``` r
check_databricks_odbc()
#> ✖ The odbc package is not installed.
#> 
#> 
#> Please install it by running:
#> 
#> 
#> `install.packages('odbc')`
```
