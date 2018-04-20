#' Set proxy settings for use with the httr package
#'
#' This function sets the proxy setting for httr
#'
#' If no argument is supplied, the user will be prompted for both username and
#' password.
#'
#' If given one argument it is assumed that this is the path to the directory
#' containing the files username.txt and password.txt. Each file should contain
#' a single line of text: the username and password respectively.
#'
#' If given two arguments it is assumed that this is username and password.
#'
#' @param arg1 Character. Either the path to a folder containg files called username.txt and password.txt that contain the username and password respectively, or a username
#' @param arg2 Character. The password, if the username is passed to arg1
#'
#' @export
#'
#' @examples
#'
#' # Supplying a username and password
#' set_DfE_proxy("myusername", "mypassword")
#'
#' # Supplying a path to a folder containing username.txt and password.txt
#' set_DfE_proxy("C:/MySecretLoginFolder/")
set_DfE_proxy <- function(arg1 = NA, arg2 = NA){
  if(is.na(arg1)){
    username <- winDialogString("Username:", "")
    password <- winDialogString("Password:", "")
  } else if(is.na(arg2)){
    username <- readLines(file.path(arg1,"username.txt"))
    password <- readLines(file.path(arg1,"password.txt"))
  } else {
    username <- arg1
    password <- arg2
  }

  httr::set_config(httr::use_proxy(url = paste("http://ad\\", username, ":", password, "@192.168.2.40", sep = ""), port = 8080))

}
