# Format academic year

This function formats academic year variables for reporting purposes. It
will convert an academic year input from 201516 format to 2015/16
format.

## Usage

``` r
format_ay(year)
```

## Arguments

- year:

  Academic year

## Value

Character vector of formatted academic year

## Details

It accepts both numerical and character arguments.

## See also

Other format:
[`format_ay_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_ay_reverse.md),
[`format_fy()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy.md),
[`format_fy_reverse()`](https://dfe-analytical-services.github.io/dfeR/reference/format_fy_reverse.md)

## Examples

``` r
format_ay(201617)
#> [1] "2016/17"
format_ay("201617")
#> [1] "2016/17"
```
