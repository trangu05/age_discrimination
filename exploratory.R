#Merging datasets to check the evolution of wages
rm(list = ls())

library(haven)
library(tidyverse)
path <- "C:/Users/nguye/OneDrive - Yale University/Documents/CHNS"
output_path <- "C:/Users/nguye/OneDrive - Yale University/Documents/age_discrimination/output/"
id <- read_sas(paste0(path,"/","Master_ID_201908/mast_pub_12.sas7bdat" ))
id <- id %>% select(Idind, GENDER, WEST_DOB_Y)
names(id) <- c("idind", "gender", "dob")

income <-  read_sas(paste0(path,"/","Master_Constructed_Income_201804/indinc_10.sas7bdat" ))
income <- income %>% select(wave, t1, urban, index_new, index_old) %>% distinct()
names(income) <- c("wave", "province", "urban", "index_new", 
                   'index_old')

wage <-  read_sas(paste0(path,"/","Master_Income_Categories_201804/wages_12.sas7bdat" ))
wage <- wage %>% select(IDind, WAVE, T1, C5, C5_89, C6, C6_89, C7, C7_89, C8, C8_CLN,
                        JOB, C2, T2)
names(wage) <- c("idind", "wave", "province", "dayspwk", "wagepday", "hrpday","wagepwrk", 
                 "hrpwk", "wrkpwk", "wgpmonth", "wage_flag", "jobnumber", "primary", "urban")
wage$urban <- ifelse(wage$urban == 2, 0, 1)

rst <- read_sas(paste0(path,"/","Master_ID_201908/rst_12.sas7bdat" ))
rst <- rst %>% select(IDind, hhid, WAVE,A8 )
names(rst) <- c("idind", "hhid", "wave", "marital")

edu <- read_sas(paste0(path,"/","Master_Educ_201804/educ_12.sas7bdat" ))
edu <- edu %>% select(IDind, WAVE, A11, A12, hhid, T1)
names(edu) <- c("idind", "wave", "complete_years", "highest_level", "hhid", "province")

merged_data <- merge(id, wage, by = c("idind" ),
                     all.y =  T)
merged_data <- left_join(merged_data, income, by = c("wave", "urban", "province"))


#Remove invalid entries and outliers
merged_data <- merged_data %>% filter(wgpmonth > 0 & wgpmonth < 200000) #3 obs are greater than 200k, 67 are =0


merged_data$year <- merged_data$wave - 1
#merged_data$hrspmonth <- ifelse(merged_data$hrpwk != 0, 
 #                               merged_data$hrpwk*4, 
#                                merged_data$dayspwk*merged_data$hrpday*4)
#merged_data$hrspmonth <- ifelse(merged_data$hrspmonth < 0 | merged_data$hrspmonth >= 168, NA, 
#                                merged_data$hrspmonth)
#merged_data$hrspmonth <- ifelse(merged_data$wgpmonth > 0 & 
#                                  merged_data$hrspmonth == 0, NA, merged_data$hrspmonth)
merged_data$hrspmonth1 <- merged_data$dayspwk*merged_data$hrpday*4
merged_data$hrspmonth1 <- ifelse(merged_data$hrspmonth1 > 0 & merged_data$hrspmonth1 < 672,
                                 merged_data$hrspmonth1, NA)
merged_data$hrspmonth2 <- merged_data$hrpwk*4
merged_data$hrspmonth2 <- ifelse(merged_data$hrspmonth2 > 0 & merged_data$hrspmonth2 < 672,
                                 merged_data$hrspmonth2, NA)
merged_data$diff <- abs(merged_data$hrspmonth1 - merged_data$hrspmonth2)
merged_data$hrspmonth <- ifelse(!is.na(merged_data$hrspmonth1), merged_data$hrspmonth1,
                                merged_data$hrspmonth2)


merged_data$wgphr <- merged_data$wgpmonth / merged_data$hrspmonth

