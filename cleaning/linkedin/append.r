setwd("/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china")

#Append files

data_path  <- "age_discrimination/output/data/linkedin"

library(dplyr)
library(purrr)


combine_files <- function(folder_path, pattern) {
  # List all CSV files in the folder that start with "edu"
  files <- list.files(
    path = folder_path,
    pattern = paste0("^", pattern, ".*\\.csv$"),  # matches files starting with "edu" and ending with .csv
    full.names = TRUE
  )
  
  # Check if any matching files were found
  if (length(files) == 0) {
    stop("No CSV files starting with the pattern found in the specified folder")
  }
  
  # Read and combine all files
  combined_data <- files %>%
    lapply(function(file) {
      df <- read.csv(file)
      df$source_file <- basename(file)  # Add source filename as a column
      return(df)
    }) %>%
    bind_rows()


  return(combined_data)
}

edu_total  <- combine_files(data_path, "edu")
can_code_total  <- combine_files(data_path, "can")
programmer_languages_total  <- combine_files(data_path, "programmer")

edu_total  <-  edu_total %>%
  group_by(user_id) %>%
  arrange(user_id, desc(degree)) %>%  # Ensure Bachelor's degree comes first if both are present
  filter(row_number() == 1) %>%  # Keep only the first entry per user_id (Bachelor's if both exist)
  ungroup()

 merged_data <- edu_total %>%
    # Left join with can_code status (keep all users)
    left_join(can_code_total, by = "user_id") %>%
    # Replace NA in can_code with FALSE (for users not in can_code_total)
    mutate(can_code = ifelse(is.na(can_code), FALSE, can_code))

# Then add programming languages
  final_data <- merged_data %>%
    # Left join with programmer languages
    left_join(programmer_languages_total,
      # First group programmer_language_total to create a concatenated list of languages per user
     # programmer_languages_total %>%
        #group_by(user_id) %>%
       # summarize(programming_languages = paste(programming_language, collapse = ", ")),
      by = "user_id"
    ) 

# Export data

write.csv(final_data, 'age_discrimination/output/data/linkedin/total.csv', row.names = F)
