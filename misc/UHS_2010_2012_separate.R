rm(list = ls())
library(readxl)
library(tidyverse)
#data = read_excel("/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/UHS_2010-12/2010-12p.xlsx")
#data = data[,-1 ]
#names(data) = c('division', 'hh', 'year', 'member_id', 'yearstart', 'employ',
                #'industry', 'occ', 'rel', 'registration', 'year_city', 'ethnic', 'gender', 'birthdate', 
                #'edu','marital')
#data_2010 = data %>% filter(year == 2010)
#data_2011 = data %>% filter(year == 2011)
#data_2012 = data %>% filter(year == 2012)


# They call it "supplementary" but actually I think this is the correct file because there are a lot of overlaps with part 1. 
data_supp =  read_excel("/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/UHS_2010-12/2010-12p_p2.xlsx")
data_supp2 = data_supp %>% select(区域代码, 户编码, 年份,月份, 家庭成员代号,
                                  开始参加工作年份, 就业情况, 行业, 职业,
                                  与户主关系, 户口状况, 何时来本市镇居住, 民族,
                                  性别,出生年月, 文化程度,婚姻状况, 总收入)
names(data_supp2) = c("division", "hh", 'year', 'month', 'member_id', 'yearstart', 'employ',
                      'industry', 'occ', 'rel', 'registration', 'year_city', 'ethnic', 'gender', 'birthdate', 
                      'edu','marital', 'salary')
data_supp2_2010 = data_supp2 %>% filter(year == 2010)
data_supp2_2011 = data_supp2 %>% filter(year == 2011)
data_supp2_2012 = data_supp2 %>% filter(year==2012)

#Export the data

write.csv(data_supp2_2010, "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/UHS/raw_data/10-12/salary_2010.csv",
          row.names = F)
write.csv(data_supp2_2011, "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/UHS/raw_data/10-12/salary_2011.csv",
          row.names = F)
write.csv(data_supp2_2012, "/Users/tranguyen/Library/CloudStorage/OneDrive-YaleUniversity/online job ads_china/data/UHS/raw_data/10-12/salary_2012.csv",
          row.names = F)