summary(merged_data$wgphr)

#Inflating nominal wage to 2015 dollars
merged_data$wage_inf = merged_data$wgpmonth/merged_data$index_new
merged_data$wgphr_inf <-  merged_data$wgphr/merged_data$index_new

#Age variable
merged_data$age <- merged_data$year - merged_data$dob

#Keep only age between 18-60
merged_data <- merged_data %>% filter(age > 20 & age < 61)

#Remove suspicious outliers
merged_data <-  merged_data %>% filter(wgpmonth < 200000)

#Choose only primary occ
merged_data <- merged_data %>%
  group_by(idind, wave) %>%
  mutate(
    temp = ifelse(wgpmonth == max(wgpmonth), 1, 2)  # Mark the job with the highest wage as primary
  ) %>%
  ungroup()
merged_data$primary_constructed = ifelse(is.na(merged_data$primary), merged_data$temp,merged_data$primary)
merged_data <- merged_data %>% filter(primary_constructed == 1)
merged_data$temp <- NULL

#Divide age into groups
merged_data$age_group <- cut(merged_data$age, 
                    breaks = seq(from = 20, to = max(merged_data$age) + 5, by = 5),
                    include.lowest = TRUE,
                    right = FALSE,
                    labels = paste(seq(20, max(merged_data$age), by = 5),
                                   seq(24, max(merged_data$age), by = 5), sep = "-"))

#Prepare data for graphing
merged_data <- merged_data %>% filter(age_group != "60-24")
merged_data$wave_group <- ifelse(merged_data$wave > 2008, "2009-2015",
                                 ifelse(merged_data$wave < 2008 & merged_data$wave > 1999,
                                        "2000-2006", 
                                        "1989-1997"))
merged_data$birthyr <- merged_data$wave - merged_data$age
merged_data$log_wage <- log(merged_data$wage_inf)
merged_data$log_wagehr <- log(merged_data$wgphr_inf)


#Choose primary job only

#Cross-sectional income 
cross_section <- merged_data  %>% filter(!is.na(wage_inf)) %>% 
  group_by(age_group, wave_group ) %>% 
  summarize(mean_wage = mean(wage_inf, na.rm = T),
                                                 mean_log_wage = mean(log_wage),
                                                 obs = n())
cross_section_phr <- merged_data  %>% filter(!is.na(wgphr_inf)) %>% 
  group_by(age_group, wave_group ) %>% summarize(mean_wagephr = mean(wgphr_inf, na.rm = T),
                                                 mean_log_wagephr = mean(log(wgphr_inf), na.rm=T),
                                                 obs = n())

cross_section2 <- merged_data  %>% filter(!is.na(wage_inf)) %>% 
  group_by(age, wave_group ) %>% 
  summarize(mean_wage = mean(wage_inf, na.rm = T),
            mean_log_wage = mean(log_wage),
            obs = n())

cross_section_phr2 <- merged_data  %>% filter(!is.na(wgphr_inf)) %>% 
  group_by(age, wave_group ) %>% summarize(mean_wagephr = mean(wgphr_inf, na.rm = T),
                                           mean_log_wagephr = mean(log(wgphr_inf), na.rm=T),
                                           
                                           obs = n())
                                                          
library(ggplot2)

