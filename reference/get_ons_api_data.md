# Fetch ONS Open Geography API data

Helper function that takes a data set id and parameters to query and
parse data from the ONS Open Geography API. Technically uses a POST
request rather than a GET request.

## Usage

``` r
get_ons_api_data(
  data_id,
  query_params = list(where = "1=1", outFields = "*", outSR = "4326", f = "json"),
  batch_size = 200,
  verbose = TRUE
)
```

## Arguments

- data_id:

  the id of the data set to query, can be found from the Open Geography
  Portal

- query_params:

  query parameters to pass into the API, see the ESRI documentation for
  more information on query parameters - [ESRI Query (Feature
  Service/Layer)](https://developers.arcgis.com/rest/services-reference/enterprise/query-feature-service-layer/)

- batch_size:

  the number of rows per query. This is 200 by default, if you hit
  errors then try lowering this. The API has a limit of 1000 to 2000
  rows per query, and in truth, the actual limit for our method is lower
  as every ObjectId queried is pasted into the request, so larger
  batches, and especially Ids that go into the 1,000s or 10,000s,
  increase the size of each request and risk hitting the limit.

- verbose:

  TRUE or FALSE boolean. TRUE by default. FALSE will turn off the
  messages to the console that update on what the function is doing

## Value

parsed data.frame of geographic names and codes

## Details

It does a pre-query to understand the ObjectIds for the query you want,
and then does a query to retrieve those Ids directly in batches before
then stacking the whole thing back together to work around the row
limits for a single query.

On the [Open Geography Portal](https://geoportal.statistics.gov.uk/),
find the data set you're interested in and then use the query explorer
to find the information for the query.

This function has been mostly developed for ease of use for dfeR
maintainers if you're interested in getting data from the Open Geography
Portal more widely you should also look at the [boundr
package](https://github.com/francisbarton/boundr).

## Examples

``` r
if (FALSE) { # interactive()
# Fetch everything from a data set
dfeR::get_ons_api_data(data_id = "LAD23_RGN23_EN_LU")

# Specify the columns you want
dfeR::get_ons_api_data(
  "RGN_DEC_2023_EN_NC",
  query_params = list(
    where = "1=1",
    outFields = "RGN23CD,RGN23NM",
    outSR = 4326,
    f = "json"
  )
)
}
```
