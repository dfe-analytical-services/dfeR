# This script sets up the variables required to get through the DfE Proxy for R.
# The function is not exported and not intended for use via dfeR.

setup_proxy <- function(){
  
  # Ask the user for their password
  password <- rstudioapi::askForPassword("AD account password")
  
  # Construct proxy url using username and password
  proxy_encoded_url <- URLencode(
    paste0(
      "https://ad\\",
      Sys.getenv("USERNAME"),
      ":",
      password,
      "@192.168.2.40:8080"
    ))
  
  # Construct commands to create environment variables
  http_proxy_cmd <-  paste0("setx http_proxy ", proxy_encoded_url)
  https_proxy_cmd <-  paste0("setx https_proxy ", proxy_encoded_url)
  
  # Create system environment variables
  system(http_proxy_cmd)
  system(https_proxy_cmd)
  
}

setup_proxy()
         
       
