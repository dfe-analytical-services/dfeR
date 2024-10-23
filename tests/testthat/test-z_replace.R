# Create a data frame for testing

df <- data.frame(a=c(1,2,3,as.double(NA)),
                  b= c(1,2,as.double(NA),4),
                  ScHOoL=c("school1","school2",NA_character_,"school3"),
                  Academic_Year= c(2008,2023,2024,as.double(NA)))

test_that("z_replace outputs are as expected", {
  #testing standard functionality
  expect_equal(z_replace(df), data.frame(a=c("1","2","3","z"),
                                         b= c("1","2","z",4),
                                         ScHOoL=c("school1","school2",NA_character_,"school3"),
                                         Academic_Year= c(2008,2023,2024,as.double(NA))))

  #testing altnerative replacement

  #testing adding more excluded columns

  #testing adding included columns
})
