# Pretty numbers into readable file size

Converts a raw file size from bytes to a more readable format.

## Usage

``` r
pretty_filesize(filesize)
```

## Arguments

- filesize:

  file size in bytes

## Value

string containing prettified file size

## Details

Designed to be used in conjunction with the file.size() function in base
R.

Presents in kilobytes, megabytes or gigabytes.

Shows as bytes until 1 KB, then kilobytes up to 1 MB, then megabytes
until 1GB, then it will show as gigabytes for anything larger.

Rounds the end result to 2 decimal places.

Using base 10 (decimal), so 1024 bytes is 1,024 KB.

## See also

[`comma_sep()`](https://dfe-analytical-services.github.io/dfeR/reference/comma_sep.md)
[`round_five_up()`](https://dfe-analytical-services.github.io/dfeR/reference/round_five_up.md)

Other prettying:
[`pretty_num()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num.md),
[`pretty_num_table()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_num_table.md),
[`pretty_time()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time.md),
[`pretty_time_taken()`](https://dfe-analytical-services.github.io/dfeR/reference/pretty_time_taken.md)

## Examples

``` r
pretty_filesize(2)
#> [1] "2 bytes"
pretty_filesize(549302)
#> [1] "549.3 KB"
pretty_filesize(9872948939)
#> [1] "9.87 GB"
pretty_filesize(1)
#> [1] "1 byte"
pretty_filesize(1000)
#> [1] "1 KB"
pretty_filesize(1000^2)
#> [1] "1 MB"
pretty_filesize(10^9)
#> [1] "1 GB"
```
