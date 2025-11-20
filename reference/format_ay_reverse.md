# Undo academic year formatting

This function converts academic year variables back into 201617 format.

## Usage

``` r
format_ay_reverse(year)
```

## Arguments

- year:

  Academic year

## Value

Unformatted 6 digit year as string

## Details

It accepts character arguments.

## See also

Other format:
[`format_ay()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay.md),
[`format_fy()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy.md),
[`format_fy_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy_reverse.md)

## Examples

``` r
format_ay_reverse("2016/17")
#> [1] "201617"
```
