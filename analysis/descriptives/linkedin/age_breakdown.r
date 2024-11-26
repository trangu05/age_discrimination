##### Exploratory look
library(tidyverse)
library(ggplot2)
setwd("/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity(2)/online job ads_china")
total  <- read.csv('age_discrimination/output/data/linkedin/total.csv')
# Keep workers 18-65
total  <- total  %>% filter(age > 17 & age <65)
#Remove art as a programming language since it probably means "Art"
total   <- total  %>% filter(skill_raw != "art" | is.na(skill_raw))

### What's the percentage of each age bracket that can code?
# Create the agegroup variable in the total dataset
total$agegroup <- cut(
  total$age,
  breaks = c(18, 25, 35, 45, 55, 65),
  labels = c("18-24", "25-34", "35-44", "45-54", "55-64"),
  right = FALSE
)

total_distinct  <- total %>% distinct(user_id, .keep_all = TRUE)
total_distinct_summary  <- total_distinct   %>%  group_by(agegroup)  %>% 
                            summarize(proportion_can_code = mean(can_code == 1))
p1  <- ggplot(total_distinct_summary, aes(x = agegroup, y = proportion_can_code)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Proportion of Coders by Age Group",
       x = "Age Group", y = "Proportion of Coders") +
  theme_minimal()
  m0  <- lm(can_code ~ agegroup, data = total_distinct)
  summary(m0)
ggsave("age_discrimination/output/figures/linkedin/proportion_of_coders_by_agegroup.png", plot = p1, width = 8, height = 6, dpi = 300)



#Under 35 vs Older than 55 distinction
# Create the u35 variable based on the age conditions
total_distinct <- total_distinct %>%
  mutate(
    u35 = case_when(
      age < 35 ~ "Under 35",
      age > 55 ~ "Older than 55",
      TRUE ~ "35-55"
    ),
    # Label the u35 variable
    u35_label = case_when(
      u35 == 1 ~ "Under 35",
      u35 == 2 ~ "Older than 55",
      u35 == 3 ~ "Else"
    )
  )


total_distinct_u35  <- total_distinct  %>% group_by(u35)  %>% 
                        summarize(proportion_can_code = mean(can_code == 1))

total_distinct_u35 <- total_distinct_u35 %>%
  mutate(u35 = factor(u35, levels = c("Under 35", "35-55", "Older than 55")))

p2  <- total_distinct_u35  %>% ggplot(aes(x = u35, y = proportion_can_code)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Proportion of Coders by Age Group",
       x = "Age Group", y = "Proportion of Coders") +
  theme_minimal()
p2
ggsave("age_discrimination/output/figures/linkedin/proportion_of_coders_under35.png", plot = p2, width = 8, height = 6, dpi = 300)

#### What's the age distribution of the coders?

coders  <- total_distinct  %>% filter(can_code == 1)
png("age_discrimination/output/figures/linkedin/histogram_of_coders_age.png", width = 800, height = 600)
hist(coders$age, prob = TRUE, main = "Histogram of Coders' Age", 
     xlab = "Age", ylab = "Probability", col = "lightblue", border = "black")
dev.off()

#######################################
###### Condition on being able to code, what's the composition of skills among the age groups? 
#######################################
skill  <-  total  %>% select(user_id, age, agegroup, skill_raw, can_code)  %>% arrange(user_id)  %>% filter(can_code == 1)
# Identify the major languages
language_counts <- skill %>%
  count(skill_raw) %>%
  arrange(desc(n))

# Set a threshold, e.g., top 10 languages. ABSOLUTE POPULARITY
top_languages <- language_counts %>%
  top_n(10, n) %>%
  pull(skill_raw)

skill <- skill %>%
  mutate(skill_major = ifelse(skill_raw %in% top_languages, skill_raw, "Other"))

library(gridExtra)

