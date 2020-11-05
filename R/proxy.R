setup_proxy <- function(){

  # Construct proxy url using username and password
  proxy_encoded_url <- URLencode(
    paste0(
      "http://",
      Sys.getenv("USERNAME"),
      "@mwg.proxy.ad.hq.dept:9090"
    ))

  # Construct commands to create environment variables
  http_proxy_cmd <-  paste0("setx http_proxy ", proxy_encoded_url)
  https_proxy_cmd <-  paste0("setx https_proxy ", proxy_encoded_url)

  # Create system environment variables
  system(http_proxy_cmd)
  system(https_proxy_cmd)
  
  # Set renv to use wininet
  system("setx RENV_DOWNLOAD_FILE_METHOD wininet")
}
