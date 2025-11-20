# Comma separate

Adds separating commas to big numbers. If a value is not numeric it will
return the value unchanged and as a string.

## Usage

``` r
comma_sep(number, nsmall = 0L)
```

## Arguments

- number:

  number to be comma separated

- nsmall:

  minimum number of digits to the right of the decimal point

## Value

string

## Examples

``` r
comma_sep(100)
#> [1] "100"
comma_sep(1000)
#> [1] "1,000"
comma_sep(3567000)
#> [1] "3,567,000"
```
