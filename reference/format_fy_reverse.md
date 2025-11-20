# Undo financial year formatting

This function converts financial year variables back into 201617 format.

## Usage

``` r
format_fy_reverse(year)
```

## Arguments

- year:

  Financial year

## Value

Unformatted 6 digit year as string

## Details

It accepts character arguments.

## See also

Other format:
[`format_ay()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay.md),
[`format_ay_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay_reverse.md),
[`format_fy()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy.md)

## Examples

``` r
format_fy_reverse("2016-17")
#> [1] "201617"
```
