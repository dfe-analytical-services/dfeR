# Pretty time

Convert seconds into a human readable format

## Usage

``` r
pretty_time(seconds)
```

## Arguments

- seconds:

  number of seconds to prettify

## Value

string containing the 'pretty' time

## Details

Recognises when to present as:

- seconds

- minutes and seconds

- hours, minutes and seconds

It will show seconds until 119 seconds, then minutes until 119 minutes,
then hours. It doesn't do days or higher yet, but could be adapted to do
so if there's demand.

## See also

[`comma_sep()`](https://dfe-analytical-services.github.io/dfeR/reference/comma_sep.md)
[`round_five_up()`](https://dfe-analytical-services.github.io/dfeR/reference/round_five_up.md)
[`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html)

Other prettying:
[`pretty_filesize()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_filesize.md),
[`pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md),
[`pretty_num_table()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num_table.md),
[`pretty_time_taken()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time_taken.md)

## Examples

``` r
pretty_time(1)
#> [1] "1 second"
pretty_time(8)
#> [1] "8 seconds"
pretty_time(888)
#> [1] "14 minutes 48 seconds"
pretty_time(88888888)
#> [1] "24,691 hours 21 minutes 28 seconds"
pretty_time(c(60, 2, 88, 88888888))
#> [1] "60 seconds"                         "2 seconds"                         
#> [3] "88 seconds"                         "24,691 hours 21 minutes 28 seconds"
```
