# Fetch regions

Fetch a data frame of all regions based on the dfeR::regions file.

## Usage

``` r
fetch_regions()
```

## Value

data frame of unique location names and codes

## See also

Other fetch_locations:
[`fetch_countries()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_countries.md),
[`fetch_lads()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_lads.md),
[`fetch_las()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_las.md),
[`fetch_mayoral()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_mayoral.md),
[`fetch_wards()`](https://dfe-analytical-services.github.io/dfeR/reference/fetch_wards.md)

## Examples

``` r
# Using head() to show only top 5 rows for examples
head(fetch_wards())
#> # A tibble: 6 × 2
#>   ward_code ward_name
#>   <chr>     <chr>    
#> 1 E05000026 Abbey    
#> 2 E05014053 Abbey    
#> 3 E05001935 Abbey    
#> 4 N08000101 Abbey    
#> 5 E05006917 Abbey    
#> 6 E05002702 Abbey    

head(fetch_pcons())
#> # A tibble: 6 × 2
#>   pcon_code pcon_name    
#>   <chr>     <chr>        
#> 1 E14000540 Barking      
#> 2 E14001073 Barking      
#> 3 E14000547 Bath         
#> 4 N05000002 Belfast North
#> 5 N06000002 Belfast North
#> 6 E14000610 Burton       

head(fetch_pcons(2023))
#> # A tibble: 6 × 2
#>   pcon_code pcon_name    
#>   <chr>     <chr>        
#> 1 E14000540 Barking      
#> 2 E14000547 Bath         
#> 3 N06000002 Belfast North
#> 4 E14000610 Burton       
#> 5 E14000617 Cambridge    
#> 6 E14000662 Derby North  

head(fetch_pcons(countries = "Scotland"))
#> # A tibble: 6 × 2
#>   pcon_code pcon_name                            
#>   <chr>     <chr>                                
#> 1 S14000013 Dumfries and Galloway                
#> 2 S14000073 Dumfries and Galloway                
#> 3 S14000037 Gordon                               
#> 4 S14000058 West Aberdeenshire and Kincardine    
#> 5 S14000111 West Aberdeenshire and Kincardine    
#> 6 S14000069 Caithness, Sutherland and Easter Ross

head(fetch_pcons(year = 2023, countries = c("England", "Wales")))
#> # A tibble: 6 × 2
#>   pcon_code pcon_name  
#>   <chr>     <chr>      
#> 1 E14000540 Barking    
#> 2 E14000547 Bath       
#> 3 E14000610 Burton     
#> 4 E14000617 Cambridge  
#> 5 E14000662 Derby North
#> 6 E14000663 Derby South

head(fetch_mayoral())
#> # A tibble: 6 × 2
#>   english_devolved_area_code english_devolved_area_name     
#>   <chr>                      <chr>                          
#> 1 E61000001                  Greater London Authority       
#> 2 E47000009                  West of England                
#> 3 E47000008                  Cambridgeshire and Peterborough
#> 4 E47000013                  East Midlands                  
#> 5 E47000017                  Greater Lincolnshire           
#> 6 E47000007                  West Midlands                  

fetch_lads(2024, "Wales")
#> # A tibble: 22 × 2
#>    lad_code  lad_name         
#>    <chr>     <chr>            
#>  1 W06000018 Caerphilly       
#>  2 W06000023 Powys            
#>  3 W06000008 Ceredigion       
#>  4 W06000016 Rhondda Cynon Taf
#>  5 W06000012 Neath Port Talbot
#>  6 W06000002 Gwynedd          
#>  7 W06000003 Conwy            
#>  8 W06000010 Carmarthenshire  
#>  9 W06000013 Bridgend         
#> 10 W06000020 Torfaen          
#> # ℹ 12 more rows

fetch_las(2022, "Northern Ireland")
#> # A tibble: 11 × 3
#>    new_la_code la_name                              old_la_code
#>    <chr>       <chr>                                <chr>      
#>  1 N09000001   Antrim and Newtownabbey              z          
#>  2 N09000010   Newry, Mourne and Down               z          
#>  3 N09000008   Mid and East Antrim                  z          
#>  4 N09000004   Causeway Coast and Glens             z          
#>  5 N09000002   Armagh City, Banbridge and Craigavon z          
#>  6 N09000003   Belfast                              z          
#>  7 N09000009   Mid Ulster                           z          
#>  8 N09000005   Derry City and Strabane              z          
#>  9 N09000006   Fermanagh and Omagh                  z          
#> 10 N09000007   Lisburn and Castlereagh              z          
#> 11 N09000011   Ards and North Down                  z          

# The following have no specific years available and return all values
fetch_regions()
#>    region_code                               region_name
#> 1    E12000001                                North East
#> 2    E12000002                                North West
#> 3    E12000003                  Yorkshire and The Humber
#> 4    E12000004                             East Midlands
#> 5    E12000005                             West Midlands
#> 6    E12000006                           East of England
#> 7    E12000007                                    London
#> 8    E12000008                                South East
#> 9    E12000009                                South West
#> 10   E13000001                              Inner London
#> 11   E13000002                              Outer London
#> 12           z            Outside of England and unknown
#> 13           z Outside of the United Kingdom and unknown
#> 14           z                        Outside of England
#> 15           z                 Outside of United Kingdom
#> 16           z                                   Unknown
fetch_countries()
#>    country_code                              country_name
#> 1     E92000001                                   England
#> 2     K02000001                            United Kingdom
#> 3     K03000001                             Great Britain
#> 4     K04000001                         England and Wales
#> 5     N92000002                          Northern Ireland
#> 6     S92000003                                  Scotland
#> 7     W92000004                                     Wales
#> 8             z       England, Wales and Northern Ireland
#> 9             z            Outside of England and unknown
#> 10            z Outside of the United Kingdom and unknown
```
