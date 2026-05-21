# locations per year are consistent

    Code
      lapply(2017:2025, fetch_mayoral)
    Output
      [[1]]
      # A tibble: 10 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000007                  West Midlands                  
       5 E47000001                  Greater Manchester             
       6 E47000006                  Tees Valley                    
       7 E47000003                  West Yorkshire                 
       8 E47000002                  Sheffield City Region          
       9 E47000004                  Liverpool City Region          
      10 E47000005                  North East                     
      
      [[2]]
      # A tibble: 11 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000007                  West Midlands                  
       5 E47000001                  Greater Manchester             
       6 E47000006                  Tees Valley                    
       7 E47000003                  West Yorkshire                 
       8 E47000002                  Sheffield City Region          
       9 E47000004                  Liverpool City Region          
      10 E47000011                  North of Tyne                  
      11 E47000010                  North East                     
      
      [[3]]
      # A tibble: 11 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000007                  West Midlands                  
       5 E47000001                  Greater Manchester             
       6 E47000006                  Tees Valley                    
       7 E47000003                  West Yorkshire                 
       8 E47000002                  Sheffield City Region          
       9 E47000004                  Liverpool City Region          
      10 E47000011                  North of Tyne                  
      11 E47000010                  North East                     
      
      [[4]]
      # A tibble: 11 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000007                  West Midlands                  
       5 E47000001                  Greater Manchester             
       6 E47000006                  Tees Valley                    
       7 E47000003                  West Yorkshire                 
       8 E47000002                  Sheffield City Region          
       9 E47000004                  Liverpool City Region          
      10 E47000011                  North of Tyne                  
      11 E47000010                  North East                     
      
      [[5]]
      # A tibble: 11 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000007                  West Midlands                  
       5 E47000001                  Greater Manchester             
       6 E47000006                  Tees Valley                    
       7 E47000003                  West Yorkshire                 
       8 E47000002                  South Yorkshire                
       9 E47000004                  Liverpool City Region          
      10 E47000011                  North of Tyne                  
      11 E47000010                  North East                     
      
      [[6]]
      # A tibble: 11 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000007                  West Midlands                  
       5 E47000001                  Greater Manchester             
       6 E47000006                  Tees Valley                    
       7 E47000003                  West Yorkshire                 
       8 E47000002                  South Yorkshire                
       9 E47000004                  Liverpool City Region          
      10 E47000011                  North of Tyne                  
      11 E47000010                  North East                     
      
      [[7]]
      # A tibble: 11 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000007                  West Midlands                  
       5 E47000001                  Greater Manchester             
       6 E47000006                  Tees Valley                    
       7 E47000003                  West Yorkshire                 
       8 E47000002                  South Yorkshire                
       9 E47000004                  Liverpool City Region          
      10 E47000011                  North of Tyne                  
      11 E47000010                  North East                     
      
      [[8]]
      # A tibble: 12 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000013                  East Midlands                  
       5 E47000007                  West Midlands                  
       6 E47000001                  Greater Manchester             
       7 E47000006                  Tees Valley                    
       8 E47000003                  West Yorkshire                 
       9 E47000012                  York and North Yorkshire       
      10 E47000002                  South Yorkshire                
      11 E47000004                  Liverpool City Region          
      12 E47000014                  North East                     
      
      [[9]]
      # A tibble: 16 x 2
         english_devolved_area_code english_devolved_area_name     
         <chr>                      <chr>                          
       1 E61000001                  Greater London Authority       
       2 E47000009                  West of England                
       3 E47000008                  Cambridgeshire and Peterborough
       4 E47000013                  East Midlands                  
       5 E47000017                  Greater Lincolnshire           
       6 E47000007                  West Midlands                  
       7 E47000001                  Greater Manchester             
       8 E47000006                  Tees Valley                    
       9 E47000003                  West Yorkshire                 
      10 E47000012                  York and North Yorkshire       
      11 E47000018                  Lancashire                     
      12 E47000002                  South Yorkshire                
      13 E47000004                  Liverpool City Region          
      14 E47000015                  Devon and Torbay               
      15 E47000014                  North East                     
      16 E47000016                  Hull and East Yorkshire        
      

