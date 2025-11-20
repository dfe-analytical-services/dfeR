# Format financial year

This function formats financial year variables for reporting purposes.
It will convert an year input from 201516 format to 2015-16 format.

## Usage

``` r
format_fy(year)
```

## Arguments

- year:

  Financial year

## Value

Character vector of formatted financial year

## Details

It accepts both numerical and character arguments.

## See also

Other format:
[`format_ay()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay.md),
[`format_ay_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay_reverse.md),
[`format_fy_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy_reverse.md)

## Examples

``` r
format_fy(201617)
#> [1] "2016-17"
format_fy("201617")
#> [1] "2016-17"
```
