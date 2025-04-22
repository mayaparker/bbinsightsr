library(dplyr)
library(readr)

# Load and clean play-by-play data
usu_data <- read_csv("data-raw/usu_data.csv") |>
  select(-`...1`)

usethis::use_data(usu_data, overwrite = TRUE)
