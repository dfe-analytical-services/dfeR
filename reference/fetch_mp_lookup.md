# Fetch Westminster constituency to MP lookup

Fetch a data frame with one row per Westminster parliamentary
constituency and the MP currently sitting for it. Alongside the
constituency name and code, it gives the MP's name, Parliament member
ID, party, email address and 2024 general election result summary, plus
the local authority districts, local authorities, mayoral authorities,
region and country that each constituency maps to.

## Usage

``` r
fetch_mp_lookup(verbose = TRUE)
```

## Arguments

- verbose:

  TRUE or FALSE boolean. TRUE by default. FALSE will turn off the
  messages to the console that update on what the function is doing

## Value

data frame with one row per Westminster parliamentary constituency and
its sitting MP

## Details

The lookup is maintained in the
[mp-lookup](https://github.com/dfe-analytical-services/mp-lookup)
repository. It updates automatically as new results are published, and
is read directly from its GitHub-hosted CSV so that users don't need to
know or find the URL themselves.

Note that this is a lookup of sitting MPs, not a set of candidate-level
results, so unsuccessful candidates are not included.

## Examples

``` r
if (FALSE) { # interactive()
head(fetch_mp_lookup())
}
```
