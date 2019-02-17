#' Install system dependencies that Rtools (and in turn packrat) require to build packages with compiled code on Windows
#'
#' This function install windows system dependencies that are required for building packages with compiled code. In particular it installs the local323.zip and curl-7.40.0.zip from the R tools goodies section of cran: https://www.stats.ox.ac.uk/pub/Rtools/goodies/multilib/ and makes them available to Rtools. \cr \cr
#'
#' The function extracts the zips to a folder (default is c:/extsoft) and creates a makevars file that points rtools to the packages. The default location of this is ~/.R./makevars. Usually ~ is My Documents. \cr
#'
#' Without this setup you will find that packages such as XML, stringi, RCurl will throw errors when compiling (usually when restoring old versions with packrat).
#'
#' @param extsoft_dir The directory you would like the external software to be installed in
#' @return Updated folder structure
#' @keywords environment, setup
#' @export
#' @examples
#' \dontrun{
#' setup_rtools_pkgs()
#' }

setup_rtools_pkgs <- function(extsoft_dir = 'c:/extsoft'){

  if (!(Sys.info()["sysname"] == "Windows")) {

    message("Windows only function. On Mac/Linux use respctive package managers.")

  } else {

    # Create temp directory
    temp_dir <- tempdir()

    # Download the local323 zip of system dependencies
    download.file('https://www.stats.ox.ac.uk/pub/Rtools/goodies/multilib/local323.zip', paste0(temp_dir,'/local323.zip'))

    # Download curl specific zip that is not captured in local323
    download.file('https://www.stats.ox.ac.uk/pub/Rtools/goodies/multilib/curl-7.40.0.zip', paste0(temp_dir,'curl-7.40.0.zip'))

    # Check if c:/extsoft exists otherwise make it
    if (!dir.exists(extsoft_dir)) dir.create(extsoft_dir)

    # Unzip both of the zips into the directory
    unzip(paste0(temp_dir,'/local323.zip'), exdir = extsoft_dir)
    unzip(paste0(temp_dir,'curl-7.40.0.zip'), exdir = extsoft_dir)

    # Check if ~/.R directory exists (this is folder where custom makevars go)
    if (!dir.exists('~/.R')) dir.create('~/.R')

    # Define custom makevars file
    makevars <- c(
      paste0('LOCAL_SOFT = ', extsoft_dir),
      paste0('LIB_XML = ', extsoft_dir),
      'ifneq ($(strip $(LOCAL_SOFT)),)',
      'LOCAL_CPPFLAGS = -I"$(LOCAL_SOFT)/include"',
      'LOCAL_LIBS = -L"$(LOCAL_SOFT)/lib$(R_ARCH)" -L"$(LOCAL_SOFT)/lib"',
      'endif'
    )

    # Write makevars file to default user makevars location
    writeLines(makevars, '~/.R./makevars')

    # Return success
    message('Rtools external packages succesffully installed!')
  }

}

