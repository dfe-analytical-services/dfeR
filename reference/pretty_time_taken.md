# Calculate elapsed time between two points and present prettily

Converts a start and end value to a readable time format.

## Usage

``` r
pretty_time_taken(start_time, end_time)
```

## Arguments

- start_time:

  start time readable by as.POSIXct

- end_time:

  end time readable by as.POSIXct

## Value

string containing prettified elapsed time

## Details

Designed to be used with Sys.time() when tracking start and end times.

Shows as seconds up until 119 seconds, then minutes until 119 minutes,
then hours for anything larger.

Input start and end times must be convertible to POSIXct format.

## See also

[`comma_sep()`](https://dfe-analytical-services.github.io/dfeR/reference/comma_sep.md)
[`round_five_up()`](https://dfe-analytical-services.github.io/dfeR/reference/round_five_up.md)
[`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html)

Other prettying:
[`pretty_filesize()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_filesize.md),
[`pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md),
[`pretty_num_table()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num_table.md),
[`pretty_time()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time.md)

## Examples

``` r
pretty_time_taken(
  "2024-03-23 07:05:53 GMT",
  "2024-03-23 12:09:56 GMT"
)
#> [1] "5 hours 4 minutes 3 seconds"

# Track the start and end time of a process
start <- Sys.time()
Sys.sleep(0.1)
end <- Sys.time()

# Use this function to present it prettily
pretty_time_taken(start, end)
#> [1] "0.1 seconds"
```
