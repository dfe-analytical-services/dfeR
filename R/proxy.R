setup_proxy <- function(){

  # Ask the user for their password
  password <- rstudioapi::askForPassword("Please provide your Windows Password to authenticate.")

  # Construct proxy url using username and password
  proxy_encoded_url <- URLencode(
    paste0(
      "http://ad\\",
      Sys.getenv("USERNAME"),
      ":",
      password,
      "@mwg.proxy.ad.hq.dept:9090"
    ))

  # Construct commands to create environment variables
  http_proxy_cmd <-  paste0("setx http_proxy ", proxy_encoded_url)
  https_proxy_cmd <-  paste0("setx https_proxy ", proxy_encoded_url)

  # Create system environment variables
  system(http_proxy_cmd)
  system(https_proxy_cmd)

  # Set download file method for renv
  system("setx RENV_DOWNLOAD_FILE_METHOD wininet")

  # Pip folder variable
  pip_folder <- file.path(Sys.getenv("APPDATA"), "pip")

  # Create pip.ini file with trusted website for python
  if (!dir.exists(pip_folder)) dir.create(pip_folder)
  
  # SSL verify false (to make Azure Devops work internally). Analyst should only pull from trusted repos.
  system("git config --global http.sslVerify false")

  write("[global]
trusted-host = pypi.python.org
               pypi.org
               files.pythonhosted.org",
        file = file.path(pip_folder, "pip.ini"))

}
