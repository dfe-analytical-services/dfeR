# Load package and dependencies
devtools::load_all()

# Load and clean LA code data from a file
load_la_codes <- function(file_path) {
  # read in data
  data.table::fread(file_path) %>%
    # rename columns
    dplyr::rename(
      la_name = 1,
      old_la_code = 2,
      new_la_code = 3
    )
}

# Combine all LA code data
all_la_codes <- dplyr::bind_rows(
  load_la_codes("data/EnglishLaNameCodes.csv"),
  load_la_codes("data/WelshLaNameCodes.csv"),
  load_la_codes("data/OtherLaNameCodes.csv")
) %>%
  # clean up the strings in the la_name column
  dplyr::mutate(
    la_name = gsub("^[A-Za-z]+ [A-Za-z]+ \\([^)]*\\) ", "", la_name),
    la_name = gsub("^[A-Za-z]+-LGR [0-9]+ ", "", la_name),
    old_la_code = as.character(old_la_code)
  )

# Identify missing LA codes from screener data
missing_3_digit_la_codes <- all_la_codes %>%
  dplyr::full_join(
    data.table::fread("data/las.csv") %>%
      dplyr::select(new_la_code, la_name, screener_old_la_code = old_la_code),
    by = c("la_name", "new_la_code")
  ) %>%
  dplyr::filter(is.na(old_la_code) & !is.na(screener_old_la_code)) %>%
  dplyr::filter(screener_old_la_code != "x") %>%
  dplyr::select(-old_la_code) %>%
  dplyr::rename(old_la_code = screener_old_la_code) %>%
  dplyr::distinct()

# Final GIAS LA codes including missing ones
old_3_digit_la_codes <- all_la_codes %>%
  dplyr::bind_rows(missing_3_digit_la_codes)

# Write the data into the package ---------------------------------------------
usethis::use_data(old_3_digit_la_codes, overwrite = TRUE)
