## code to prepare `DATASET` dataset goes here

library(readr)
USUdata <- read_csv("data-raw/USUdata.csv")

usethis::use_data(DATASET, overwrite = TRUE)
