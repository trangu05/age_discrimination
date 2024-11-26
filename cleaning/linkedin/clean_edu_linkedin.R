setwd("/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china")

data_path <- "data/linkedin"

library(tidyverse)
# List all files that start with "edu_" in the specified folder
files <- list.files(path = data_path, pattern = "^edu_", full.names = TRUE)
i = 1
# Loop through each of those files
for (file in files) {
  library(dplyr)
  edu <- read.csv(file)

  edu <- edu %>%
    mutate(
      startdate = as.Date(startdate),
      enddate = as.Date(enddate),
      # Calculate duration in years for each degree
      duration_years = as.numeric(difftime(enddate, startdate, units = "weeks")) / 52.25
    )
  
  # Filter to keep only the Bachelor degree with the earliest end date for each user
  edu <- edu %>%
    group_by(user_id) %>%
    arrange(degree == "Bachelor", enddate) %>% # Sort Bachelors by enddate within each user group
    filter(!(degree == "Bachelor" & duplicated(degree))) %>% # Keep only the earliest Bachelor degree
    ungroup()
  
  # Calculate the age variable with the updated conditions
  edu <- edu %>%
    mutate(birthyr= case_when(
      # If the degree is "Bachelor"
      degree == "Bachelor" ~ as.numeric(format(startdate, "%Y")) - 18,
      
      # If the degree is "High School"
      degree == "High School" ~ as.numeric(format(startdate, "%Y")) - 14,
      
      # If the degree is unknown, the duration is over 2 years, and the user has another degree like "Master" or "Doctor"
      (is.na(degree) | degree == "Unknown") & duration_years > 2 & any(degree %in% c("Master", "Doctor")) ~ as.numeric(format(startdate, "%Y")) - 18,
      
      # Otherwise, set age to NA
      TRUE ~ NA_real_
    ))
  
  # Remove duration_years if not needed
  edu <- select(edu, -duration_years)
  edu$age <- 2024 - edu$birthyr
  edu2 <- edu %>% filter(!is.na(age))
  
  write.csv(edu2, file  = paste0("age_discrimination/output/data/linkedin/edu_cleaned_",i, '.csv'), row.names = F)
  i = i +1

}
