# location counts per year are consistent

    Code
      lapply(2017:2025, fetch_mayoral)
    Output
      [[1]]
      # A tibble: 9 x 2
        cauth_code cauth_name                     
        <chr>      <chr>                          
      1 E47000009  West of England                
      2 E47000008  Cambridgeshire and Peterborough
      3 E47000007  West Midlands                  
      4 E47000001  Greater Manchester             
      5 E47000006  Tees Valley                    
      6 E47000003  West Yorkshire                 
      7 E47000002  Sheffield City Region          
      8 E47000004  Liverpool City Region          
      9 E47000005  North East                     
      
      [[2]]
      # A tibble: 10 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000007  West Midlands                  
       4 E47000001  Greater Manchester             
       5 E47000006  Tees Valley                    
       6 E47000003  West Yorkshire                 
       7 E47000002  Sheffield City Region          
       8 E47000004  Liverpool City Region          
       9 E47000011  North of Tyne                  
      10 E47000010  North East                     
      
      [[3]]
      # A tibble: 10 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000007  West Midlands                  
       4 E47000001  Greater Manchester             
       5 E47000006  Tees Valley                    
       6 E47000003  West Yorkshire                 
       7 E47000002  Sheffield City Region          
       8 E47000004  Liverpool City Region          
       9 E47000011  North of Tyne                  
      10 E47000010  North East                     
      
      [[4]]
      # A tibble: 10 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000007  West Midlands                  
       4 E47000001  Greater Manchester             
       5 E47000006  Tees Valley                    
       6 E47000003  West Yorkshire                 
       7 E47000002  Sheffield City Region          
       8 E47000004  Liverpool City Region          
       9 E47000011  North of Tyne                  
      10 E47000010  North East                     
      
      [[5]]
      # A tibble: 10 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000007  West Midlands                  
       4 E47000001  Greater Manchester             
       5 E47000006  Tees Valley                    
       6 E47000003  West Yorkshire                 
       7 E47000002  South Yorkshire                
       8 E47000004  Liverpool City Region          
       9 E47000011  North of Tyne                  
      10 E47000010  North East                     
      
      [[6]]
      # A tibble: 10 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000007  West Midlands                  
       4 E47000001  Greater Manchester             
       5 E47000006  Tees Valley                    
       6 E47000003  West Yorkshire                 
       7 E47000002  South Yorkshire                
       8 E47000004  Liverpool City Region          
       9 E47000011  North of Tyne                  
      10 E47000010  North East                     
      
      [[7]]
      # A tibble: 10 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000007  West Midlands                  
       4 E47000001  Greater Manchester             
       5 E47000006  Tees Valley                    
       6 E47000003  West Yorkshire                 
       7 E47000002  South Yorkshire                
       8 E47000004  Liverpool City Region          
       9 E47000011  North of Tyne                  
      10 E47000010  North East                     
      
      [[8]]
      # A tibble: 11 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000013  East Midlands                  
       4 E47000007  West Midlands                  
       5 E47000001  Greater Manchester             
       6 E47000006  Tees Valley                    
       7 E47000003  West Yorkshire                 
       8 E47000012  York and North Yorkshire       
       9 E47000002  South Yorkshire                
      10 E47000004  Liverpool City Region          
      11 E47000014  North East                     
      
      [[9]]
      # A tibble: 15 x 2
         cauth_code cauth_name                     
         <chr>      <chr>                          
       1 E47000009  West of England                
       2 E47000008  Cambridgeshire and Peterborough
       3 E47000013  East Midlands                  
       4 E47000017  Greater Lincolnshire           
       5 E47000007  West Midlands                  
       6 E47000001  Greater Manchester             
       7 E47000006  Tees Valley                    
       8 E47000003  West Yorkshire                 
       9 E47000012  York and North Yorkshire       
      10 E47000018  Lancashire                     
      11 E47000002  South Yorkshire                
      12 E47000004  Liverpool City Region          
      13 E47000015  Devon and Torbay               
      14 E47000014  North East                     
      15 E47000016  Hull and East Yorkshire        
      

