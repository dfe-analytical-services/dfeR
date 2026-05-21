# Take in a vector of years, countries and a fetch_* function
# Return named counts of the locations for each combination of inputs
fetch_location_counts <- function(fetch_fun, years, countries) {
  params <- expand.grid(
    year = years,
    country = countries,
    stringsAsFactors = FALSE
  )

  results <- mapply(
    function(y, c) fetch_fun(year = y, countries = c),
    params$year,
    params$country,
    SIMPLIFY = FALSE
  )

  names(results) <- paste(params$year, params$country, sep = "_")

  sapply(results, nrow)
}
