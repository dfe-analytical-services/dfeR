# Prettify big numbers into a readable format

Uses [`as.numeric()`](https://rdrr.io/r/base/numeric.html) to force a
numeric value and then formats prettily for easy presentation in console
messages, reports, or dashboards.

This rounds to 0 decimal places by default, and adds in comma
separators.

Expect that this will commonly be used for adding the pound symbol, the
percentage symbol, or to have a +/- prefixed based on the value.

If applying over multiple or unpredictable values and you want to
preserve a non-numeric symbol such as "x" or "c" for data not available,
use the `ignore_na = TRUE` argument to return those values unaffected.

If you want to customise what NA values are returned as, use the
`alt_na` argument.

This function silences the warning around NAs being introduced by
coercion.

## Usage

``` r
pretty_num(
  value,
  prefix = "",
  gbp = FALSE,
  suffix = "",
  dp = 0,
  ignore_na = FALSE,
  alt_na = FALSE,
  nsmall = NULL,
  dynamic_dp_value = NULL,
  abbreviate = TRUE
)
```

## Arguments

- value:

  value to be prettified

- prefix:

  prefix for the value, if "+/-" then it will automatically assign +
  or - based on the value

- gbp:

  whether to add the pound symbol or not, defaults to not

- suffix:

  suffix for the value, e.g. "%"

- dp:

  number of decimal places to round to, 0 by default.

- ignore_na:

  whether to skip function for strings that can't be converted and
  return original value

- alt_na:

  alternative value to return in place of NA, e.g. "x"

- nsmall:

  minimum number of digits to the right of the decimal point. If NULL,
  the value of `dp` will be used. If the value of `dp` is less than 0,
  then `nsmall` will automatically be set to 0.

- dynamic_dp_value:

  Integer. Default = NULL. Overrides the `dp` setting and dynamically
  adjusts decimal places based on value magnitude. For values ≥ 1
  million or ≥ 1 billion, the function checks the scaled value (e.g.,
  value / 1e6 or value / 1e9): if the scaled value is a whole number, it
  sets decimal places to 0; otherwise, it adds precision as specified
  here. This approach improves clarity without unnecessary formatting.

- abbreviate:

  whether to abbreviate large numbers to nearest million (where 1e6 \<=
  value \< 1e9) or billion (where value \>= 1e9).

## Value

string featuring prettified value

## See also

[`comma_sep()`](https://dfe-analytical-services.github.io/dfeR/reference/comma_sep.md)
[`round_five_up()`](https://dfe-analytical-services.github.io/dfeR/reference/round_five_up.md)
[`as.numeric()`](https://rdrr.io/r/base/numeric.html)

Other prettying:
[`pretty_filesize()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_filesize.md),
[`pretty_num_table()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num_table.md),
[`pretty_time()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time.md),
[`pretty_time_taken()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time_taken.md)

## Examples

``` r
# On individual values
pretty_num(5789, gbp = TRUE)
#> [1] "£5,789"
pretty_num(564, prefix = "+/-")
#> [1] "+564"
pretty_num(567812343223, gbp = TRUE, prefix = "+/-")
#> [1] "+£568 billion"
pretty_num(11^9, gbp = TRUE, dp = 3)
#> [1] "£2.358 billion"
pretty_num(-11^8, gbp = TRUE, dp = -1)
#> [1] "-£210 million"
pretty_num(43.3, dp = 1, nsmall = 2)
#> [1] "43.30"
pretty_num("56.089", suffix = "%")
#> [1] "56%"
pretty_num("x")
#> [1] NA
pretty_num("x", ignore_na = TRUE)
#> [1] "x"
pretty_num("nope", alt_na = "x")
#> [1] "x"
pretty_num(7.8e9, abbreviate = FALSE)
#> [1] "7,800,000,000"
# dynamic_dp_value enabled for a billion value not divisible by 10
pretty_num(3e9, dynamic_dp_value = 2)
#> [1] "3 billion"
# dynamic_dp_value enabled for a billion value divisible by 10
pretty_num(10e9, dynamic_dp_value = 2)
#> [1] "10 billion"
# dynamic_dp_value enabled for a million value not divisible by 10
pretty_num(3e6, dynamic_dp_value = 3)
#> [1] "3 million"
# dynamic_dp_value enabled for a million value divisible by 10
pretty_num(10e6, dynamic_dp_value = 3)
#> [1] "10 million"
# dynamic_dp_value enabled with GBP and suffix
pretty_num(1.5e9,
  gbp = TRUE, suffix = "%",
  dynamic_dp_value = 1
)
#> [1] "£1.5 billion%"
#' # Applied over an example vector
vector <- c(3998098008, -123421421, "c", "x")
pretty_num(vector)
#> [1] "4 billion"    "-123 million" NA             NA            
pretty_num(vector, prefix = "+/-", gbp = TRUE)
#> [1] "+£4 billion"   "-£123 million" NA              NA             

# Return original values if NA
pretty_num(vector, ignore_na = TRUE)
#> [1] "4 billion"    "-123 million" "c"            "x"           

# Return alternative value in place of NA
pretty_num(vector, alt_na = "z")
#> [1] "4 billion"    "-123 million" "z"            "z"           
```
