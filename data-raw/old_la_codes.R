# Create the internal old_la_codes data set ----------------------------------

# This data is used to add 'old' 3 digit la codes to the wd_pcon_lad_la_reg_ctry
# lookup table in dfeR


# Get and process data from GIAS ------------------------------------------


##############################################################################
# IMPORTANT: Please make sure to read the data-raw/old_la_codes.md file to read
# about the manual steps needed before running this script
##############################################################################

# Load package and dependencies
devtools::load_all()

# Load and clean LA code data from a file
load_la_codes <- function(file_path) {
  # read in data
  data.table::fread(file_path) |>
    # rename columns
    dplyr::rename(
      la_name = 1,
      old_la_code = 2,
      new_la_code = 3
    )
}

# Combine all LA code data
gias_la_codes <- dplyr::bind_rows(
  load_la_codes("data/EnglishLaNameCodes.csv"),
  load_la_codes("data/WelshLaNameCodes.csv"),
  load_la_codes("data/OtherLaNameCodes.csv")
) |>
  # clean up the strings in the la_name column
  dplyr::mutate(
    la_name = gsub("^[A-Za-z]+ [A-Za-z]+ \\([^)]*\\) ", "", la_name),
    la_name = gsub("^[A-Za-z]+-LGR [0-9]+ ", "", la_name),
    old_la_code = as.character(old_la_code)
  ) |>
  # rename old_la_code column to gias_old_la_code to make identifying columns
  # easier for the joins
  dplyr::rename(gias_old_la_code = old_la_code)


# Create the internal old_la_codes data set ----------------------------------

# This data is used to add 'old' 3 digit la codes to the wd_pcon_lad_la_reg_ctry
# lookup table in dfeR

#####################################################################
# NOTE: the missing rows we extract from the screener after the two joins
# are due to  9 digit codes that have become inactive and are therefore
# no longer available on the GIAS data. We are adding them to this lookup to
# ensure that we have a complete list of 'old' LA codes at different points
# in time.
#####################################################################

old_la_codes <- dfeR::fetch_las() |>
  # left join the la_names and new_la_codes from dfeR::fetch_las() to
  # 'old' 3 digit la codes from GIAS data
  dplyr::left_join(
    gias_la_codes,
    by = c("la_name", "new_la_code")
  ) |>
  # left join the screener 'old' 3 digit la codes
  dplyr::left_join(
    data.table::fread("data/las.csv") |>
      dplyr::select(new_la_code, la_name, screener_old_la_code = old_la_code),
    by = c("la_name", "new_la_code")
  ) |>
  # Identify missing LA codes from the GIAS data and extract any matches for
  # them from screener data
  dplyr::mutate(
    old_la_code = dplyr::if_else(
      is.na(gias_old_la_code) & !is.na(screener_old_la_code),
      screener_old_la_code,
      gias_old_la_code
    )
  ) |>
  # select the columns we need
  dplyr::select(la_name, old_la_code, new_la_code) |>
  # replace any remaining NAs in old_la_code with "z" to indicate no old code
  dplyr::mutate(old_la_code = dplyr::if_else(is.na(old_la_code),
    "z", old_la_code
  )) |>
  # remove duplicates if any
  dplyr::distinct()


# Write the data into the package ---------------------------------------------
usethis::use_data(old_la_codes, internal = TRUE, overwrite = TRUE)