# Creating the line plot
ggplot(cross_section, aes(x = age_group, y = mean_wage, group = wave_group, color = wave_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Cross-sectional Average Monthly Earnings by Age Group and Wave Group",
       x = "Age Group",
       y = "Average Wage (2015 CNY") +
  scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
  theme_minimal()        # Adds a minimal theme for aesthetics

ggplot(cross_section2, aes(x = age, y = mean_log_wage, group = wave_group, color = wave_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Cross-sectional Average Log Monthly Earnings by Age and Wave Group",
       x = "Age",
       y = "Average log Wage (2015 CNY") +
  scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
  theme_minimal()        # Adds a minimal theme for aesthetics


ggplot(cross_section, aes(x = age_group, y = mean_log_wage, group = wave_group, color = wave_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Cross-sectional Average Log Monthly Earnings by Age Group and Wave Group",
       x = "Age Group",
       y = "Average log Wage (2015 CNY") +
  scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
  theme_minimal()        # Adds a minimal theme for aesthetics


ggplot(cross_section_phr, aes(x = age_group, y = mean_wagephr, group = wave_group, color = wave_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Cross-sectional Average Log Wage by Age Group and Wave Group",
       x = "Age Group",
       y = "Average log Wage (2015 CNY") +
  scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
  theme_minimal()        # Adds a minimal theme for aesthetics

ggplot(cross_section_phr, aes(x = age_group, y = mean_log_wagephr, group = wave_group, color = wave_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Cross-sectional Average Log Wage by Age Group and Wave Group",
       x = "Age Group",
       y = "Average log Wage (2015 CNY") +
  scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
  theme_minimal()        # Adds a minimal theme for aesthetics

# ggplot(cross_section_phr2, aes(x = age, y = mean_wagephr, group = wave_group, color = wave_group)) +
#   geom_line() +          # Draw lines between points
#   geom_point() +         # Add points at each data point
#   labs(title = "Cross-sectional Average Log Wage by Age Group and Wave Group",
#        x = "Age Group",
#        y = "Average log Wage (2015 CNY") +
#   scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
#   theme_minimal()        # Adds a minimal theme for aesthetics



############ Cohort-based wage evolution

start_year <- floor(min(merged_data$dob) / 10) * 10
end_year <- ceiling(max(merged_data$dob) / 10) * 10

merged_data$cohort_group <- cut(merged_data$birthyr,
                       breaks = seq(from = start_year, to = end_year, by = 10),
                       include.lowest = TRUE,
                       right = FALSE, 
                       labels = paste(seq(start_year, end_year - 10, by = 10),
                                      seq(start_year + 9, end_year - 1, by = 10), sep = "-"))

cohort_income <- merged_data  %>% filter(!is.na(wage_inf)) %>% 
  group_by(cohort_group, age) %>% summarize(mean_wage = mean(wage_inf, na.rm = T),
                                            mean_log_wage = mean(log_wage, na.rm = T),
                                            obs = n()) %>% filter(cohort_group != "1920-1929" & cohort_group != "1930-1939")


cohort_income_group <- merged_data  %>% filter(!is.na(wage_inf)) %>% 
  group_by(cohort_group, age_group) %>% summarize(mean_wage = mean(wage_inf, na.rm = T),
                                                  mean_log_wage = mean(log_wage),
                                                  obs = n()) %>%
                      filter(cohort_group != "1920-1929" & cohort_group != "1930-1939")

cohort_income_phr <- merged_data  %>% filter(!is.na(wage_inf)) %>% 
  group_by(cohort_group, age) %>% summarize(mean_wagephr = mean(wgphr_inf, na.rm = T),
                                            mean_log_wagephr = mean(log(wgphr_inf), na.rm = T),
                                      
                                        obs = n()) %>% filter(cohort_group != "1920-1929" & cohort_group != "1930-1939")


cohort_income_group_phr <- merged_data  %>% filter(!is.na(wgphr_inf)) %>% 
  group_by(cohort_group, age_group) %>% summarize(mean_wgphr = mean(wgphr_inf),
                                                  mean_log_wagephr = mean(log(wgphr_inf), na.rm = T),
                                                  mean_hrs = mean(hrspmonth),
                                                  med_hrs = median(hrspmonth),
                                                  med_wgphr = median(wgphr_inf),
                                                  obs = n()) %>% 
  filter(cohort_group != "1920-1929" & cohort_group != "1930-1939")



# Creating the line plot
p1 <- ggplot(cohort_income, aes(x = age, y = mean_wage, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Average Monthly Earnings by Age  and Cohorts",
       x = "Age",
       y = "Average Wage (2015 CNY") +
  scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
  theme_minimal()        # Adds a minimal theme for aesthetics

p2 <- ggplot(cohort_income, aes(x = age, y = mean_log_wage, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Average Log Monthly Earnings by Age  and Cohorts",
       x = "Age",
       y = "Average Log Monthly Earnings (2015 CNY") +
  scale_color_brewer(palette = "Set1") +  # Optional: use a color palette for clarity
  theme_minimal()        # Adds a minimal theme for aesthetics
ggsave(paste0(output_path, "/figures/log_earnings_age_cohort.png"), bg= "white", plot = p2, width = 6, height = 4, dpi = 300)

p3 <- ggplot(cohort_income_group, aes(x = age_group, y = mean_log_wage, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average log monthly earnings by cohort",
       x = "Age",
       y = "Average Log Monthly Earnings (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()   
ggsave(paste0(output_path, "/figures/log_earnings_agegroup_cohort.png"), bg= "white", plot = p3, width = 6, height = 4, dpi = 300)

p4 <- ggplot(cohort_income_group_phr, aes(x = age_group, y = mean_wgphr, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average wage by cohort",
       x = "Age",
       y = "Average Wage (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()   
ggsave(paste0(output_path, "/figures/wage_agegroup_cohort.png"), bg= "white", plot = p4, width = 6, height = 4, dpi = 300)


p5 <- ggplot(cohort_income_group_phr, aes(x = age_group, y = mean_log_wagephr, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average log wage by cohort",
       x = "Age",
       y = "Average Log Wage (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()   
ggsave(paste0(output_path, "/figures/log_wage_agegroup_cohort.png"), bg= "white", plot = p5, width = 6, height = 4, dpi = 300)


p6 <- ggplot(cohort_income_phr, aes(x = age, y = mean_log_wagephr, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average log wage by cohort",
       x = "Age",
       y = "Average Log Wage (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()   
ggsave(paste0(output_path, "/figures/log_wage_age_cohort.png"), bg= "white", plot = p6, width = 6, height = 4, dpi = 300)

p7 <- ggplot(cohort_income_phr, aes(x = age, y = mean_wagephr, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average wage by cohort",
       x = "Age",
       y = "Average Wage (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()   
ggsave(paste0(output_path, "/figures/wage_age_cohort.png"), bg= "white", plot = p7, width = 6, height = 4, dpi = 300)



ggplot(cohort_income_group_phr, aes(x = age_group, y = mean_hrs, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average wage by cohort",
       x = "Age",
       y = "Average Wage (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()  
ggplot(cohort_income_group_phr, aes(x = age_group, y = med_hrs, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average wage by cohort",
       x = "Age",
       y = "Average Wage (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal() 
###############################CONTINUOUS DATA##################
# Summarize the data to see how many observations each individual has across specific time points
obs_summary <- merged_data %>%
  group_by(idind) %>%
  mutate(n_observations = n_distinct(wave),
         min = min(wave),
         max = max(wave))# count distinct time points per individual

# Determine the number of time periods you expect each individual to have
expected_time_periods <- length(unique(merged_data$wave))

# Filter individuals who have observations for all time periods
# Filter to retain only individuals who have continuous records up to the last year of the dataset
continuous_individuals <- obs_summary %>%
  filter(max == 2015)

# Filter the original dataset to include only these individuals
continuous_df <- merged_data %>%
  semi_join(continuous_individuals, by = "idind")


cohort_income_group_continuous <- continuous_df  %>% filter(!is.na(wage_inf)) %>% 
  group_by(cohort_group, age_group) %>% summarize(mean_wage = mean(wage_inf, na.rm = T),
                                                  mean_log_wage = mean(log_wage, na.rm = T),
                                                  obs = n()) %>% 
  filter(cohort_group != "1920-1929" & cohort_group != "1930-1939")

cohort_income_group_phr_continuous <- continuous_df  %>% filter(!is.na(wgphr_inf)) %>% 
  group_by(cohort_group, age_group) %>% summarize(mean_wgphr = mean(wgphr_inf, na.rm = T),
                                                  mean_log_wgphr = mean(log(wgphr_inf), na.rm = T),
                                                  obs = n()) %>% 
  filter(cohort_group != "1920-1929" & cohort_group != "1930-1939")

p9 <- ggplot(cohort_income_group_phr_continuous, aes(x = age_group,
                                               y = mean_log_wgphr, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average log wage by cohort (Continuous data)",
       x = "Age",
       y = "Average Log Wage (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()   
ggsave(paste0(output_path, "/figures/log_wage_agegroup_cohort_ctn.png"), bg= "white", plot = p9, width = 6, height = 4, dpi = 300)


p8 <- ggplot(cohort_income_group_continuous, aes(x = age_group,
                                               y = mean_log_wage, group = cohort_group, color = cohort_group)) +
  geom_line() +          # Draw lines between points
  geom_point() +         # Add points at each data point
  labs(title = "Life cycle of average log monthly earnings by cohort (Continuous data)",
       x = "Age",
       y = "Average Monthly Earnings (2015 CNY)") +
  scale_color_brewer(palette = "Set1") + 
  theme_minimal()   
ggsave(paste0(output_path, "/figures/log_earnings_agegroup_cohort_ctn.png"), bg= "white", plot = p8, width = 6, height = 4, dpi = 300)



################################################Regressions
merged_data2 <- left_join(merged_data, edu, by = c("idind", "wave", "province"))
merged_data2 <- left_join(merged_data2, rst, by = c('idind', 'wave'))
merged_data2$marital <- ifelse(merged_data2$marital < 1 | merged_data2$marital > 5, NA, 
                               merged_data2$marital)
merged_data2$highest_level <- ifelse(merged_data2$highest_level < 0 | merged_data2$highest_level == 9,
                                     NA, merged_data2$highest_level)
#merged_data3 <- merged_data2 %>% filter(cohort_group != "1930-1939" & cohort_group != "1940-1949" &
                                         # cohort_group != "1990-1999")
merged_data3 <- merged_data2 %>% filter(cohort_group != "1930-1939" &
                                          cohort_group != "1990-1999")
merged_data3$marital <- ifelse(merged_data3$marital != 2, 0, 1)
library(plm)
library(lmtest)
library(sandwich)
library(stargazer)
merged_data3 <- pdata.frame(merged_data3, index = c("idind", "wave")) 
merged_data3$exp <- merged_data3$age - 20 
model2 <- plm(log(wage_inf) ~ age + I(age^2)   + age:cohort_group  + I(age^2):cohort_group + factor(marital),
              data = merged_data3, 
              model = "within") 
robust_se2 <- coeftest(model2, vcovHC(model2, type = "HC1"))

model3 <- plm(log(wage_inf) ~ age + I(age^2)  + age:cohort_group +I(age^2):cohort_group + factor(marital) + gender:marital,
              data = merged_data3, effect = "individual",
              model = "within")  
robust_se3 <- coeftest(model3, vcovHC(model3, type = "HC1"))
model4 <- plm(log(wage_inf) ~ age + I(age^2) + gender:marital + age:cohort_group  + I(age^2):cohort_group + factor(marital) +hrspmonth,
              data = merged_data3, 
              model = "within")  
robust_se4 <- coeftest(model4, vcovHC(model4, type = "HC1"))

model5 <- plm(wgphr_inf ~ age + I(age^2) + cohort_group + age:cohort_group + I(age^2):cohort_group +
              factor(marital), data = merged_data3, model = "within")
model6 <-  plm(log(wage_inf) ~ exp + I(exp^2)  + factor(cohort_group) + factor(marital),
               data = merged_data3, 
               model = "within")  

model7 <-  plm(log(wage_inf) ~age + I(age^2) + cohort_group + age:cohort_group + factor(marital),
               data = merged_data3, effect = "individual",
               model = "within")  
model8 <-  plm(hrspmonth ~ age + I(age^2) + cohort_group + age:cohort_group + I(age^2):cohort_group +
                 factor(marital), data = merged_data3, model = "within")
model9 <-  plm(log(wage_inf) ~ exp + I(exp^2) + exp:cohort_group+hrspmonth + factor(marital),
              data = merged_data3, 
              model = "within") 
model12  <- plm(log(wgphr_inf) ~age + I(age^2) + cohort_group + age:cohort_group + I(age^2):cohort_group +
                  factor(marital), data = merged_data3, model = "within")
robust_se12 <- coeftest(model12, vcovHC(model12, type = "HC1"))
model13  <- plm(log(wgphr_inf) ~age + I(age^2) + cohort_group + age:cohort_group + I(age^2):cohort_group + gender:marital+
                  factor(marital), data = merged_data3, model = "within")
robust_se13 <- coeftest(model13, vcovHC(model13, type = "HC1"))


Q1 <- quantile(merged_data2$hrspmonth, 0.25, na.rm = T)
Q3 <- quantile(merged_data2$hrspmonth, 0.75, na.rm = T)
IQR <- Q3 - Q1
outliers <- merged_data2$hrspmonth < (Q1 - 1.5 * IQR) | merged_data2$hrspmonth > (Q3 + 1.5 * IQR)
merged_data2$outliers <- outliers  # Add outlier flag to data
merged_data4 =merged_data2 %>% filter(cohort_group != "1930-1939" &
                                        cohort_group != "1990-1999") %>% filter(outliers == 0)

merged_data4 <- pdata.frame(merged_data4, index = c('idind', 'wave'))
merged_data4$marital <- ifelse(merged_data4$marital != 2, 0, 1)
merged_data4$exp <- merged_data4$age - 20
model10 <- plm(log(wgphr_inf) ~ age + I(age^2) + factor(cohort_group) + age:cohort_group + I(age^2):cohort_group +
                 factor(marital) + gender:marital, data = merged_data4, model = "within",
               effect = 'individual')
robust_se10 <- coeftest(model10, vcovHC(model10, type = "HC1"))
model14 <- plm(log(wgphr_inf) ~ age + I(age^2) + factor(cohort_group) + age:cohort_group + I(age^2):cohort_group +
                 factor(marital) , data = merged_data4, model = "within",
               effect = 'individual')
robust_se14 <- coeftest(model14, vcovHC(model14, type = "HC1"))
model11 <- plm(log(wage_inf) ~ exp + I(exp^2) + factor(cohort_group) + exp:cohort_group + I(exp^2):cohort_group +
                 factor(marital) + gender:marital, data = merged_data4, model = "within",
               effect = 'individual')

## Exporting regression output
model_earnings <- list(robust_se2, robust_se3, robust_se4)

stargazer(model_earnings, type = "text", report=('vc*s'),
          dep.var.labels = "Log Monthly earnings",
          out = paste0(output_path, "tables/","earnings")
          )
stargazer(list(robust_se12, robust_se13), type = "text", report=('vc*s'),
          dep.var.labels = "Log Wage",
          out = paste0(output_path, "tables/","wage")
)
stargazer(list(robust_se14, robust_se10), type = "text", report=('vc*s'),
          dep.var.labels = "Log Wage (removed outliers",
          out = paste0(output_path, "tables/","wage(no_outliers")
)

m1 <- lm(log(wage_inf) ~age + I(age^2) + cohort_group + age:cohort_group + factor(marital) + factor(highest_level) +
           I(age^2):cohort_group + factor(gender),
data = merged_data3)

