# Minimum supported Air version

Air 0.10.0 changed the default `assignment-style` to `"arrow"`, which
affects the styled output that
[`air_style()`](https://dfe-analytical-services.github.io/dfeR/reference/air_style.md)
produces. Versions of Air older than this will silently produce
different (older) formatting.

## Usage

``` r
dfer_min_air_version
```
