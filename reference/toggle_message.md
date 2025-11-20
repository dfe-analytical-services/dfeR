# Controllable console messages

Quick expansion to the
[`message()`](https://rdrr.io/r/base/message.html) function aimed for
use in functions for an easy addition of a global verbose TRUE / FALSE
argument to toggle the messages on or off

## Usage

``` r
toggle_message(..., verbose)
```

## Arguments

- ...:

  any message you would normally pass into
  [`message()`](https://rdrr.io/r/base/message.html). See
  [`message`](https://rdrr.io/r/base/message.html) for more details

- verbose:

  logical, usually a variable passed from the function you are using
  this within

## Value

No return value, called for side effects

## Examples

``` r
# Usually used in a function
my_function <- function(count_fingers, verbose) {
  toggle_message("I have ", count_fingers, " fingers", verbose = verbose)
  fingers_thumbs <- count_fingers + 2
  toggle_message("I have ", fingers_thumbs, " digits", verbose = verbose)
}

my_function(5, verbose = FALSE)
my_function(5, verbose = TRUE)
#> I have 5 fingers
#> I have 7 digits

# Can be used in isolation
toggle_message("I want the world to read this!", verbose = TRUE)
#> I want the world to read this!
toggle_message("I ain't gonna show this message!", verbose = FALSE)

count_fingers <- 5
toggle_message("I have ", count_fingers, " fingers", verbose = TRUE)
#> I have 5 fingers
```
