#' Sets up Environment Variables to authenticate with the DfE Proxy for working with web content.
#'
#' This function sets up User environment variables http_proxy and https_proxy so that R (and other software) can access web conent. E.g. install packages from github, web scrape etc.
#'
#' This function will need to be re-run every time you change your windows password.
#'
#' @keywords setup
#' @examples
#' \dontrun{
#' setup_proxy()
#' }

setup_proxy <- function(){
  
  # Ask the user for their password
  password <- rstudioapi::askForPassword("Please provide your Windows Password to authenticate.")
  
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
