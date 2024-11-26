library(tidyverse)
library(stringr)
setwd('/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/age_discrimination')

program_language  = read.csv('output/data/linkedin/programming_languages.csv')
head(program_language)
# Convert the Language.Name variable to lowercase
program_language$Language.Name <- tolower(program_language$Language.Name)
programming_languages  <- program_language$Language.Name
#Change the name of SAS language to just sas
programming_languages[programming_languages == "sas language"]  <- 'sas'

# List all files that start with "edu_" in the specified folder
data_path  <-  "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china/data/linkedin"
files <- list.files(path = data_path, pattern = "^skill_", full.names = TRUE)
i = 1

for (file in files) {
skill = read.csv(file)
# Convert skill_raw to lowercase (for consistent matching)
skill <- skill %>%
  mutate(skill_raw = tolower(skill_raw))

skill  <- skill  %>%  mutate(skill_raw = case_when(
      tolower(skill_raw) == "structured query language" ~ "sql",
      TRUE ~ skill_raw
    ))

# For each user_id, check if any of the skill_raw values match the programming language pattern
identify_coders <- function(skill, program_language) {

  # Group by user_id and check for programming skills
  result <- skill %>%
    # Convert skills to lowercase
    mutate(skill_raw = tolower(skill_raw)) %>%
    # Group by user_id
    group_by(user_id) %>%
    # Check if any skill matches a programming language
    summarize(can_code = any(skill_raw %in% programming_languages)) %>%
    # Convert back to regular dataframe
    ungroup()
    
  return(result)
}

# retain only one row per user_id with can_code information
skill_summary <- identify_coders(skill, program_language)

skill2  <- skill  %>% filter(skill_raw %in% programming_languages)

write.csv(skill_summary, paste0('output/data/linkedin/can_code_', i, '.csv'), row.names = F)
write.csv(skill2, paste0('output/data/linkedin/programmer_and_languages_', i, '.csv'), row.names = F)
i = i + 1
}