# Count unique users per age group and programming language
language_by_age <- skill %>%
  count(agegroup, skill_major) %>%
  group_by(agegroup) %>%
  mutate(proportion = n / sum(n))  %>% filter(skill_major != "Other")

# Now generate the individual plots for each age group
q1 <- ggplot(subset(language_by_age, agegroup == "18-24"), 
             aes(x = reorder(skill_major, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "skyblue") + 
  coord_flip() + 
  labs(title = "18-24 Age Group", x = "Language", y = "Proportion")

q2 <- ggplot(subset(language_by_age, agegroup == "25-34"), 
             aes(x = reorder(skill_major, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "lightgreen") + 
  coord_flip() + 
  labs(title = "25-34 Age Group", x = "Language", y = "Proportion")

q3 <- ggplot(subset(language_by_age, agegroup == "35-44"), 
             aes(x = reorder(skill_major, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "coral") + 
  coord_flip() + 
  labs(title = "35-44 Age Group", x = "Language", y = "Proportion")

q4 <- ggplot(subset(language_by_age, agegroup == "45-54"), 
             aes(x = reorder(skill_major, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "orchid") + 
  coord_flip() + 
  labs(title = "45-54 Age Group", x = "Language", y = "Proportion")

q5 <- ggplot(subset(language_by_age, agegroup == "55-64"), 
             aes(x = reorder(skill_major, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "lightcoral") + 
  coord_flip() + 
  labs(title = "55-64 Age Group", x = "Language", y = "Proportion")

# Now arrange all plots in a grid using grid.arrange
png("age_discrimination/output/figures/linkedin/top_10_by_age_group_abs.png",
width = 1200, height = 900)
grid.arrange(q1, q2, q3, q4, q5, nrow = 3)
dev.off()

#Top languages, RELATIVE POPULARITY
# First, calculate the number of unique users for each language in each age group
language_by_age_counts <- skill %>%
  group_by(agegroup, skill_raw, user_id) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  group_by(agegroup, skill_raw) %>%
  summarise(user_count = n_distinct(user_id)) %>%
  ungroup()

# Calculate the total number of users in each age group to get proportions
total_users_by_age <- skill %>%
  group_by(agegroup) %>%
  summarise(total_users = n_distinct(user_id))

# Join the data with total users to calculate the proportion
language_by_age_proportion <- language_by_age_counts %>%
  left_join(total_users_by_age, by = "agegroup") %>%
  mutate(proportion = user_count / total_users)

# Now, for each age group, find the top 10 languages by proportion
top_languages_by_age <- language_by_age_proportion %>%
  group_by(agegroup) %>%
  arrange(agegroup, desc(proportion)) %>%
  slice_max(proportion, n = 10) %>%
  ungroup()

# Now let's visualize the top 10 languages for each age group by proportion
q1 <- ggplot(subset(top_languages_by_age, agegroup == "18-24"), 
             aes(x = reorder(skill_raw, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "skyblue") + 
  coord_flip() + 
  labs(title = "Top 10 Languages - 18-24 Age Group", x = "Language", y = "Proportion")

q2 <- ggplot(subset(top_languages_by_age, agegroup == "25-34"), 
             aes(x = reorder(skill_raw, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "lightgreen") + 
  coord_flip() + 
  labs(title = "Top 10 Languages - 25-34 Age Group", x = "Language", y = "Proportion")

q3 <- ggplot(subset(top_languages_by_age, agegroup == "35-44"), 
             aes(x = reorder(skill_raw, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "coral") + 
  coord_flip() + 
  labs(title = "Top 10 Languages - 35-44 Age Group", x = "Language", y = "Proportion")

q4 <- ggplot(subset(top_languages_by_age, agegroup == "45-54"), 
             aes(x = reorder(skill_raw, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "orchid") + 
  coord_flip() + 
  labs(title = "Top 10 Languages - 45-54 Age Group", x = "Language", y = "Proportion")

q5 <- ggplot(subset(top_languages_by_age, agegroup == "55-64"), 
             aes(x = reorder(skill_raw, proportion), y = proportion)) + 
  geom_bar(stat = "identity", fill = "lightcoral") + 
  coord_flip() + 
  labs(title = "Top 10 Languages - 55-64 Age Group", x = "Language", y = "Proportion")

# Now arrange all plots in a grid using grid.arrange
png("age_discrimination/output/figures/linkedin/top_10_by_age_group_rel.png",
width = 1200, height = 900)
grid.arrange(q1, q2, q3, q4, q5, nrow = 3)
dev.off()

# Correlation between create year and age of the user
create_year  <- read.csv('age_discrimination/output/data/linkedin/programming_languages.csv')
create_year$Language.Name  <- tolower(create_year$Language.Name)

# 
# skill_sum <-  skill  %>% group_by(skill_raw)  %>% 
# summarize(avg_userage = mean(age, na.rm = T),
# median_userage = median(age, na.rm = T), n = n())
# merged_skill_create  <- skill_sum  %>% filter(n > 100)  %>% 
# inner_join(create_year, by = c( 'skill_raw' = 'Language.Name'))
# merged_skill_create  <- merged_skill_create  %>% mutate(age_language = 2024-Created.Year)

#m1  <- lm(avg_userage ~ age_language, data = merged_total_create)
#summary(m1)
#m2  <- lm(median_userage ~ age_language, data = merged_total_create)

#plot(avg_userage ~ age_language, data = merged_total_create)


# Age distribution of the most popular languages 

language_age_proportion <- skill %>%
  group_by(skill_raw, agegroup) %>%
  summarise(count = n()) %>%
  group_by(skill_raw) %>%
  mutate(proportion = count / sum(count))

# Plot the proportions by programming language and age group

p3  <- language_age_proportion  %>%  filter(skill_raw %in%  c('python', 'r', 'stata', 'cobol','fortran')) %>% ggplot(aes(x = skill_raw, y = proportion, fill = agegroup)) +
  geom_bar(stat = "identity", position = "stack") +  # Use position = "dodge" for side-by-side bars
  labs(title = "Proportion of Users by Programming Language and Age Group", 
       x = "Programming Language", y = "Proportion of Users", fill = "Age Group") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for better readability

ggsave('age_discrimination/output/figures/linkedin/selected_languages_proportion.png',plot = p3, width = 8, height = 6, dpi = 300)
#Under 35 vs older 35
skill <- skill %>%
  mutate(
    u35 = case_when(
      age < 35 ~ "Under 35",
      age > 45 ~ "Older than 45",
      TRUE ~ "35-45"
    ),
    # Label the u35 variable
    u35_label = case_when(
      u35 == 1 ~ "Under 35",
      u35 == 2 ~ "Older than 45",
      u35 == 3 ~ "Else"
    )
  )
# Convert u35 to a factor with a specified order
skill <- skill %>%
  mutate(u35 = factor(u35, levels = c("Under 35", "35-45", "Older than 45")))

language_age_proportion2 <- skill %>%
  group_by(skill_raw, u35) %>%
  summarise(count = n()) %>%
  group_by(skill_raw) %>%
  mutate(proportion = count / sum(count))

# Plot the proportions by programming language and age group
p4  <- language_age_proportion2  %>%  filter(skill_raw %in%  c('python', 'sas', 'spss', 
'r', 'stata', 'cobol','fortran')) %>% 
 ggplot(aes(x = skill_raw, y = proportion, fill = u35)) +
  geom_bar(stat = "identity", position = "stack") +  
  labs(title = "Proportion of Users by Programming Language and Age Group", 
       x = "Programming Language", y = "Proportion of Users", fill = "Age Group") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  
ggsave('age_discrimination/output/figures/linkedin/selected_languages_proportion.png',plot = p4, width = 8, height = 6, dpi = 300)



