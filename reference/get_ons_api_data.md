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
  Service/Layer)](https://www.shorturl.at/5xrJT)

- batch_size:

  the number of rows per query. This is 250 by default, if you hit
  errors then try lowering this. The API has a limit of 1000 to 2000
  rows per query, and in truth, the actual limit for our method is lower
  as every ObjectId queried is pasted into the query URL so for every
  row included in the batch, and especial if those Id's go into the
  1,000s or 10,000s they will increase the size of the URL and risk
  hitting the limit.

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
# Fetch everything from a data set
dfeR::get_ons_api_data(data_id = "LAD23_RGN23_EN_LU")
#> Checking total number of objects...
#> 296 objects found for the query
#> Created 2 batches of objects to query
#> Querying API to get objects...
#> ...fetching batch 1: objects 1 to 200...
#> ...success! There are now 200 rows in your table...
#> ...fetching batch 2: objects 201 to 296...
#> ...success! There are now 296 rows in your table...
#> ...data frame batched, stacked and delivered!
#>     attributes.LAD23CD                  attributes.LAD23NM attributes.RGN23CD
#> 1            E06000001                          Hartlepool          E12000001
#> 2            E06000002                       Middlesbrough          E12000001
#> 3            E06000003                Redcar and Cleveland          E12000001
#> 4            E06000004                    Stockton-on-Tees          E12000001
#> 5            E06000005                          Darlington          E12000001
#> 6            E06000006                              Halton          E12000002
#> 7            E06000007                          Warrington          E12000002
#> 8            E06000008               Blackburn with Darwen          E12000002
#> 9            E06000009                           Blackpool          E12000002
#> 10           E06000010         Kingston upon Hull, City of          E12000003
#> 11           E06000011            East Riding of Yorkshire          E12000003
#> 12           E06000012             North East Lincolnshire          E12000003
#> 13           E06000013                  North Lincolnshire          E12000003
#> 14           E06000014                                York          E12000003
#> 15           E06000015                               Derby          E12000004
#> 16           E06000016                           Leicester          E12000004
#> 17           E06000017                             Rutland          E12000004
#> 18           E06000018                          Nottingham          E12000004
#> 19           E06000019            Herefordshire, County of          E12000005
#> 20           E06000020                  Telford and Wrekin          E12000005
#> 21           E06000021                      Stoke-on-Trent          E12000005
#> 22           E06000022        Bath and North East Somerset          E12000009
#> 23           E06000023                    Bristol, City of          E12000009
#> 24           E06000024                      North Somerset          E12000009
#> 25           E06000025               South Gloucestershire          E12000009
#> 26           E06000026                            Plymouth          E12000009
#> 27           E06000027                              Torbay          E12000009
#> 28           E06000030                             Swindon          E12000009
#> 29           E06000031                        Peterborough          E12000006
#> 30           E06000032                               Luton          E12000006
#> 31           E06000033                     Southend-on-Sea          E12000006
#> 32           E06000034                            Thurrock          E12000006
#> 33           E06000035                              Medway          E12000008
#> 34           E06000036                    Bracknell Forest          E12000008
#> 35           E06000037                      West Berkshire          E12000008
#> 36           E06000038                             Reading          E12000008
#> 37           E06000039                              Slough          E12000008
#> 38           E06000040              Windsor and Maidenhead          E12000008
#> 39           E06000041                           Wokingham          E12000008
#> 40           E06000042                       Milton Keynes          E12000008
#> 41           E06000043                   Brighton and Hove          E12000008
#> 42           E06000044                          Portsmouth          E12000008
#> 43           E06000045                         Southampton          E12000008
#> 44           E06000046                       Isle of Wight          E12000008
#> 45           E06000047                       County Durham          E12000001
#> 46           E06000049                       Cheshire East          E12000002
#> 47           E06000050           Cheshire West and Chester          E12000002
#> 48           E06000051                          Shropshire          E12000005
#> 49           E06000052                            Cornwall          E12000009
#> 50           E06000053                     Isles of Scilly          E12000009
#> 51           E06000054                           Wiltshire          E12000009
#> 52           E06000055                             Bedford          E12000006
#> 53           E06000056                Central Bedfordshire          E12000006
#> 54           E06000057                      Northumberland          E12000001
#> 55           E06000058 Bournemouth, Christchurch and Poole          E12000009
#> 56           E06000059                              Dorset          E12000009
#> 57           E06000060                     Buckinghamshire          E12000008
#> 58           E06000061              North Northamptonshire          E12000004
#> 59           E06000062               West Northamptonshire          E12000004
#> 60           E06000063                          Cumberland          E12000002
#> 61           E07000181                    West Oxfordshire          E12000008
#> 62           E07000192                       Cannock Chase          E12000005
#> 63           E07000193                  East Staffordshire          E12000005
#> 64           E07000194                           Lichfield          E12000005
#> 65           E07000195                Newcastle-under-Lyme          E12000005
#> 66           E07000196                 South Staffordshire          E12000005
#> 67           E07000197                            Stafford          E12000005
#> 68           E07000198             Staffordshire Moorlands          E12000005
#> 69           E07000199                            Tamworth          E12000005
#> 70           E07000200                             Babergh          E12000006
#> 71           E07000202                             Ipswich          E12000006
#> 72           E07000203                         Mid Suffolk          E12000006
#> 73           E07000207                           Elmbridge          E12000008
#> 74           E07000208                     Epsom and Ewell          E12000008
#> 75           E07000209                           Guildford          E12000008
#> 76           E07000210                         Mole Valley          E12000008
#> 77           E07000211                Reigate and Banstead          E12000008
#> 78           E07000212                           Runnymede          E12000008
#> 79           E07000213                          Spelthorne          E12000008
#> 80           E07000214                        Surrey Heath          E12000008
#> 81           E07000215                           Tandridge          E12000008
#> 82           E07000216                            Waverley          E12000008
#> 83           E07000217                              Woking          E12000008
#> 84           E07000218                  North Warwickshire          E12000005
#> 85           E07000219               Nuneaton and Bedworth          E12000005
#> 86           E07000220                               Rugby          E12000005
#> 87           E07000221                   Stratford-on-Avon          E12000005
#> 88           E07000222                             Warwick          E12000005
#> 89           E07000223                                Adur          E12000008
#> 90           E07000224                                Arun          E12000008
#> 91           E07000225                          Chichester          E12000008
#> 92           E07000226                             Crawley          E12000008
#> 93           E07000227                             Horsham          E12000008
#> 94           E07000228                          Mid Sussex          E12000008
#> 95           E07000229                            Worthing          E12000008
#> 96           E07000234                          Bromsgrove          E12000005
#> 97           E07000235                       Malvern Hills          E12000005
#> 98           E07000236                            Redditch          E12000005
#> 99           E07000237                           Worcester          E12000005
#> 100          E07000238                            Wychavon          E12000005
#> 101          E07000239                         Wyre Forest          E12000005
#> 102          E07000240                           St Albans          E12000006
#> 103          E07000241                     Welwyn Hatfield          E12000006
#> 104          E07000242                  East Hertfordshire          E12000006
#> 105          E07000243                           Stevenage          E12000006
#> 106          E07000244                        East Suffolk          E12000006
#> 107          E07000245                        West Suffolk          E12000006
#> 108          E08000001                              Bolton          E12000002
#> 109          E08000002                                Bury          E12000002
#> 110          E08000003                          Manchester          E12000002
#> 111          E08000004                              Oldham          E12000002
#> 112          E08000005                            Rochdale          E12000002
#> 113          E08000006                             Salford          E12000002
#> 114          E08000007                           Stockport          E12000002
#> 115          E08000008                            Tameside          E12000002
#> 116          E08000009                            Trafford          E12000002
#> 117          E08000010                               Wigan          E12000002
#> 118          E08000011                            Knowsley          E12000002
#> 119          E08000012                           Liverpool          E12000002
#> 120          E08000013                          St. Helens          E12000002
#> 121          E07000098                           Hertsmere          E12000006
#> 122          E07000099                 North Hertfordshire          E12000006
#> 123          E07000102                        Three Rivers          E12000006
#> 124          E07000103                             Watford          E12000006
#> 125          E07000105                             Ashford          E12000008
#> 126          E07000106                          Canterbury          E12000008
#> 127          E07000107                            Dartford          E12000008
#> 128          E07000108                               Dover          E12000008
#> 129          E07000109                           Gravesham          E12000008
#> 130          E07000110                           Maidstone          E12000008
#> 131          E07000111                           Sevenoaks          E12000008
#> 132          E07000112                Folkestone and Hythe          E12000008
#> 133          E07000113                               Swale          E12000008
#> 134          E07000114                              Thanet          E12000008
#> 135          E07000115               Tonbridge and Malling          E12000008
#> 136          E07000116                     Tunbridge Wells          E12000008
#> 137          E07000117                             Burnley          E12000002
#> 138          E07000118                             Chorley          E12000002
#> 139          E07000119                               Fylde          E12000002
#> 140          E07000120                            Hyndburn          E12000002
#> 141          E07000121                           Lancaster          E12000002
#> 142          E07000122                              Pendle          E12000002
#> 143          E07000123                             Preston          E12000002
#> 144          E07000124                       Ribble Valley          E12000002
#> 145          E07000125                          Rossendale          E12000002
#> 146          E07000126                        South Ribble          E12000002
#> 147          E07000127                     West Lancashire          E12000002
#> 148          E07000128                                Wyre          E12000002
#> 149          E07000129                               Blaby          E12000004
#> 150          E07000130                           Charnwood          E12000004
#> 151          E07000131                          Harborough          E12000004
#> 152          E07000132               Hinckley and Bosworth          E12000004
#> 153          E07000133                              Melton          E12000004
#> 154          E07000134           North West Leicestershire          E12000004
#> 155          E07000135                   Oadby and Wigston          E12000004
#> 156          E07000136                              Boston          E12000004
#> 157          E07000137                        East Lindsey          E12000004
#> 158          E07000138                             Lincoln          E12000004
#> 159          E07000139                      North Kesteven          E12000004
#> 160          E07000140                       South Holland          E12000004
#> 161          E07000141                      South Kesteven          E12000004
#> 162          E07000142                        West Lindsey          E12000004
#> 163          E07000143                           Breckland          E12000006
#> 164          E07000144                           Broadland          E12000006
#> 165          E07000145                      Great Yarmouth          E12000006
#> 166          E07000146        King's Lynn and West Norfolk          E12000006
#> 167          E07000147                       North Norfolk          E12000006
#> 168          E07000148                             Norwich          E12000006
#> 169          E07000149                       South Norfolk          E12000006
#> 170          E07000170                            Ashfield          E12000004
#> 171          E07000171                           Bassetlaw          E12000004
#> 172          E07000172                            Broxtowe          E12000004
#> 173          E07000173                             Gedling          E12000004
#> 174          E07000174                           Mansfield          E12000004
#> 175          E07000175                 Newark and Sherwood          E12000004
#> 176          E07000176                          Rushcliffe          E12000004
#> 177          E07000177                            Cherwell          E12000008
#> 178          E07000178                              Oxford          E12000008
#> 179          E07000179                   South Oxfordshire          E12000008
#> 180          E07000180                 Vale of White Horse          E12000008
#> 181          E08000014                              Sefton          E12000002
#> 182          E08000015                              Wirral          E12000002
#> 183          E08000016                            Barnsley          E12000003
#> 184          E08000017                           Doncaster          E12000003
#> 185          E08000018                           Rotherham          E12000003
#> 186          E08000019                           Sheffield          E12000003
#> 187          E08000021                 Newcastle upon Tyne          E12000001
#> 188          E08000022                      North Tyneside          E12000001
#> 189          E08000023                      South Tyneside          E12000001
#> 190          E08000024                          Sunderland          E12000001
#> 191          E08000025                          Birmingham          E12000005
#> 192          E08000026                            Coventry          E12000005
#> 193          E08000027                              Dudley          E12000005
#> 194          E08000028                            Sandwell          E12000005
#> 195          E08000029                            Solihull          E12000005
#> 196          E08000030                             Walsall          E12000005
#> 197          E08000031                       Wolverhampton          E12000005
#> 198          E08000032                            Bradford          E12000003
#> 199          E08000033                          Calderdale          E12000003
#> 200          E08000034                            Kirklees          E12000003
#> 201          E06000064             Westmorland and Furness          E12000002
#> 202          E08000035                               Leeds          E12000003
#> 203          E08000036                           Wakefield          E12000003
#> 204          E08000037                           Gateshead          E12000001
#> 205          E09000001                      City of London          E12000007
#> 206          E09000002                Barking and Dagenham          E12000007
#> 207          E09000003                              Barnet          E12000007
#> 208          E09000004                              Bexley          E12000007
#> 209          E09000005                               Brent          E12000007
#> 210          E09000006                             Bromley          E12000007
#> 211          E09000007                              Camden          E12000007
#> 212          E09000008                             Croydon          E12000007
#> 213          E09000009                              Ealing          E12000007
#> 214          E09000010                             Enfield          E12000007
#> 215          E09000011                           Greenwich          E12000007
#> 216          E09000012                             Hackney          E12000007
#> 217          E09000013              Hammersmith and Fulham          E12000007
#> 218          E09000014                            Haringey          E12000007
#> 219          E09000015                              Harrow          E12000007
#> 220          E09000016                            Havering          E12000007
#> 221          E09000017                          Hillingdon          E12000007
#> 222          E09000018                            Hounslow          E12000007
#> 223          E09000019                           Islington          E12000007
#> 224          E09000020              Kensington and Chelsea          E12000007
#> 225          E09000021                Kingston upon Thames          E12000007
#> 226          E09000022                             Lambeth          E12000007
#> 227          E09000023                            Lewisham          E12000007
#> 228          E09000024                              Merton          E12000007
#> 229          E09000025                              Newham          E12000007
#> 230          E09000026                           Redbridge          E12000007
#> 231          E09000027                Richmond upon Thames          E12000007
#> 232          E09000028                           Southwark          E12000007
#> 233          E09000029                              Sutton          E12000007
#> 234          E09000030                       Tower Hamlets          E12000007
#> 235          E09000031                      Waltham Forest          E12000007
#> 236          E09000032                          Wandsworth          E12000007
#> 237          E09000033                         Westminster          E12000007
#> 238          E06000065                     North Yorkshire          E12000003
#> 239          E06000066                            Somerset          E12000009
#> 240          E07000008                           Cambridge          E12000006
#> 241          E07000009                 East Cambridgeshire          E12000006
#> 242          E07000010                             Fenland          E12000006
#> 243          E07000011                     Huntingdonshire          E12000006
#> 244          E07000012                South Cambridgeshire          E12000006
#> 245          E07000032                        Amber Valley          E12000004
#> 246          E07000033                            Bolsover          E12000004
#> 247          E07000034                        Chesterfield          E12000004
#> 248          E07000035                    Derbyshire Dales          E12000004
#> 249          E07000036                             Erewash          E12000004
#> 250          E07000037                           High Peak          E12000004
#> 251          E07000038               North East Derbyshire          E12000004
#> 252          E07000039                    South Derbyshire          E12000004
#> 253          E07000040                          East Devon          E12000009
#> 254          E07000041                              Exeter          E12000009
#> 255          E07000042                           Mid Devon          E12000009
#> 256          E07000043                         North Devon          E12000009
#> 257          E07000044                          South Hams          E12000009
#> 258          E07000045                         Teignbridge          E12000009
#> 259          E07000046                            Torridge          E12000009
#> 260          E07000047                          West Devon          E12000009
#> 261          E07000061                          Eastbourne          E12000008
#> 262          E07000062                            Hastings          E12000008
#> 263          E07000063                               Lewes          E12000008
#> 264          E07000064                              Rother          E12000008
#> 265          E07000065                             Wealden          E12000008
#> 266          E07000066                            Basildon          E12000006
#> 267          E07000067                           Braintree          E12000006
#> 268          E07000068                           Brentwood          E12000006
#> 269          E07000069                        Castle Point          E12000006
#> 270          E07000070                          Chelmsford          E12000006
#> 271          E07000071                          Colchester          E12000006
#> 272          E07000072                       Epping Forest          E12000006
#> 273          E07000073                              Harlow          E12000006
#> 274          E07000074                              Maldon          E12000006
#> 275          E07000075                            Rochford          E12000006
#> 276          E07000076                            Tendring          E12000006
#> 277          E07000077                          Uttlesford          E12000006
#> 278          E07000078                          Cheltenham          E12000009
#> 279          E07000079                            Cotswold          E12000009
#> 280          E07000080                      Forest of Dean          E12000009
#> 281          E07000081                          Gloucester          E12000009
#> 282          E07000082                              Stroud          E12000009
#> 283          E07000083                          Tewkesbury          E12000009
#> 284          E07000084               Basingstoke and Deane          E12000008
#> 285          E07000085                      East Hampshire          E12000008
#> 286          E07000086                           Eastleigh          E12000008
#> 287          E07000087                             Fareham          E12000008
#> 288          E07000088                             Gosport          E12000008
#> 289          E07000089                                Hart          E12000008
#> 290          E07000090                              Havant          E12000008
#> 291          E07000091                          New Forest          E12000008
#> 292          E07000092                            Rushmoor          E12000008
#> 293          E07000093                         Test Valley          E12000008
#> 294          E07000094                          Winchester          E12000008
#> 295          E07000095                          Broxbourne          E12000006
#> 296          E07000096                             Dacorum          E12000006
#>           attributes.RGN23NM attributes.ObjectId
#> 1                 North East                   1
#> 2                 North East                   2
#> 3                 North East                   3
#> 4                 North East                   4
#> 5                 North East                   5
#> 6                 North West                   6
#> 7                 North West                   7
#> 8                 North West                   8
#> 9                 North West                   9
#> 10  Yorkshire and The Humber                  10
#> 11  Yorkshire and The Humber                  11
#> 12  Yorkshire and The Humber                  12
#> 13  Yorkshire and The Humber                  13
#> 14  Yorkshire and The Humber                  14
#> 15             East Midlands                  15
#> 16             East Midlands                  16
#> 17             East Midlands                  17
#> 18             East Midlands                  18
#> 19             West Midlands                  19
#> 20             West Midlands                  20
#> 21             West Midlands                  21
#> 22                South West                  22
#> 23                South West                  23
#> 24                South West                  24
#> 25                South West                  25
#> 26                South West                  26
#> 27                South West                  27
#> 28                South West                  28
#> 29           East of England                  29
#> 30           East of England                  30
#> 31           East of England                  31
#> 32           East of England                  32
#> 33                South East                  33
#> 34                South East                  34
#> 35                South East                  35
#> 36                South East                  36
#> 37                South East                  37
#> 38                South East                  38
#> 39                South East                  39
#> 40                South East                  40
#> 41                South East                  41
#> 42                South East                  42
#> 43                South East                  43
#> 44                South East                  44
#> 45                North East                  45
#> 46                North West                  46
#> 47                North West                  47
#> 48             West Midlands                  48
#> 49                South West                  49
#> 50                South West                  50
#> 51                South West                  51
#> 52           East of England                  52
#> 53           East of England                  53
#> 54                North East                  54
#> 55                South West                  55
#> 56                South West                  56
#> 57                South East                  57
#> 58             East Midlands                  58
#> 59             East Midlands                  59
#> 60                North West                  60
#> 61                South East                  61
#> 62             West Midlands                  62
#> 63             West Midlands                  63
#> 64             West Midlands                  64
#> 65             West Midlands                  65
#> 66             West Midlands                  66
#> 67             West Midlands                  67
#> 68             West Midlands                  68
#> 69             West Midlands                  69
#> 70           East of England                  70
#> 71           East of England                  71
#> 72           East of England                  72
#> 73                South East                  73
#> 74                South East                  74
#> 75                South East                  75
#> 76                South East                  76
#> 77                South East                  77
#> 78                South East                  78
#> 79                South East                  79
#> 80                South East                  80
#> 81                South East                  81
#> 82                South East                  82
#> 83                South East                  83
#> 84             West Midlands                  84
#> 85             West Midlands                  85
#> 86             West Midlands                  86
#> 87             West Midlands                  87
#> 88             West Midlands                  88
#> 89                South East                  89
#> 90                South East                  90
#> 91                South East                  91
#> 92                South East                  92
#> 93                South East                  93
#> 94                South East                  94
#> 95                South East                  95
#> 96             West Midlands                  96
#> 97             West Midlands                  97
#> 98             West Midlands                  98
#> 99             West Midlands                  99
#> 100            West Midlands                 100
#> 101            West Midlands                 101
#> 102          East of England                 102
#> 103          East of England                 103
#> 104          East of England                 104
#> 105          East of England                 105
#> 106          East of England                 106
#> 107          East of England                 107
#> 108               North West                 108
#> 109               North West                 109
#> 110               North West                 110
#> 111               North West                 111
#> 112               North West                 112
#> 113               North West                 113
#> 114               North West                 114
#> 115               North West                 115
#> 116               North West                 116
#> 117               North West                 117
#> 118               North West                 118
#> 119               North West                 119
#> 120               North West                 120
#> 121          East of England                 121
#> 122          East of England                 122
#> 123          East of England                 123
#> 124          East of England                 124
#> 125               South East                 125
#> 126               South East                 126
#> 127               South East                 127
#> 128               South East                 128
#> 129               South East                 129
#> 130               South East                 130
#> 131               South East                 131
#> 132               South East                 132
#> 133               South East                 133
#> 134               South East                 134
#> 135               South East                 135
#> 136               South East                 136
#> 137               North West                 137
#> 138               North West                 138
#> 139               North West                 139
#> 140               North West                 140
#> 141               North West                 141
#> 142               North West                 142
#> 143               North West                 143
#> 144               North West                 144
#> 145               North West                 145
#> 146               North West                 146
#> 147               North West                 147
#> 148               North West                 148
#> 149            East Midlands                 149
#> 150            East Midlands                 150
#> 151            East Midlands                 151
#> 152            East Midlands                 152
#> 153            East Midlands                 153
#> 154            East Midlands                 154
#> 155            East Midlands                 155
#> 156            East Midlands                 156
#> 157            East Midlands                 157
#> 158            East Midlands                 158
#> 159            East Midlands                 159
#> 160            East Midlands                 160
#> 161            East Midlands                 161
#> 162            East Midlands                 162
#> 163          East of England                 163
#> 164          East of England                 164
#> 165          East of England                 165
#> 166          East of England                 166
#> 167          East of England                 167
#> 168          East of England                 168
#> 169          East of England                 169
#> 170            East Midlands                 170
#> 171            East Midlands                 171
#> 172            East Midlands                 172
#> 173            East Midlands                 173
#> 174            East Midlands                 174
#> 175            East Midlands                 175
#> 176            East Midlands                 176
#> 177               South East                 177
#> 178               South East                 178
#> 179               South East                 179
#> 180               South East                 180
#> 181               North West                 181
#> 182               North West                 182
#> 183 Yorkshire and The Humber                 183
#> 184 Yorkshire and The Humber                 184
#> 185 Yorkshire and The Humber                 185
#> 186 Yorkshire and The Humber                 186
#> 187               North East                 187
#> 188               North East                 188
#> 189               North East                 189
#> 190               North East                 190
#> 191            West Midlands                 191
#> 192            West Midlands                 192
#> 193            West Midlands                 193
#> 194            West Midlands                 194
#> 195            West Midlands                 195
#> 196            West Midlands                 196
#> 197            West Midlands                 197
#> 198 Yorkshire and The Humber                 198
#> 199 Yorkshire and The Humber                 199
#> 200 Yorkshire and The Humber                 200
#> 201               North West                 201
#> 202 Yorkshire and The Humber                 202
#> 203 Yorkshire and The Humber                 203
#> 204               North East                 204
#> 205                   London                 205
#> 206                   London                 206
#> 207                   London                 207
#> 208                   London                 208
#> 209                   London                 209
#> 210                   London                 210
#> 211                   London                 211
#> 212                   London                 212
#> 213                   London                 213
#> 214                   London                 214
#> 215                   London                 215
#> 216                   London                 216
#> 217                   London                 217
#> 218                   London                 218
#> 219                   London                 219
#> 220                   London                 220
#> 221                   London                 221
#> 222                   London                 222
#> 223                   London                 223
#> 224                   London                 224
#> 225                   London                 225
#> 226                   London                 226
#> 227                   London                 227
#> 228                   London                 228
#> 229                   London                 229
#> 230                   London                 230
#> 231                   London                 231
#> 232                   London                 232
#> 233                   London                 233
#> 234                   London                 234
#> 235                   London                 235
#> 236                   London                 236
#> 237                   London                 237
#> 238 Yorkshire and The Humber                 238
#> 239               South West                 239
#> 240          East of England                 240
#> 241          East of England                 241
#> 242          East of England                 242
#> 243          East of England                 243
#> 244          East of England                 244
#> 245            East Midlands                 245
#> 246            East Midlands                 246
#> 247            East Midlands                 247
#> 248            East Midlands                 248
#> 249            East Midlands                 249
#> 250            East Midlands                 250
#> 251            East Midlands                 251
#> 252            East Midlands                 252
#> 253               South West                 253
#> 254               South West                 254
#> 255               South West                 255
#> 256               South West                 256
#> 257               South West                 257
#> 258               South West                 258
#> 259               South West                 259
#> 260               South West                 260
#> 261               South East                 261
#> 262               South East                 262
#> 263               South East                 263
#> 264               South East                 264
#> 265               South East                 265
#> 266          East of England                 266
#> 267          East of England                 267
#> 268          East of England                 268
#> 269          East of England                 269
#> 270          East of England                 270
#> 271          East of England                 271
#> 272          East of England                 272
#> 273          East of England                 273
#> 274          East of England                 274
#> 275          East of England                 275
#> 276          East of England                 276
#> 277          East of England                 277
#> 278               South West                 278
#> 279               South West                 279
#> 280               South West                 280
#> 281               South West                 281
#> 282               South West                 282
#> 283               South West                 283
#> 284               South East                 284
#> 285               South East                 285
#> 286               South East                 286
#> 287               South East                 287
#> 288               South East                 288
#> 289               South East                 289
#> 290               South East                 290
#> 291               South East                 291
#> 292               South East                 292
#> 293               South East                 293
#> 294               South East                 294
#> 295          East of England                 295
#> 296          East of England                 296

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
#> Checking total number of objects...
#> 9 objects found for the query
#> Created 1 batches of objects to query
#> Querying API to get objects...
#> ...fetching batch 1: objects 1 to 9...
#> ...success! There are now 9 rows in your table...
#> ...data frame batched, stacked and delivered!
#>   attributes.RGN23CD       attributes.RGN23NM
#> 1          E12000001               North East
#> 2          E12000002               North West
#> 3          E12000003 Yorkshire and The Humber
#> 4          E12000004            East Midlands
#> 5          E12000005            West Midlands
#> 6          E12000006          East of England
#> 7          E12000007                   London
#> 8          E12000008               South East
#> 9          E12000009               South West
```
