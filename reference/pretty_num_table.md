# Format a data frame with `dfeR::pretty_num()`.

You can format number and character values in a data frame by passing
arguments to
[`dfeR::pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md).
Use parameters `include_columns` or `exclude_columns` to specify columns
for formatting.

## Usage

``` r
pretty_num_table(data, include_columns = NULL, exclude_columns = NULL, ...)
```

## Arguments

- data:

  A data frame containing the columns to be formatted.

- include_columns:

  A character vector specifying which columns to format. If `NULL`
  (default), all columns will be considered for formatting.

- exclude_columns:

  A character vector specifying columns to exclude from formatting. If
  `NULL` (default), no columns will be excluded. If both
  `include_columns` and `exclude_columns` are provided ,
  `include_columns` takes precedence.

- ...:

  Additional arguments passed to
  [`dfeR::pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md)
  , such as `dp` (decimal places) for controlling the number of decimal
  points.

## Value

A data frame with columns formatted using
[`dfeR::pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md).

## Details

The function first checks if any columns are specified for inclusion via
`include_columns`. If none are provided, it checks if columns are
specified for exclusion via `exclude_columns`. If neither is specified,
all columns in the data frame are formatted.

## See also

[`pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md)

Other prettying:
[`pretty_filesize()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_filesize.md),
[`pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md),
[`pretty_time()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time.md),
[`pretty_time_taken()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time_taken.md)

## Examples

``` r
# Example data frame
df <- data.frame(
  a = c(1.234, 5.678, 9.1011),
  b = c(10.1112, 20.1314, 30.1516),
  c = c("A", "B", "C")
)

# Apply formatting to all columns
pretty_num_table(df, dp = 2)
#>      a     b  c
#> 1 1.23 10.11 NA
#> 2 5.68 20.13 NA
#> 3 9.10 30.15 NA

# Apply formatting to only selected columns
pretty_num_table(df, include_columns = c("a"), dp = 2)
#>      a       b c
#> 1 1.23 10.1112 A
#> 2 5.68 20.1314 B
#> 3 9.10 30.1516 C

# Apply formatting to all columns except specified ones
pretty_num_table(df, exclude_columns = c("b"), dp = 2)
#>      a       b  c
#> 1 1.23 10.1112 NA
#> 2 5.68 20.1314 NA
#> 3 9.10 30.1516 NA

# Apply formatting to all columns except specified ones and
# provide alternative value for NAs
pretty_num_table(df, alt_na = "[z]", exclude_columns = c("b"), dp = 2)
#>      a       b   c
#> 1 1.23 10.1112 [z]
#> 2 5.68 20.1314 [z]
#> 3 9.10 30.1516 [z]
```
