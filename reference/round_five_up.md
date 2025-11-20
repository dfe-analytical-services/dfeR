# Round five up

Round any number to a specified number of places, with 5's being rounded
up.

## Usage

``` r
round_five_up(number, dp = 0)
```

## Arguments

- number:

  number to be rounded

- dp:

  number of decimal places to round to, default is 0

## Value

Rounded number

## Details

Rounds to 0 decimal places by default.

You can use a negative value for the decimal places. For example: -1
would round to the nearest 10 -2 would round to the nearest 100 and so
on.

This is as an alternative to round in base R, which uses a bankers
round. For more information see the [round()
documentation](https://rdrr.io/r/base/Round.html).

## Examples

``` r
# No dp set
round_five_up(2485.85)
#> [1] 2486

# With dp set
round_five_up(2485.85, 2)
#> [1] 2485.85
round_five_up(2485.85, 1)
#> [1] 2485.9
round_five_up(2485.85, 0)
#> [1] 2486
round_five_up(2485.85, -1)
#> [1] 2490
round_five_up(2485.85, -2)
#> [1] 2500
```
