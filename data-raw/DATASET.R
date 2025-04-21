## code to prepare `DATASET` dataset goes here

library(dplyr)
library(readr)
usu_data <- read_csv("data-raw/usu_data.csv")


usu_data <- usu_data %>% select(-`...1`)

usethis::use_data(usu_data, overwrite = TRUE)


usethis::use_data(usu_data, overwrite = TRUE)
